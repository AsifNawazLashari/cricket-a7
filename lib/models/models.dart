// ── Tournament ────────────────────────────────────────────────────────────
class Tournament {
  final String id, name, format;
  final int overs;
  final String? venue, startDate;
  final int bowlerQuota; // custom per-match quota, 0 = auto (ceil(overs/5))

  Tournament({
    required this.id, required this.name, required this.format,
    required this.overs, this.venue, this.startDate, this.bowlerQuota = 0,
  });

  factory Tournament.fromMap(String id, Map<String,dynamic> m) => Tournament(
    id: id, name: m['name'] ?? '', format: m['format'] ?? 'round_robin',
    overs: m['overs'] ?? 6, venue: m['venue'], startDate: m['start_date'],
    bowlerQuota: m['bowler_quota'] ?? 0,
  );

  Map<String,dynamic> toMap() => {
    'name': name, 'format': format, 'overs': overs,
    if (venue != null) 'venue': venue,
    if (startDate != null) 'start_date': startDate,
    'bowler_quota': bowlerQuota,
  };
}

// ── Team ──────────────────────────────────────────────────────────────────
class CricketTeam {
  final String id, name, code, tournamentId;
  final String color;
  final List<Player> players;
  final String? captainId;

  CricketTeam({
    required this.id, required this.name, required this.code,
    required this.tournamentId, this.color = '#1B4D1F',
    this.players = const [], this.captainId,
  });

  factory CricketTeam.fromMap(String id, Map<String,dynamic> m) {
    final pMap = m['players'] as Map? ?? {};
    final players = pMap.entries.map((e) =>
      Player.fromMap(e.key, Map<String,dynamic>.from(e.value as Map))).toList();
    return CricketTeam(
      id: id, name: m['name'] ?? '', code: m['code'] ?? '',
      tournamentId: m['tournament_id'] ?? '', color: m['color'] ?? '#1B4D1F',
      players: players, captainId: m['captain_id'],
    );
  }

  Map<String,dynamic> toMap() => {
    'name': name, 'code': code, 'tournament_id': tournamentId,
    'color': color, if (captainId != null) 'captain_id': captainId,
  };
}

// ── Player ────────────────────────────────────────────────────────────────
class Player {
  final String id, name, role, teamId;
  final int? jerseyNo;
  bool retiredHurt;   // can return if last wicket pending

  Player({
    required this.id, required this.name, required this.role,
    required this.teamId, this.jerseyNo, this.retiredHurt = false,
  });

  factory Player.fromMap(String id, Map<String,dynamic> m) => Player(
    id: id, name: m['name'] ?? '', role: m['role'] ?? 'allrounder',
    teamId: m['team_id'] ?? '', jerseyNo: m['jersey_no'],
    retiredHurt: m['retired_hurt'] == true,
  );

  Map<String,dynamic> toMap() => {
    'name': name, 'role': role, 'team_id': teamId,
    if (jerseyNo != null) 'jersey_no': jerseyNo,
    'retired_hurt': retiredHurt,
  };

  String get roleIcon => const {
    'batsman': '🏏', 'bowler': '🎳', 'allrounder': '⭐', 'wicketkeeper': '🧤',
  }[role] ?? '';
}

// ── Match ─────────────────────────────────────────────────────────────────
class CricketMatch {
  final String id;
  String status; // scheduled | live | completed
  final String team1Id, team2Id, team1Name, team2Name;
  final String? tournamentId, tournamentName, venue, stage;
  final int overs, roundNo;
  String? tossWinnerId, tossDecision, battingFirstId;
  String? winnerId, resultDesc;
  List<String> inningsIds;
  Map<String,String> team1Map, team2Map; // id->name for all players

  CricketMatch({
    required this.id, required this.status,
    required this.team1Id, required this.team2Id,
    required this.team1Name, required this.team2Name,
    this.tournamentId, this.tournamentName, this.venue, this.stage,
    required this.overs, this.roundNo = 1,
    this.tossWinnerId, this.tossDecision, this.battingFirstId,
    this.winnerId, this.resultDesc,
    this.inningsIds = const [],
    this.team1Map = const {}, this.team2Map = const {},
  });

  factory CricketMatch.fromMap(String id, Map<String,dynamic> m) {
    final idsMap = m['innings_ids'] as Map? ?? {};
    return CricketMatch(
      id: id, status: m['status'] ?? 'scheduled',
      team1Id: m['team1_id'] ?? '', team2Id: m['team2_id'] ?? '',
      team1Name: m['team1_name'] ?? '', team2Name: m['team2_name'] ?? '',
      tournamentId: m['tournament_id'], tournamentName: m['tournament_name'],
      venue: m['venue'], stage: m['stage'],
      overs: m['overs'] ?? 6, roundNo: m['round_no'] ?? 1,
      tossWinnerId: m['toss_winner_id'], tossDecision: m['toss_decision'],
      battingFirstId: m['batting_first_id'],
      winnerId: m['winner_id'], resultDesc: m['result_desc'],
      inningsIds: idsMap.keys.map((e) => e.toString()).toList(),
    );
  }

  Map<String,dynamic> toMap() => {
    'status': status, 'team1_id': team1Id, 'team2_id': team2Id,
    'team1_name': team1Name, 'team2_name': team2Name,
    if (tournamentId != null) 'tournament_id': tournamentId,
    if (tournamentName != null) 'tournament_name': tournamentName,
    if (venue != null) 'venue': venue,
    if (stage != null) 'stage': stage,
    'overs': overs, 'round_no': roundNo,
    if (tossWinnerId != null) 'toss_winner_id': tossWinnerId,
    if (tossDecision != null) 'toss_decision': tossDecision,
    if (battingFirstId != null) 'batting_first_id': battingFirstId,
    if (winnerId != null) 'winner_id': winnerId,
    if (resultDesc != null) 'result_desc': resultDesc,
  };
}

// ── Innings ───────────────────────────────────────────────────────────────
class Innings {
  final String id, matchId, battingTeamId, bowlingTeamId;
  final int inningsNo;
  int runs, wickets, wides, noballs, byes, legbyes;
  String? strikerId, nonStrikerId, currentBowlerId, previousBowlerId;
  int? target;
  bool isComplete;

  // Batter stats map: playerId -> BatterStat
  Map<String, BatterStat> batterStats;
  // Bowler stats map: playerId -> BowlerStat
  Map<String, BowlerStat> bowlerStats;
  // Partnership tracking
  int partnershipRuns, partnershipBalls;

  Innings({
    required this.id, required this.matchId,
    required this.battingTeamId, required this.bowlingTeamId,
    required this.inningsNo,
    this.runs = 0, this.wickets = 0,
    this.wides = 0, this.noballs = 0, this.byes = 0, this.legbyes = 0,
    this.strikerId, this.nonStrikerId, this.currentBowlerId, this.previousBowlerId,
    this.target, this.isComplete = false,
    this.batterStats = const {}, this.bowlerStats = const {},
    this.partnershipRuns = 0, this.partnershipBalls = 0,
  });

  int get extras => wides + noballs + byes + legbyes;
  int get totalBalls => batterStats.values.fold(0, (s, b) => s + b.balls);
  String get overStr {
    final legal = totalBalls;
    return '${legal ~/ 6}.${legal % 6}';
  }
  double get crr => totalBalls > 0 ? runs / (totalBalls / 6) : 0.0;

  factory Innings.fromMap(String id, Map<String,dynamic> m) {
    final bsMap = m['batter_stats'] as Map? ?? {};
    final bowMap = m['bowler_stats'] as Map? ?? {};
    return Innings(
      id: id, matchId: m['match_id'] ?? '',
      battingTeamId: m['batting_team_id'] ?? '',
      bowlingTeamId: m['bowling_team_id'] ?? '',
      inningsNo: m['innings_no'] ?? 1,
      runs: m['runs'] ?? 0, wickets: m['wickets'] ?? 0,
      wides: m['wides'] ?? 0, noballs: m['noballs'] ?? 0,
      byes: m['byes'] ?? 0, legbyes: m['legbyes'] ?? 0,
      strikerId: m['striker_id'], nonStrikerId: m['non_striker_id'],
      currentBowlerId: m['current_bowler_id'],
      previousBowlerId: m['previous_bowler_id'],
      target: m['target'], isComplete: m['is_complete'] == true,
      batterStats: bsMap.map((k, v) =>
          MapEntry(k, BatterStat.fromMap(k, Map<String,dynamic>.from(v as Map)))),
      bowlerStats: bowMap.map((k, v) =>
          MapEntry(k, BowlerStat.fromMap(k, Map<String,dynamic>.from(v as Map)))),
      partnershipRuns: m['partnership_runs'] ?? 0,
      partnershipBalls: m['partnership_balls'] ?? 0,
    );
  }

  Map<String,dynamic> toMap() => {
    'match_id': matchId, 'batting_team_id': battingTeamId,
    'bowling_team_id': bowlingTeamId, 'innings_no': inningsNo,
    'runs': runs, 'wickets': wickets, 'wides': wides,
    'noballs': noballs, 'byes': byes, 'legbyes': legbyes,
    if (strikerId != null) 'striker_id': strikerId,
    if (nonStrikerId != null) 'non_striker_id': nonStrikerId,
    if (currentBowlerId != null) 'current_bowler_id': currentBowlerId,
    if (previousBowlerId != null) 'previous_bowler_id': previousBowlerId,
    if (target != null) 'target': target,
    'is_complete': isComplete,
    'batter_stats': batterStats.map((k, v) => MapEntry(k, v.toMap())),
    'bowler_stats': bowlerStats.map((k, v) => MapEntry(k, v.toMap())),
    'partnership_runs': partnershipRuns, 'partnership_balls': partnershipBalls,
  };
}

// ── BatterStat ────────────────────────────────────────────────────────────
class BatterStat {
  final String playerId, playerName;
  int runs, balls, fours, sixes;
  bool isOut, isRetiredHurt;
  String? dismissalType, dismissedBy, fielder;
  int order;

  BatterStat({
    required this.playerId, required this.playerName,
    this.runs = 0, this.balls = 0, this.fours = 0, this.sixes = 0,
    this.isOut = false, this.isRetiredHurt = false,
    this.dismissalType, this.dismissedBy, this.fielder, this.order = 0,
  });

  double get sr => balls > 0 ? runs / balls * 100 : 0.0;

  factory BatterStat.fromMap(String id, Map<String,dynamic> m) => BatterStat(
    playerId: id, playerName: m['player_name'] ?? '',
    runs: m['runs'] ?? 0, balls: m['balls'] ?? 0,
    fours: m['fours'] ?? 0, sixes: m['sixes'] ?? 0,
    isOut: m['is_out'] == true, isRetiredHurt: m['is_retired_hurt'] == true,
    dismissalType: m['dismissal_type'], dismissedBy: m['dismissed_by'],
    fielder: m['fielder'], order: m['order'] ?? 0,
  );

  Map<String,dynamic> toMap() => {
    'player_name': playerName, 'runs': runs, 'balls': balls,
    'fours': fours, 'sixes': sixes, 'is_out': isOut,
    'is_retired_hurt': isRetiredHurt, 'order': order,
    if (dismissalType != null) 'dismissal_type': dismissalType,
    if (dismissedBy != null) 'dismissed_by': dismissedBy,
    if (fielder != null) 'fielder': fielder,
  };
}

// ── BowlerStat ────────────────────────────────────────────────────────────
class BowlerStat {
  final String playerId, playerName;
  int balls, runs, wickets, wides, noballs, maidens;

  BowlerStat({
    required this.playerId, required this.playerName,
    this.balls = 0, this.runs = 0, this.wickets = 0,
    this.wides = 0, this.noballs = 0, this.maidens = 0,
  });

  double get econ => balls > 0 ? runs / (balls / 6) : 0.0;
  String get overStr => '${balls ~/ 6}.${balls % 6}';

  factory BowlerStat.fromMap(String id, Map<String,dynamic> m) => BowlerStat(
    playerId: id, playerName: m['player_name'] ?? '',
    balls: m['balls'] ?? 0, runs: m['runs'] ?? 0,
    wickets: m['wickets'] ?? 0, wides: m['wides'] ?? 0,
    noballs: m['noballs'] ?? 0, maidens: m['maidens'] ?? 0,
  );

  Map<String,dynamic> toMap() => {
    'player_name': playerName, 'balls': balls, 'runs': runs,
    'wickets': wickets, 'wides': wides, 'noballs': noballs, 'maidens': maidens,
  };
}

// ── BallEvent (Immutable event ledger) ────────────────────────────────────
class BallEvent {
  final String id, inningsId;
  final int runs, overNo, ballInOver;
  final String type; // normal|wide|noball|bye|legbye|wicket
  final String? strikerId, nonStrikerId, bowlerId;
  final String? dismissalType, dismissedPlayerId, fielderId;
  final bool isFreeHit;
  final int extraRuns; // runs off wide/noball beyond the extra
  final int timestamp;
  // Undo: snapshot of innings state before this ball
  final Map<String,dynamic>? preState;

  BallEvent({
    required this.id, required this.inningsId,
    required this.runs, required this.overNo, required this.ballInOver,
    required this.type,
    this.strikerId, this.nonStrikerId, this.bowlerId,
    this.dismissalType, this.dismissedPlayerId, this.fielderId,
    this.isFreeHit = false, this.extraRuns = 0,
    required this.timestamp, this.preState,
  });

  bool get isLegal => type != 'wide' && type != 'noball';
  bool get isWicket => type == 'wicket';
  bool get isExtra => type == 'wide' || type == 'noball' || type == 'bye' || type == 'legbye';
  int get totalRuns => runs + extraRuns;

  factory BallEvent.fromMap(String id, String inningsId, Map<String,dynamic> m) => BallEvent(
    id: id, inningsId: inningsId,
    runs: m['runs'] ?? 0, overNo: m['over_no'] ?? 0,
    ballInOver: m['ball_in_over'] ?? 0, type: m['type'] ?? 'normal',
    strikerId: m['striker_id'], nonStrikerId: m['non_striker_id'],
    bowlerId: m['bowler_id'],
    dismissalType: m['dismissal_type'], dismissedPlayerId: m['dismissed_player_id'],
    fielderId: m['fielder_id'],
    isFreeHit: m['is_free_hit'] == true, extraRuns: m['extra_runs'] ?? 0,
    timestamp: m['timestamp'] ?? 0,
    preState: m['pre_state'] != null ? Map<String,dynamic>.from(m['pre_state'] as Map) : null,
  );

  Map<String,dynamic> toMap() => {
    'runs': runs, 'over_no': overNo, 'ball_in_over': ballInOver, 'type': type,
    if (strikerId != null) 'striker_id': strikerId,
    if (nonStrikerId != null) 'non_striker_id': nonStrikerId,
    if (bowlerId != null) 'bowler_id': bowlerId,
    if (dismissalType != null) 'dismissal_type': dismissalType,
    if (dismissedPlayerId != null) 'dismissed_player_id': dismissedPlayerId,
    if (fielderId != null) 'fielder_id': fielderId,
    'is_free_hit': isFreeHit, 'extra_runs': extraRuns,
    'timestamp': timestamp,
    if (preState != null) 'pre_state': preState,
  };

  String get label {
    if (type == 'wicket') return 'W';
    if (type == 'wide') return extraRuns > 0 ? 'Wd+$extraRuns' : 'Wd';
    if (type == 'noball') return extraRuns > 0 ? 'Nb+$extraRuns' : 'Nb';
    if (type == 'bye') return '${runs}b';
    if (type == 'legbye') return '${runs}lb';
    return '$runs';
  }
}

// ── AppUser ───────────────────────────────────────────────────────────────
class AppUser {
  final String id, username, role;
  final String? email, teamId;

  AppUser({
    required this.id, required this.username, required this.role,
    this.email, this.teamId,
  });

  bool get isDeveloper => role == 'developer';
  bool get isOrganizer => role == 'organizer' || isDeveloper;
  bool get isCaptain => role == 'captain' || isOrganizer;

  factory AppUser.fromMap(String id, Map<String,dynamic> m) => AppUser(
    id: id, username: m['username'] ?? '', role: m['role'] ?? 'viewer',
    email: m['email'], teamId: m['team_id'],
  );

  Map<String,dynamic> toMap() => {
    'username': username, 'role': role,
    if (email != null) 'email': email,
    if (teamId != null) 'team_id': teamId,
  };
}
