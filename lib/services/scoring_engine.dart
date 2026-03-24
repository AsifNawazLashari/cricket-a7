import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

enum ScoringBlocker { none, needBowler, needBatsman, overComplete, inningsComplete, targetChased }

class ScoringEngine extends ChangeNotifier {
  CricketMatch? match;
  Innings? innings;
  List<BallEvent> balls = [];
  List<Player> battingPlayers = [];
  List<Player> bowlingPlayers = [];

  bool isFreeHit = false;
  bool isLoading = false;
  String? error;

  // Powerplay config
  bool ppEnabled = false;
  int ppMandatoryOvers = 3;
  int ppBattingOvers = 1;
  bool ppBattingClaimed = false;
  bool ppDeathBonus = false;

  // Last ball id for undo
  String? _lastBallId;

  ScoringBlocker get blocker {
    final inn = innings;
    if (inn == null) return ScoringBlocker.none;
    if (inn.isComplete) return ScoringBlocker.inningsComplete;
    if (inn.currentBowlerId == null) return ScoringBlocker.needBowler;
    if (inn.strikerId == null) return ScoringBlocker.needBatsman;

    // Check over complete
    final legal = _legalInCurrentOver();
    if (legal >= 6) return ScoringBlocker.overComplete;

    // Check target chased
    if (inn.target != null && inn.runs >= inn.target!) return ScoringBlocker.targetChased;

    return ScoringBlocker.none;
  }

  bool get isPowerplayOver {
    if (!ppEnabled) return false;
    final overNo = _currentOverNo;
    final totalOvers = match?.overs ?? 6;
    if (overNo < ppMandatoryOvers) return true;
    if (ppBattingClaimed && overNo < ppMandatoryOvers + ppBattingOvers) return true;
    if (ppDeathBonus && totalOvers > 2 && overNo >= totalOvers - 2) return true;
    return false;
  }

  int get _currentOverNo {
    final inn = innings;
    if (inn == null) return 0;
    return _totalLegalBalls ~/ 6;
  }

  int get _totalLegalBalls {
    return balls.where((b) => b.isLegal).length;
  }

  int _legalInCurrentOver() {
    final overNo = _currentOverNo;
    return balls.where((b) => b.overNo == overNo && b.isLegal).length;
  }

  // ── Load match into engine ────────────────────────────────────────────────
  Future<void> loadMatch(String matchId) async {
    isLoading = true; notifyListeners();
    match = await FirebaseService.getMatch(matchId);
    if (match == null) { isLoading = false; notifyListeners(); return; }

    // Load active innings (last one)
    if (match!.inningsIds.isNotEmpty) {
      final innId = match!.inningsIds.last;
      innings = await FirebaseService.getInnings(innId);
      if (innings != null) {
        balls = await FirebaseService.getBalls(innId);
        await _loadPlayerLists();
      }
    }
    isLoading = false; notifyListeners();
  }

  Future<void> _loadPlayerLists() async {
    final inn = innings; if (inn == null) return;
    final bt = await FirebaseService.getTeam(inn.battingTeamId);
    final bw = await FirebaseService.getTeam(inn.bowlingTeamId);
    battingPlayers = bt?.players ?? [];
    bowlingPlayers = bw?.players ?? [];
  }

  // ── Start Innings ─────────────────────────────────────────────────────────
  Future<void> startInnings({
    required String matchId, required String battingTeamId,
    required String bowlingTeamId, required int inningsNo,
    int? target,
  }) async {
    final inn = Innings(
      id: '', matchId: matchId,
      battingTeamId: battingTeamId, bowlingTeamId: bowlingTeamId,
      inningsNo: inningsNo, target: target,
    );
    final id = await FirebaseService.createInnings(inn);
    innings = Innings(
      id: id, matchId: matchId,
      battingTeamId: battingTeamId, bowlingTeamId: bowlingTeamId,
      inningsNo: inningsNo, target: target,
      batterStats: {}, bowlerStats: {},
    );
    balls = [];
    await _loadPlayerLists();
    await FirebaseService.updateMatch(matchId, {'status': 'live'});
    notifyListeners();
  }

  // ── Record Ball (core method) ─────────────────────────────────────────────
  Future<void> recordBall({
    required int runs, required String type, int extraRuns = 0,
    // Wicket fields
    String? dismissalType, String? dismissedPlayerId, String? fielderId,
  }) async {
    final inn = innings; if (inn == null) return;
    if (blocker != ScoringBlocker.none && blocker != ScoringBlocker.overComplete) return;

    final overNo = _currentOverNo;
    final ballInOver = _legalInCurrentOver();
    final isLegal = type != 'wide' && type != 'noball';

    // Snapshot pre-state for undo
    final preState = inn.toMap();

    final ball = BallEvent(
      id: '', inningsId: inn.id,
      runs: runs, overNo: overNo, ballInOver: ballInOver,
      type: type, strikerId: inn.strikerId,
      nonStrikerId: inn.nonStrikerId, bowlerId: inn.currentBowlerId,
      dismissalType: dismissalType, dismissedPlayerId: dismissedPlayerId,
      fielderId: fielderId, isFreeHit: isFreeHit,
      extraRuns: extraRuns, timestamp: DateTime.now().millisecondsSinceEpoch,
      preState: preState,
    );

    final ballId = await FirebaseService.recordBall(ball);
    _lastBallId = ballId;
    balls.add(BallEvent(
      id: ballId, inningsId: ball.inningsId, runs: runs,
      overNo: overNo, ballInOver: ballInOver, type: type,
      strikerId: inn.strikerId, nonStrikerId: inn.nonStrikerId,
      bowlerId: inn.currentBowlerId, dismissalType: dismissalType,
      dismissedPlayerId: dismissedPlayerId, fielderId: fielderId,
      isFreeHit: isFreeHit, extraRuns: extraRuns,
      timestamp: ball.timestamp, preState: preState,
    ));

    // ── Update innings state ──────────────────────────────────────────────
    final Map<String,dynamic> updates = {};

    // Runs
    final totalRuns = runs + extraRuns;
    inn.runs += totalRuns;
    updates['runs'] = inn.runs;

    // Extras breakdown
    if (type == 'wide') { inn.wides += 1 + extraRuns; updates['wides'] = inn.wides; }
    if (type == 'noball') { inn.noballs++; updates['noballs'] = inn.noballs; }
    if (type == 'bye') { inn.byes += runs; updates['byes'] = inn.byes; }
    if (type == 'legbye') { inn.legbyes += runs; updates['legbyes'] = inn.legbyes; }

    // Batter stats
    if (inn.strikerId != null && isLegal && type != 'bye' && type != 'legbye' && type != 'wicket') {
      final bs = inn.batterStats[inn.strikerId!] ??
          BatterStat(playerId: inn.strikerId!, playerName: _nameOf(inn.strikerId!, battingPlayers));
      bs.runs += runs;
      bs.balls++;
      if (runs == 4) bs.fours++;
      if (runs == 6) bs.sixes++;
      inn.batterStats[inn.strikerId!] = bs;
      updates['batter_stats/${inn.strikerId}'] = bs.toMap();
    } else if (inn.strikerId != null && isLegal) {
      // bye/legbye: ball count but no runs to batter
      final bs = inn.batterStats[inn.strikerId!] ??
          BatterStat(playerId: inn.strikerId!, playerName: _nameOf(inn.strikerId!, battingPlayers));
      bs.balls++;
      inn.batterStats[inn.strikerId!] = bs;
      updates['batter_stats/${inn.strikerId}'] = bs.toMap();
    }

    // Bowler stats
    if (inn.currentBowlerId != null) {
      final bw = inn.bowlerStats[inn.currentBowlerId!] ??
          BowlerStat(playerId: inn.currentBowlerId!, playerName: _nameOf(inn.currentBowlerId!, bowlingPlayers));
      if (type == 'wide') bw.wides++;
      if (type == 'noball') bw.noballs++;
      if (isLegal) {
        bw.balls++;
        if (type != 'bye' && type != 'legbye') bw.runs += runs;
        if (type == 'wicket' && dismissalType != 'runout') bw.wickets++;
      } else {
        bw.runs += totalRuns; // wides + noball extras charge to bowler
      }
      // Maiden check: if over complete and 0 runs off bat this over
      if (isLegal && bw.balls % 6 == 0) {
        final overBalls = balls.where((b) => b.overNo == overNo && b.bowlerId == inn.currentBowlerId);
        final overRuns = overBalls.fold(0, (s, b) => s + b.totalRuns);
        if (overRuns == 0) bw.maidens++;
      }
      inn.bowlerStats[inn.currentBowlerId!] = bw;
      updates['bowler_stats/${inn.currentBowlerId}'] = bw.toMap();
    }

    // Partnership
    if (isLegal && type != 'wicket') {
      inn.partnershipRuns += totalRuns;
      inn.partnershipBalls++;
      updates['partnership_runs'] = inn.partnershipRuns;
      updates['partnership_balls'] = inn.partnershipBalls;
    }

    // Wicket
    if (type == 'wicket') {
      inn.wickets++;
      updates['wickets'] = inn.wickets;
      // Mark batter out
      if (dismissedPlayerId != null && inn.batterStats.containsKey(dismissedPlayerId)) {
        inn.batterStats[dismissedPlayerId]!.isOut = true;
        inn.batterStats[dismissedPlayerId]!.dismissalType = dismissalType;
        updates['batter_stats/$dismissedPlayerId/is_out'] = true;
        updates['batter_stats/$dismissedPlayerId/dismissal_type'] = dismissalType;
        if (fielderId != null) updates['batter_stats/$dismissedPlayerId/fielder'] = fielderId;
        if (inn.currentBowlerId != null) updates['batter_stats/$dismissedPlayerId/dismissed_by'] = inn.currentBowlerId;
      }
      // Reset partnership
      inn.partnershipRuns = 0; inn.partnershipBalls = 0;
      updates['partnership_runs'] = 0; updates['partnership_balls'] = 0;
    }

    // Rotate strike on odd runs (legal only)
    if (isLegal && type != 'wicket') {
      if (runs % 2 == 1) {
        final tmp = inn.strikerId; inn.strikerId = inn.nonStrikerId; inn.nonStrikerId = tmp;
        updates['striker_id'] = inn.strikerId;
        updates['non_striker_id'] = inn.nonStrikerId;
      }
    }

    // Free hit tracking
    if (type == 'noball') {
      isFreeHit = true;
    } else if (isLegal) {
      isFreeHit = false;
    }

    // Over complete: rotate strike at end of over
    if (isLegal && _legalInCurrentOver() >= 6) {
      final tmp = inn.strikerId; inn.strikerId = inn.nonStrikerId; inn.nonStrikerId = tmp;
      updates['striker_id'] = inn.strikerId;
      updates['non_striker_id'] = inn.nonStrikerId;
      inn.previousBowlerId = inn.currentBowlerId;
      inn.currentBowlerId = null;
      updates['previous_bowler_id'] = inn.previousBowlerId;
      updates['current_bowler_id'] = null;
    }

    // Target chase check
    if (inn.target != null && inn.runs >= inn.target!) {
      inn.isComplete = true; updates['is_complete'] = true;
    }
    // All out check
    if (inn.wickets >= 10) {
      inn.isComplete = true; updates['is_complete'] = true;
    }
    // Overs up
    if (_totalLegalBalls >= (match?.overs ?? 6) * 6 + 1) {
      inn.isComplete = true; updates['is_complete'] = true;
    }

    await FirebaseService.updateInnings(inn.id, updates);
    notifyListeners();
  }

  // ── Undo last ball ────────────────────────────────────────────────────────
  Future<bool> undoLastBall() async {
    if (balls.isEmpty) return false;
    final last = balls.last;
    if (last.preState == null) return false;

    // Remove ball from Firebase
    await FirebaseService.deleteBall(last.inningsId, last.id);
    balls.removeLast();

    // Restore innings from preState
    final restored = Innings.fromMap(innings!.id, last.preState!);
    innings = restored;
    await FirebaseService.updateInnings(innings!.id, last.preState!);

    // Undo free hit
    if (balls.isNotEmpty && balls.last.type == 'noball') {
      isFreeHit = true;
    } else {
      isFreeHit = false;
    }

    notifyListeners();
    return true;
  }

  // ── Set striker ───────────────────────────────────────────────────────────
  Future<void> setStriker(String playerId) async {
    final inn = innings; if (inn == null) return;
    final name = _nameOf(playerId, battingPlayers);
    // Init batter stat if new
    if (!inn.batterStats.containsKey(playerId)) {
      inn.batterStats[playerId] = BatterStat(
        playerId: playerId, playerName: name, order: inn.batterStats.length + 1,
      );
    }
    inn.strikerId = playerId;
    await FirebaseService.updateInnings(inn.id, {
      'striker_id': playerId,
      'batter_stats/$playerId': inn.batterStats[playerId]!.toMap(),
    });
    notifyListeners();
  }

  Future<void> setNonStriker(String playerId) async {
    final inn = innings; if (inn == null) return;
    final name = _nameOf(playerId, battingPlayers);
    if (!inn.batterStats.containsKey(playerId)) {
      inn.batterStats[playerId] = BatterStat(
        playerId: playerId, playerName: name, order: inn.batterStats.length + 1,
      );
    }
    inn.nonStrikerId = playerId;
    await FirebaseService.updateInnings(inn.id, {
      'non_striker_id': playerId,
      'batter_stats/$playerId': inn.batterStats[playerId]!.toMap(),
    });
    notifyListeners();
  }

  // ── Set bowler ────────────────────────────────────────────────────────────
  Future<void> setBowler(String playerId) async {
    final inn = innings; if (inn == null) return;
    if (playerId == inn.previousBowlerId) return; // back-to-back
    final name = _nameOf(playerId, bowlingPlayers);
    if (!inn.bowlerStats.containsKey(playerId)) {
      inn.bowlerStats[playerId] = BowlerStat(playerId: playerId, playerName: name);
    }
    inn.currentBowlerId = playerId;
    await FirebaseService.updateInnings(inn.id, {
      'current_bowler_id': playerId,
      'bowler_stats/$playerId': inn.bowlerStats[playerId]!.toMap(),
    });
    notifyListeners();
  }

  // ── Retired Hurt ──────────────────────────────────────────────────────────
  Future<void> retireHurt(String playerId, String newBatterId) async {
    final inn = innings; if (inn == null) return;
    if (inn.batterStats.containsKey(playerId)) {
      inn.batterStats[playerId]!.isRetiredHurt = true;
    }
    await setStriker(newBatterId);
    await FirebaseService.updateInnings(inn.id, {
      'batter_stats/$playerId/is_retired_hurt': true,
    });
    notifyListeners();
  }

  // ── Bowler quota ──────────────────────────────────────────────────────────
  int maxOversForBowler(String playerId) {
    // Custom quota from tournament, else ceil(overs/5)
    // Passed in from tournament bowlerQuota
    return _maxBowlerOvers;
  }

  int _maxBowlerOvers = 2;
  void setMaxBowlerOvers(int v) { _maxBowlerOvers = v; notifyListeners(); }

  bool bowlerMaxed(String playerId) {
    final inn = innings; if (inn == null) return false;
    final bs = inn.bowlerStats[playerId];
    if (bs == null) return false;
    return bs.balls ~/ 6 >= _maxBowlerOvers;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _nameOf(String id, List<Player> list) =>
      list.firstWhere((p) => p.id == id, orElse: () => Player(id: id, name: 'Unknown', role: 'batsman', teamId: '')).name;

  Player? get striker => battingPlayers.cast<Player?>().firstWhere(
    (p) => p?.id == innings?.strikerId, orElse: () => null);
  Player? get nonStriker => battingPlayers.cast<Player?>().firstWhere(
    (p) => p?.id == innings?.nonStrikerId, orElse: () => null);
  Player? get currentBowler => bowlingPlayers.cast<Player?>().firstWhere(
    (p) => p?.id == innings?.currentBowlerId, orElse: () => null);

  List<Player> get availableBatters {
    final inn = innings; if (inn == null) return [];
    final usedIds = inn.batterStats.keys.toSet();
    // Remove retired hurt unless last wicket scenario
    return battingPlayers.where((p) {
      if (!usedIds.contains(p.id)) return true;
      final stat = inn.batterStats[p.id]!;
      return stat.isRetiredHurt && inn.wickets >= 9; // can return at last wicket
    }).toList();
  }

  List<Player> get availableBowlers {
    final inn = innings; if (inn == null) return [];
    return bowlingPlayers.where((p) {
      return p.id != inn.previousBowlerId && !bowlerMaxed(p.id);
    }).toList();
  }

  // Over history: group balls by over
  List<List<BallEvent>> get overHistory {
    final Map<int, List<BallEvent>> byOver = {};
    for (final b in balls) {
      byOver.putIfAbsent(b.overNo, () => []).add(b);
    }
    return byOver.values.toList();
  }

  void claimBattingPowerplay() {
    ppBattingClaimed = true;
    notifyListeners();
  }
}
