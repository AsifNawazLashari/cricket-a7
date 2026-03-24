import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/scoring_engine.dart';
import '../services/app_state.dart';
import '../widgets/common_widgets.dart';

class ScoreScreen extends StatefulWidget {
  final String matchId;
  const ScoreScreen({super.key, required this.matchId});
  @override State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  late ScoringEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = ScoringEngine();
    _engine.loadMatch(widget.matchId);
    _engine.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _engine.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (_engine.isLoading) {
      return Scaffold(backgroundColor: AppTheme.bg,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.cyan)));
    }
    final match = _engine.match;
    final inn = _engine.innings;
    if (match == null || inn == null) {
      return Scaffold(backgroundColor: AppTheme.bg,
        body: Center(child: Text('Match not found', style: AppTheme.rajdhani(18, FontWeight.w600))));
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _buildAppBar(match, appState),
      body: ListView(children: [
        _buildScoreHero(match, inn),
        if (_engine.isFreeHit) const FreeHitBanner(),
        if (_engine.isPowerplayOver) const PowerplayBanner(),
        _buildOverStrip(),
        _buildCreaseRow(inn),
        PartnershipBar(runs: inn.partnershipRuns, balls: inn.partnershipBalls),
        _buildBlockerBanner(),
        if (_engine.blocker == ScoringBlocker.none || _engine.blocker == ScoringBlocker.overComplete)
          _buildRunButtons(),
        if (_engine.blocker == ScoringBlocker.none || _engine.blocker == ScoringBlocker.overComplete)
          _buildExtrasRow(),
        _buildActionRow(appState),
        _buildBattingCard(inn),
        _buildBowlingCard(inn),
        const SizedBox(height: 20),
      ]),
    );
  }

  AppBar _buildAppBar(CricketMatch match, AppState appState) => AppBar(
    backgroundColor: AppTheme.bg2,
    title: Text('${match.team1Name} vs ${match.team2Name}',
      style: AppTheme.rajdhani(15, FontWeight.w700, AppTheme.cyan)),
    leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.muted),
      onPressed: () => Navigator.pop(context)),
    actions: [
      // Undo button
      IconButton(
        icon: Icon(Icons.undo, color: _engine.balls.isNotEmpty ? AppTheme.yellow : AppTheme.muted),
        onPressed: _engine.balls.isNotEmpty ? _doUndo : null,
        tooltip: 'Undo last ball',
      ),
      if (appState.isOrganizer)
        IconButton(icon: const Icon(Icons.settings, color: AppTheme.muted),
          onPressed: _showPowerplaySetup),
    ],
  );

  Widget _buildScoreHero(CricketMatch match, Innings inn) {
    final batTeam = inn.battingTeamId == match.team1Id ? match.team1Name : match.team2Name;
    final crr = inn.crr.toStringAsFixed(2);
    final legalBalls = inn.batterStats.values.fold(0, (s, b) => s + b.balls);
    final overs = '${legalBalls ~/ 6}.${legalBalls % 6}';
    final rrr = inn.target != null && legalBalls < (match.overs * 6)
        ? ((inn.target! - inn.runs) / ((match.overs * 6 - legalBalls) / 6)).toStringAsFixed(2)
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(gradient: AppTheme.cardGrad,
        border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const LiveBadge(),
          Text('${inn.inningsNo == 1 ? '1st' : '2nd'} Innings',
            style: AppTheme.condensed(11, FontWeight.w600, AppTheme.muted)),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Column(children: [
            Text('${inn.runs}/${inn.wickets}',
              style: AppTheme.rajdhani(48, FontWeight.w700, AppTheme.cyan)
                .copyWith(shadows: [Shadow(color: AppTheme.cyan.withOpacity(0.4), blurRadius: 20)])),
            Text('$overs ov   |   CRR: $crr',
              style: AppTheme.condensed(13, FontWeight.w500, AppTheme.muted)),
          ]),
        ]),
        if (inn.target != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.yellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.yellow.withOpacity(0.3)),
            ),
            child: Text('Target: ${inn.target}  |  Need: ${inn.target! - inn.runs}'
              '${rrr != null ? '  |  RRR: $rrr' : ''}',
              style: AppTheme.condensed(12, FontWeight.w700, AppTheme.yellow)),
          ),
        ],
        if (inn.extras > 0) ...[
          const SizedBox(height: 6),
          Text('Extras: ${inn.extras}  (Wd ${inn.wides}, Nb ${inn.noballs}, B ${inn.byes}, LB ${inn.legbyes})',
            style: AppTheme.condensed(11, FontWeight.w400, AppTheme.muted)),
        ],
      ]),
    );
  }

  Widget _buildOverStrip() {
    final overNo = _engine.balls.isNotEmpty
        ? _engine.balls.last.overNo : 0;
    final currentOverBalls = _engine.balls.where((b) => b.overNo == overNo).toList();
    return OverStrip(balls: currentOverBalls);
  }

  Widget _buildCreaseRow(Innings inn) {
    final striker = _engine.striker;
    final nonStriker = _engine.nonStriker;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(children: [
        Expanded(child: _creaseCard(
          label: 'STRIKER ⚡',
          player: striker,
          stat: striker != null ? inn.batterStats[striker.id] : null,
          color: AppTheme.yellow,
        )),
        const SizedBox(width: 8),
        Expanded(child: _creaseCard(
          label: 'NON-STRIKER',
          player: nonStriker,
          stat: nonStriker != null ? inn.batterStats[nonStriker.id] : null,
          color: AppTheme.cyan,
        )),
      ]),
    );
  }

  Widget _creaseCard({required String label, Player? player, BatterStat? stat, required Color color}) =>
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTheme.condensed(9, FontWeight.w700, AppTheme.muted)),
        const SizedBox(height: 4),
        Text(player?.name ?? '—', style: AppTheme.rajdhani(15, FontWeight.w700),
          overflow: TextOverflow.ellipsis),
        if (stat != null)
          Text('${stat.runs} (${stat.balls})  4s:${stat.fours}  6s:${stat.sixes}',
            style: AppTheme.condensed(10, FontWeight.w500, AppTheme.muted)),
      ]),
    );

  Widget _buildBlockerBanner() {
    final blocker = _engine.blocker;
    if (blocker == ScoringBlocker.none) return const SizedBox();

    String msg = '';
    Color color = AppTheme.yellow;
    VoidCallback? action;
    String actionLabel = '';

    switch (blocker) {
      case ScoringBlocker.overComplete:
        msg = '🏁 Over Complete! Select new bowler to continue.';
        action = _showBowlerPicker; actionLabel = '🎳 Select Bowler';
        break;
      case ScoringBlocker.needBowler:
        msg = 'No bowler selected'; color = AppTheme.yellow;
        action = _showBowlerPicker; actionLabel = 'Select Bowler';
        break;
      case ScoringBlocker.needBatsman:
        msg = 'No batsman at crease'; color = AppTheme.red;
        action = _showBatsmanPicker; actionLabel = 'Select Batsman';
        break;
      case ScoringBlocker.targetChased:
        msg = '🏆 Target chased! Innings complete.'; color = AppTheme.green;
        action = _declareResult; actionLabel = 'Declare Result';
        break;
      case ScoringBlocker.inningsComplete:
        msg = 'Innings complete';
        if (_engine.innings?.inningsNo == 1) {
          action = _start2ndInnings; actionLabel = 'Start 2nd Innings';
        } else {
          action = _declareResult; actionLabel = 'Declare Result';
        }
        break;
      default: return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(children: [
        Expanded(child: Text(msg, style: AppTheme.condensed(13, FontWeight.w600, color))),
        if (action != null)
          AppButton.primary(label: actionLabel, onTap: action, small: true),
      ]),
    );
  }

  Widget _buildRunButtons() {
    final locked = _engine.blocker == ScoringBlocker.overComplete;
    final isPP = _engine.isPowerplayOver;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Record Delivery', style: AppTheme.condensed(10, FontWeight.w700, AppTheme.muted)),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.3,
          children: [
            for (final r in [0, 1, 2, 3, 4, 6])
              _runBtn(r, locked: locked, pp: isPP),
            _runBtn(5, locked: locked, pp: isPP),
            _wicketBtn(locked: locked),
          ],
        ),
      ]),
    );
  }

  Widget _runBtn(int r, {bool locked = false, bool pp = false}) {
    final colors = {
      0: AppTheme.muted, 1: AppTheme.text, 2: AppTheme.text, 3: AppTheme.text,
      4: AppTheme.green, 5: AppTheme.text, 6: AppTheme.yellow,
    };
    final c = colors[r] ?? AppTheme.text;
    return GestureDetector(
      onTap: locked ? null : () => _engine.recordBall(runs: r, type: 'normal'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: c.withOpacity(locked ? 0.03 : pp ? 0.15 : 0.08),
          border: Border.all(color: c.withOpacity(locked ? 0.1 : pp ? 0.6 : 0.25)),
          boxShadow: pp && !locked ? [BoxShadow(color: c.withOpacity(0.2), blurRadius: 8)] : null,
        ),
        child: Center(child: Text('$r', style: AppTheme.rajdhani(24, FontWeight.w700,
          c.withOpacity(locked ? 0.3 : 1.0)))),
      ),
    );
  }

  Widget _wicketBtn({bool locked = false}) => GestureDetector(
    onTap: locked ? null : _showWicketFlow,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.red.withOpacity(locked ? 0.03 : 0.12),
        border: Border.all(color: AppTheme.red.withOpacity(locked ? 0.1 : 0.4)),
      ),
      child: Center(child: Text('WICKET', style: AppTheme.rajdhani(16, FontWeight.w700,
        AppTheme.red.withOpacity(locked ? 0.3 : 1.0)))),
    ),
  );

  Widget _buildExtrasRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Extras', style: AppTheme.condensed(10, FontWeight.w700, AppTheme.muted)),
      const SizedBox(height: 6),
      Wrap(spacing: 6, runSpacing: 6, children: [
        _extraBtn('Wide', () => _showWideDialog()),
        _extraBtn('No Ball', () => _showNoBallDialog()),
        _extraBtn('Bye', () => _showByeDialog(false)),
        _extraBtn('Leg Bye', () => _showByeDialog(true)),
      ]),
      const SizedBox(height: 8),
    ]),
  );

  Widget _extraBtn(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.orange.withOpacity(0.3)),
      ),
      child: Text(label, style: AppTheme.condensed(12, FontWeight.w600, AppTheme.orange)),
    ),
  );

  Widget _buildActionRow(AppState appState) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
    child: Wrap(spacing: 8, runSpacing: 8, children: [
      AppButton.outline(label: '🎳 Bowler', onTap: _showBowlerPicker, small: true),
      AppButton.outline(label: '🏏 Batsman', onTap: _showBatsmanPicker, small: true),
      AppButton.outline(label: '🔄 Ret Hurt', onTap: _showRetiredHurt, small: true),
      if (appState.isOrganizer && _engine.ppEnabled && !_engine.ppBattingClaimed)
        AppButton.outline(label: '⚡ Claim PP', onTap: _engine.claimBattingPowerplay, small: true),
      AppButton.red(label: '🛑 End', onTap: _openEndMatch, small: true),
    ]),
  );

  Widget _buildBattingCard(Innings inn) => GlassCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Row(children: [
          Text('BATTING', style: AppTheme.condensed(10, FontWeight.w700, AppTheme.gn)),
          const Spacer(),
          Text('R  (B)  4s  6s  SR',
            style: AppTheme.condensed(10, FontWeight.w500, AppTheme.muted)),
        ]),
      ),
      ...inn.batterStats.values.map((stat) => BatterRow(
        stat: stat,
        isStriker: stat.playerId == inn.strikerId,
      )),
    ]),
  );

  Widget _buildBowlingCard(Innings inn) => GlassCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Row(children: [
          Text('BOWLING', style: AppTheme.condensed(10, FontWeight.w700, AppTheme.gn)),
          const Spacer(),
          Text('O  R  W  Md  Econ',
            style: AppTheme.condensed(10, FontWeight.w500, AppTheme.muted)),
        ]),
      ),
      ...inn.bowlerStats.values.map((stat) => BowlerRow(
        stat: stat,
        isActive: stat.playerId == inn.currentBowlerId,
      )),
    ]),
  );

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showWideDialog() {
    int extraRuns = 0;
    showModalBottomSheet(context: context, backgroundColor: AppTheme.panel2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Wide Ball', style: AppTheme.rajdhani(20, FontWeight.w700, AppTheme.cyan)),
          const SizedBox(height: 4),
          Text('How many runs off the wide?', style: AppTheme.condensed(13, FontWeight.w500, AppTheme.muted)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [0, 1, 2, 3, 4].map((r) => GestureDetector(
              onTap: () { setS(() => extraRuns = r); },
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: extraRuns == r ? AppTheme.orange.withOpacity(0.3) : AppTheme.panel,
                  border: Border.all(color: extraRuns == r ? AppTheme.orange : AppTheme.border, width: 2),
                ),
                child: Center(child: Text('$r', style: AppTheme.rajdhani(20, FontWeight.w700,
                  extraRuns == r ? AppTheme.orange : AppTheme.text))),
              ),
            )).toList()),
          const SizedBox(height: 20),
          AppButton.primary(label: 'Record Wide +${1 + extraRuns}', width: double.infinity,
            onTap: () {
              Navigator.pop(context);
              _engine.recordBall(runs: 0, type: 'wide', extraRuns: extraRuns);
            }),
        ]),
      )),
    );
  }

  void _showNoBallDialog() {
    int batRuns = 0;
    showModalBottomSheet(context: context, backgroundColor: AppTheme.panel2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('No Ball', style: AppTheme.rajdhani(20, FontWeight.w700, AppTheme.orange)),
          const SizedBox(height: 4),
          Text('Runs scored by batter off the no ball?',
            style: AppTheme.condensed(13, FontWeight.w500, AppTheme.muted)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [0, 1, 2, 3, 4, 6].map((r) => GestureDetector(
              onTap: () { setS(() => batRuns = r); },
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: batRuns == r ? AppTheme.yellow.withOpacity(0.3) : AppTheme.panel,
                  border: Border.all(color: batRuns == r ? AppTheme.yellow : AppTheme.border, width: 2),
                ),
                child: Center(child: Text('$r', style: AppTheme.rajdhani(18, FontWeight.w700,
                  batRuns == r ? AppTheme.yellow : AppTheme.text))),
              ),
            )).toList()),
          const SizedBox(height: 8),
          Text('Next delivery will be a FREE HIT ⚡',
            style: AppTheme.condensed(12, FontWeight.w600, AppTheme.orange)),
          const SizedBox(height: 16),
          AppButton.primary(label: 'Record No Ball + $batRuns runs', width: double.infinity,
            onTap: () {
              Navigator.pop(context);
              _engine.recordBall(runs: batRuns, type: 'noball', extraRuns: 0);
            }),
        ]),
      )),
    );
  }

  void _showByeDialog(bool isLegBye) {
    int runs = 1;
    final type = isLegBye ? 'legbye' : 'bye';
    final label = isLegBye ? 'Leg Bye' : 'Bye';
    showModalBottomSheet(context: context, backgroundColor: AppTheme.panel2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: AppTheme.rajdhani(20, FontWeight.w700, AppTheme.cyan)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3, 4].map((r) => GestureDetector(
              onTap: () { setS(() => runs = r); },
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: runs == r ? AppTheme.cyan.withOpacity(0.2) : AppTheme.panel,
                  border: Border.all(color: runs == r ? AppTheme.cyan : AppTheme.border, width: 2),
                ),
                child: Center(child: Text('$r', style: AppTheme.rajdhani(20, FontWeight.w700,
                  runs == r ? AppTheme.cyan : AppTheme.text))),
              ),
            )).toList()),
          const SizedBox(height: 20),
          AppButton.primary(label: 'Record $runs $label', width: double.infinity,
            onTap: () {
              Navigator.pop(context);
              _engine.recordBall(runs: runs, type: type);
            }),
        ]),
      )),
    );
  }

  void _showWicketFlow() {
    // Step 1: Dismissal type
    String? dismissalType;
    String? fielderId;
    String? dismissedId = _engine.innings?.strikerId;
    bool strikerOut = true;

    final dismissals = [
      ('bowled', 'Bowled'), ('caught', 'Caught'), ('lbw', 'LBW'),
      ('stumped', 'Stumped'), ('runout', 'Run Out'),
      ('hitwicket', 'Hit Wicket'), ('obstructed', 'Obstructing Field'),
    ];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppTheme.panel2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.75, maxChildSize: 0.95,
        builder: (_, sc) => SingleChildScrollView(controller: sc,
          child: Padding(padding: const EdgeInsets.all(20), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
                color: AppTheme.muted.withOpacity(0.4), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('⚡ WICKET', style: AppTheme.rajdhani(22, FontWeight.w700, AppTheme.red)),
              const SizedBox(height: 16),

              // 1. Dismissal type
              Text('How was the batter dismissed?',
                style: AppTheme.condensed(11, FontWeight.w700, AppTheme.muted)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: dismissals.map((d) => GestureDetector(
                  onTap: () => setS(() => dismissalType = d.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: dismissalType == d.$1 ? AppTheme.red.withOpacity(0.2) : AppTheme.panel,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: dismissalType == d.$1 ? AppTheme.red : AppTheme.border),
                    ),
                    child: Text(d.$2, style: AppTheme.condensed(13, FontWeight.w600,
                      dismissalType == d.$1 ? AppTheme.red : AppTheme.text)),
                  ),
                )).toList()),
              const SizedBox(height: 16),

              // 2. Run out specifics
              if (dismissalType == 'runout') ...[
                Text('Who was run out?', style: AppTheme.condensed(11, FontWeight.w700, AppTheme.muted)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () { setS(() { strikerOut = true; dismissedId = _engine.innings?.strikerId; }); },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: strikerOut ? AppTheme.red.withOpacity(0.15) : AppTheme.panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: strikerOut ? AppTheme.red : AppTheme.border),
                      ),
                      child: Column(children: [
                        Text('Striker', style: AppTheme.condensed(10, FontWeight.w600, AppTheme.muted)),
                        Text(_engine.striker?.name ?? '—',
                          style: AppTheme.rajdhani(14, FontWeight.w700)),
                      ]),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: GestureDetector(
                    onTap: () { setS(() { strikerOut = false; dismissedId = _engine.innings?.nonStrikerId; }); },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: !strikerOut ? AppTheme.red.withOpacity(0.15) : AppTheme.panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: !strikerOut ? AppTheme.red : AppTheme.border),
                      ),
                      child: Column(children: [
                        Text('Non-Striker', style: AppTheme.condensed(10, FontWeight.w600, AppTheme.muted)),
                        Text(_engine.nonStriker?.name ?? '—',
                          style: AppTheme.rajdhani(14, FontWeight.w700)),
                      ]),
                    ),
                  )),
                ]),
                const SizedBox(height: 16),
              ],

              // 3. Free hit restriction
              if (_engine.isFreeHit && dismissalType != null && dismissalType != 'runout') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.orange.withOpacity(0.4)),
                  ),
                  child: Text('⚠️ This is a FREE HIT — only Run Out is valid!',
                    style: AppTheme.condensed(12, FontWeight.w700, AppTheme.orange)),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 8),
              AppButton(
                label: dismissalType == null ? 'Select dismissal type' : 'Confirm Wicket',
                onTap: dismissalType == null ? null : () {
                  // Validate free hit
                  if (_engine.isFreeHit && dismissalType != 'runout') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Free Hit — only Run Out allowed!'),
                      backgroundColor: Colors.orange));
                    return;
                  }
                  Navigator.pop(context);
                  _commitWicket(dismissalType!, dismissedId, fielderId);
                },
                gradient: dismissalType != null ? AppTheme.redGrad : null,
                color: dismissalType == null ? AppTheme.panel : null,
                textColor: Colors.white,
                width: double.infinity,
              ),
            ],
          )),
        ),
      )),
    );
  }

  Future<void> _commitWicket(String dismissalType, String? dismissedId, String? fielderId) async {
    final inn = _engine.innings; if (inn == null) return;
    await _engine.recordBall(
      runs: 0, type: 'wicket',
      dismissalType: dismissalType,
      dismissedPlayerId: dismissedId ?? inn.strikerId,
      fielderId: fielderId,
    );
    // Update striker based on who was out
    if (dismissedId == inn.strikerId) {
      inn.strikerId = null;
    } else {
      inn.nonStrikerId = null;
    }
    // Show next batsman picker
    _showBatsmanPicker();
  }

  void _showBowlerPicker() {
    final available = _engine.availableBowlers;
    showModalBottomSheet(context: context, backgroundColor: AppTheme.panel2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🎳 Select Bowler', style: AppTheme.rajdhani(20, FontWeight.w700, AppTheme.yellow)),
          const SizedBox(height: 4),
          Text('Max ${_engine._maxBowlerOvers} overs per bowler',
            style: AppTheme.condensed(11, FontWeight.w500, AppTheme.muted)),
          const SizedBox(height: 12),
          ...available.map((p) {
            final stat = _engine.innings?.bowlerStats[p.id];
            final overs = stat != null ? '${stat.balls ~/ 6}.${stat.balls % 6}' : '0.0';
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: CircleAvatar(backgroundColor: AppTheme.yellow.withOpacity(0.15),
                child: Text(p.jerseyNo?.toString() ?? '#',
                  style: AppTheme.rajdhani(14, FontWeight.w700, AppTheme.yellow))),
              title: Text('${p.roleIcon} ${p.name}', style: AppTheme.rajdhani(16, FontWeight.w700)),
              subtitle: Text('$overs / ${_engine._maxBowlerOvers} overs  •  ${p.role}',
                style: AppTheme.condensed(11, FontWeight.w400, AppTheme.muted)),
              onTap: () {
                Navigator.pop(context);
                _engine.setBowler(p.id);
              },
            );
          }),
          if (available.isEmpty)
            Padding(padding: const EdgeInsets.all(20),
              child: Text('All bowlers have reached their quota',
                style: AppTheme.condensed(14, FontWeight.w500, AppTheme.muted), textAlign: TextAlign.center)),
        ]),
      ),
    );
  }

  void _showBatsmanPicker() {
    final available = _engine.availableBatters;
    showModalBottomSheet(context: context, backgroundColor: AppTheme.panel2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🏏 Select Next Batsman', style: AppTheme.rajdhani(20, FontWeight.w700, AppTheme.cyan)),
          const SizedBox(height: 12),
          ...available.map((p) {
            final isRetHurt = _engine.innings?.batterStats[p.id]?.isRetiredHurt == true;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: CircleAvatar(backgroundColor: AppTheme.cyan.withOpacity(0.1),
                child: Text(p.jerseyNo?.toString() ?? '#',
                  style: AppTheme.rajdhani(14, FontWeight.w700, AppTheme.cyan))),
              title: Row(children: [
                Text('${p.roleIcon} ${p.name}', style: AppTheme.rajdhani(16, FontWeight.w700)),
                if (isRetHurt) ...[
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.yellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text('ret hurt', style: AppTheme.condensed(9, FontWeight.w700, AppTheme.yellow))),
                ],
              ]),
              subtitle: Text(p.role, style: AppTheme.condensed(11, FontWeight.w400, AppTheme.muted)),
              onTap: () {
                Navigator.pop(context);
                _engine.setStriker(p.id);
              },
            );
          }),
          if (available.isEmpty) ...[
            Padding(padding: const EdgeInsets.all(20),
              child: Text('All Out — no more batsmen',
                style: AppTheme.condensed(14, FontWeight.w500, AppTheme.muted), textAlign: TextAlign.center)),
            AppButton.gold(label: 'End Innings', width: double.infinity,
              onTap: () { Navigator.pop(context); _endInnings(); }),
          ],
        ]),
      ),
    );
  }

  void _showRetiredHurt() {
    final inn = _engine.innings; if (inn == null) return;
    final striker = _engine.striker; if (striker == null) return;
    final available = _engine.availableBatters.where((p) => p.id != striker.id).toList();
    showModalBottomSheet(context: context, backgroundColor: AppTheme.panel2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🤕 Retire ${striker.name} Hurt', style: AppTheme.rajdhani(18, FontWeight.w700, AppTheme.yellow)),
          Text('Can return at last wicket', style: AppTheme.condensed(11, FontWeight.w400, AppTheme.muted)),
          const SizedBox(height: 12),
          Text('Select incoming batsman:', style: AppTheme.condensed(11, FontWeight.w700, AppTheme.muted)),
          ...available.map((p) => ListTile(
            title: Text(p.name, style: AppTheme.rajdhani(16, FontWeight.w700)),
            onTap: () {
              Navigator.pop(context);
              _engine.retireHurt(striker.id, p.id);
            },
          )),
        ]),
      ),
    );
  }

  void _showPowerplaySetup() {
    showModalBottomSheet(context: context, backgroundColor: AppTheme.panel2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(padding: const EdgeInsets.all(20), child: Column(
          mainAxisSize: MainAxisSize.min, children: [
            Text('⚡ Powerplay Config', style: AppTheme.rajdhani(20, FontWeight.w700, AppTheme.cyan)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Enable Powerplay', style: AppTheme.barlow(14, FontWeight.w600)),
              Switch(value: _engine.ppEnabled, activeColor: AppTheme.cyan,
                onChanged: (v) { setS(() => _engine.ppEnabled = v); }),
            ]),
            if (_engine.ppEnabled) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Mandatory Overs', style: AppTheme.condensed(10, FontWeight.w700, AppTheme.muted)),
                  Slider(value: _engine.ppMandatoryOvers.toDouble(), min: 1, max: 20,
                    divisions: 19, activeColor: AppTheme.cyan,
                    label: _engine.ppMandatoryOvers.toString(),
                    onChanged: (v) => setS(() => _engine.ppMandatoryOvers = v.round())),
                ])),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Death Overs Bonus', style: AppTheme.barlow(13, FontWeight.w500)),
                Switch(value: _engine.ppDeathBonus, activeColor: AppTheme.cyan,
                  onChanged: (v) { setS(() => _engine.ppDeathBonus = v); }),
              ]),
            ],
            const SizedBox(height: 12),
            AppButton.primary(label: 'Save', width: double.infinity,
              onTap: () { Navigator.pop(context); setState(() {}); }),
          ],
        ));
      }),
    );
  }

  Future<void> _doUndo() async {
    final ok = await _engine.undoLastBall();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? '✅ Last ball undone' : 'Nothing to undo'),
        backgroundColor: ok ? AppTheme.gn : AppTheme.red,
        duration: const Duration(seconds: 2)));
    }
  }

  void _openEndMatch() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.panel,
      title: Text('End Match', style: AppTheme.rajdhani(18, FontWeight.w700, AppTheme.red)),
      content: Text('Are you sure you want to end this match?',
        style: AppTheme.barlow(14, FontWeight.w400)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTheme.condensed(14, FontWeight.w600, AppTheme.muted))),
        TextButton(onPressed: () { Navigator.pop(context); _declareResult(); },
          child: Text('End Match', style: AppTheme.condensed(14, FontWeight.w700, AppTheme.red))),
      ],
    ));
  }

  void _declareResult() {
    Navigator.pop(context); // Return to match list
  }

  void _endInnings() {
    final inn = _engine.innings; if (inn == null) return;
    if (inn.inningsNo == 1) _start2ndInnings();
    else _declareResult();
  }

  void _start2ndInnings() {
    // Navigate to innings setup — handled by parent
    Navigator.pop(context);
  }
}
