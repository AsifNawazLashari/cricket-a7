import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../services/firebase_service.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import 'package:provider/provider.dart';

// ── Tournaments Screen ────────────────────────────────────────────────────
class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});
  @override State<TournamentsScreen> createState() => _TournamentsScreenState();
}
class _TournamentsScreenState extends State<TournamentsScreen> {
  List<Tournament> _tournaments = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final ts = await FirebaseService.getTournaments();
    setState(() { _tournaments = ts; _loading = false; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    body: RefreshIndicator(onRefresh: _load, color: AppTheme.cyan, child: ListView(children: [
      SectionHeader(title: 'FIXTURES & TOURNAMENTS',
        trailing: context.watch<AppState>().isOrganizer
          ? AppButton.primary(label: '+ New', onTap: _showCreateTournament, small: true) : null),
      if (_loading) const Center(child: Padding(padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: AppTheme.cyan))),
      ..._tournaments.map(_buildCard),
      if (!_loading && _tournaments.isEmpty)
        const Padding(padding: EdgeInsets.all(40),
          child: Center(child: Text('No tournaments yet', style: TextStyle(color: AppTheme.muted)))),
    ])),
  );

  Widget _buildCard(Tournament t) => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.panel.withOpacity(0.7), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border)),
    child: Row(children: [
      const Text('🏆', style: TextStyle(fontSize: 24)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.name, style: AppTheme.rajdhani(16, FontWeight.w700)),
        Text('${t.overs} overs • ${t.format.replaceAll('_', ' ')}',
          style: AppTheme.condensed(11, FontWeight.w500, AppTheme.muted)),
        if (t.venue != null) Text(t.venue!, style: AppTheme.condensed(11, FontWeight.w400, AppTheme.muted)),
      ])),
    ]),
  );

  void _showCreateTournament() {
    final name = TextEditingController();
    final overs = TextEditingController(text: '6');
    String format = 'round_robin';
    showModalBottomSheet(context: context, backgroundColor: AppTheme.panel2, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('New Tournament', style: AppTheme.rajdhani(20, FontWeight.w700, AppTheme.cyan)),
          const SizedBox(height: 16),
          InputField(label: 'NAME', hint: 'Ashes Cup 2026', controller: name),
          InputField(label: 'OVERS', hint: '6', controller: overs, keyboardType: TextInputType.number),
          Text('Format', style: AppTheme.condensed(10, FontWeight.w700, AppTheme.cyan.withOpacity(0.8))),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: ['round_robin', 'single_knockout', 'combined'].map((f) =>
            GestureDetector(
              onTap: () => setS(() => format = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: format == f ? AppTheme.cyan.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: format == f ? AppTheme.cyan.withOpacity(0.4) : AppTheme.border)),
                child: Text(f.replaceAll('_', ' '), style: AppTheme.condensed(12, FontWeight.w600,
                  format == f ? AppTheme.cyan : AppTheme.muted))),
            )).toList()),
          const SizedBox(height: 16),
          AppButton.primary(label: 'Create Tournament', width: double.infinity,
            onTap: () async {
              if (name.text.isEmpty) return;
              await FirebaseService.createTournament(Tournament(
                id: '', name: name.text.trim(), format: format,
                overs: int.tryParse(overs.text) ?? 6));
              if (mounted) { Navigator.pop(context); _load(); }
            }),
        ]),
      )),
    );
  }
}

// ── Teams Screen ──────────────────────────────────────────────────────────
class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});
  @override State<TeamsScreen> createState() => _TeamsScreenState();
}
class _TeamsScreenState extends State<TeamsScreen> {
  List<CricketTeam> _teams = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final ts = await FirebaseService.getTeams();
    setState(() { _teams = ts; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: RefreshIndicator(onRefresh: _load, color: AppTheme.cyan, child: ListView(children: [
        SectionHeader(title: 'TEAMS',
          trailing: appState.isOrganizer
            ? AppButton.primary(label: '+ Team', onTap: _showAddTeam, small: true) : null),
        if (_loading) const Center(child: Padding(padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppTheme.cyan))),
        ..._teams.map((t) => _buildTeamCard(t, appState.isOrganizer)),
      ])),
    );
  }

  Widget _buildTeamCard(CricketTeam t, bool canEdit) {
    final pCount = t.players.length;
    final okSquad = pCount >= 11;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Color(int.parse(t.color.replaceAll('#', '0xFF'))).withOpacity(0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
          child: Row(children: [
            Container(width: 4, height: 40, decoration: BoxDecoration(
              color: Color(int.parse(t.color.replaceAll('#', '0xFF'))),
              borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.name, style: AppTheme.rajdhani(17, FontWeight.w700)),
              Text(t.code, style: AppTheme.condensed(11, FontWeight.w600, AppTheme.muted)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: okSquad ? AppTheme.gn.withOpacity(0.15) : AppTheme.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
              child: Text('$pCount/11', style: AppTheme.condensed(11, FontWeight.w700,
                okSquad ? AppTheme.gn2 : AppTheme.red))),
          ]),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 6, runSpacing: 6, children: t.players.map((p) =>
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cyan.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border)),
              child: Text('${p.jerseyNo != null ? '#${p.jerseyNo} ' : ''}${p.name}',
                style: AppTheme.condensed(11, FontWeight.w500)))).toList()),
          if (canEdit) ...[
            const SizedBox(height: 10),
            AppButton.outline(label: '+ Add Player', small: true,
              onTap: () => _showAddPlayer(t.id)),
          ],
        ])),
      ]),
    );
  }

  void _showAddTeam() {
    // Simplified - same pattern as tournament
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Team dialog - coming soon'), backgroundColor: AppTheme.panel));
  }

  void _showAddPlayer(String teamId) {
    final name = TextEditingController();
    final jersey = TextEditingController();
    String role = 'allrounder';
    showModalBottomSheet(context: context, backgroundColor: AppTheme.panel2, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add Player', style: AppTheme.rajdhani(20, FontWeight.w700, AppTheme.cyan)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: InputField(label: 'NAME', hint: 'Player name', controller: name)),
            const SizedBox(width: 10),
            SizedBox(width: 80, child: InputField(label: 'JERSEY', hint: '10', controller: jersey,
              keyboardType: TextInputType.number)),
          ]),
          Wrap(spacing: 8, children: ['batsman', 'bowler', 'allrounder', 'wicketkeeper'].map((r) =>
            GestureDetector(
              onTap: () => setS(() => role = r),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: role == r ? AppTheme.cyan.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: role == r ? AppTheme.cyan.withOpacity(0.4) : AppTheme.border)),
                child: Text(r, style: AppTheme.condensed(12, FontWeight.w600,
                  role == r ? AppTheme.cyan : AppTheme.muted))),
            )).toList()),
          const SizedBox(height: 16),
          AppButton.primary(label: 'Add Player', width: double.infinity,
            onTap: () async {
              if (name.text.isEmpty) return;
              await FirebaseService.addPlayer(Player(
                id: '', name: name.text.trim(), role: role, teamId: teamId,
                jerseyNo: int.tryParse(jersey.text)));
              if (mounted) { Navigator.pop(context); _load(); }
            }),
        ]),
      )),
    );
  }
}

// ── Stats Screen ──────────────────────────────────────────────────────────
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    body: ListView(children: [
      const SectionHeader(title: 'STATISTICS'),
      Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppTheme.panel.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
        child: Column(children: [
          const Text('📊', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('Stats Dashboard', style: AppTheme.rajdhani(18, FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Player and team statistics will appear here after matches are scored.',
            style: AppTheme.condensed(13, FontWeight.w400, AppTheme.muted), textAlign: TextAlign.center),
        ]),
      ),
    ]),
  );
}

// ── Admin Screen ──────────────────────────────────────────────────────────
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isOrganizer) {
      return Scaffold(backgroundColor: AppTheme.bg,
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🔒', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('Admin access required', style: AppTheme.rajdhani(18, FontWeight.w600, AppTheme.muted)),
        ])));
    }
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: ListView(children: [
        const SectionHeader(title: 'ADMIN PANEL'),
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          GlassCard(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('⚙️ System', style: AppTheme.rajdhani(16, FontWeight.w700, AppTheme.cyan)),
            const SizedBox(height: 10),
            Text('Logged in as: ${appState.currentUser?.username ?? '—'} [${appState.currentUser?.role ?? '—'}]',
              style: AppTheme.condensed(13, FontWeight.w500, AppTheme.muted)),
            const SizedBox(height: 10),
            AppButton.red(label: 'Sign Out', width: double.infinity, onTap: appState.logout),
          ])),
          GlassCard(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ℹ️ Database', style: AppTheme.rajdhani(16, FontWeight.w700, AppTheme.cyan)),
            const SizedBox(height: 8),
            Text('Firebase Realtime DB: a7-cricket-default-rtdb',
              style: AppTheme.condensed(12, FontWeight.w400, AppTheme.muted)),
            Text('Auth: Firebase Auth', style: AppTheme.condensed(12, FontWeight.w400, AppTheme.muted)),
          ])),
        ])),
      ]),
    );
  }
}
