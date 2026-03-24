import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'score_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CricketMatch> _liveMatches = [];
  List<CricketMatch> _recentMatches = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final matches = await FirebaseService.getMatches();
    setState(() {
      _liveMatches = matches.where((m) => m.status == 'live').toList();
      _recentMatches = matches.where((m) => m.status == 'completed').take(5).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return RefreshIndicator(
      onRefresh: _load, color: AppTheme.cyan,
      child: ListView(children: [
        _buildHero(appState),
        if (_loading) const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator(color: AppTheme.cyan))),
        if (!_loading) ...[
          if (_liveMatches.isNotEmpty) ...[
            const SectionHeader(title: 'LIVE MATCHES'),
            ..._liveMatches.map(_buildLiveCard),
          ],
          const SectionHeader(title: 'RECENT RESULTS'),
          if (_recentMatches.isEmpty)
            const _EmptyState(icon: '🏏', title: 'No matches yet', desc: 'Create a tournament to get started'),
          ..._recentMatches.map(_buildResultCard),
        ],
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildHero(AppState appState) => Container(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
    decoration: BoxDecoration(
      gradient: AppTheme.heroBg,
      border: Border(bottom: BorderSide(color: AppTheme.border)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('🏆', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CRICKET A7', style: AppTheme.rajdhani(22, FontWeight.w700, AppTheme.cyan)
            .copyWith(letterSpacing: 2, shadows: [Shadow(color: AppTheme.cyan.withOpacity(0.4), blurRadius: 12)])),
          Text('LIVE SCORING PLATFORM', style: AppTheme.condensed(9, FontWeight.w600, AppTheme.muted)
            .copyWith(letterSpacing: 2)),
        ]),
      ]),
      const SizedBox(height: 14),
      if (!appState.isLoggedIn) ...[
        Text('Sign in to score matches and manage teams',
          style: AppTheme.barlow(13, FontWeight.w400, AppTheme.muted)),
        const SizedBox(height: 10),
        Row(children: [
          AppButton.primary(label: 'Sign In', onTap: () => _showAuth(context), small: true),
          const SizedBox(width: 8),
          AppButton.outline(label: 'Register', onTap: () => _showAuth(context, register: true), small: true),
        ]),
      ] else ...[
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(
            color: _roleColor(appState.currentUser!.role), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(appState.currentUser!.username, style: AppTheme.rajdhani(16, FontWeight.w700)),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppTheme.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cyan.withOpacity(0.3))),
            child: Text(appState.currentUser!.role.toUpperCase(),
              style: AppTheme.condensed(9, FontWeight.w700, AppTheme.cyan))),
          const Spacer(),
          AppButton.outline(label: 'Sign Out', onTap: appState.logout, small: true),
        ]),
      ],
    ]),
  );

  Color _roleColor(String role) => const {
    'developer': Color(0xFFFF4757), 'organizer': Color(0xFFFFD93D),
    'captain': Color(0xFF00FF88),
  }[role] ?? AppTheme.muted;

  Widget _buildLiveCard(CricketMatch m) => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
    decoration: BoxDecoration(
      gradient: AppTheme.cardGrad,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.cyan.withOpacity(0.25)),
      boxShadow: [BoxShadow(color: AppTheme.cyan.withOpacity(0.1), blurRadius: 20)],
    ),
    child: Column(children: [
      // Animated top line
      Container(height: 2, decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.transparent, AppTheme.cyan, Colors.transparent]),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)))),
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const LiveBadge(),
          Text(m.tournamentName ?? 'Match', style: AppTheme.condensed(11, FontWeight.w500, AppTheme.muted)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Text(m.team1Name, style: AppTheme.rajdhani(18, FontWeight.w700), overflow: TextOverflow.ellipsis)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('vs', style: AppTheme.condensed(13, FontWeight.w500, AppTheme.muted))),
          Expanded(child: Text(m.team2Name, style: AppTheme.rajdhani(18, FontWeight.w700), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 12),
        AppButton.primary(label: '🎯 Watch Live', onTap: () => _openMatch(m), width: double.infinity),
      ])),
    ]),
  );

  Widget _buildResultCard(CricketMatch m) => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.panel.withOpacity(0.6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('${m.team1Name} vs ${m.team2Name}',
          style: AppTheme.rajdhani(15, FontWeight.w700), overflow: TextOverflow.ellipsis)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppTheme.gn.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10)),
          child: Text('DONE', style: AppTheme.condensed(9, FontWeight.w700, AppTheme.gn))),
      ]),
      if (m.resultDesc != null) ...[
        const SizedBox(height: 4),
        Text('🏆 ${m.resultDesc}', style: AppTheme.condensed(12, FontWeight.w500, AppTheme.gn2)),
      ],
    ]),
  );

  void _openMatch(CricketMatch m) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ScoreScreen(matchId: m.id)));
  }

  void _showAuth(BuildContext context, {bool register = false}) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      backgroundColor: AppTheme.panel2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AuthSheet(register: register));
  }
}

class _EmptyState extends StatelessWidget {
  final String icon, title, desc;
  const _EmptyState({required this.icon, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 12),
      Text(title, style: AppTheme.rajdhani(18, FontWeight.w700, AppTheme.muted)),
      const SizedBox(height: 6),
      Text(desc, style: AppTheme.condensed(13, FontWeight.w400, AppTheme.muted), textAlign: TextAlign.center),
    ]),
  );
}

class _AuthSheet extends StatefulWidget {
  final bool register;
  const _AuthSheet({this.register = false});
  @override State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  late bool _isRegister;
  final _user = TextEditingController();
  final _pass = TextEditingController();
  String _role = 'viewer';

  @override void initState() { super.initState(); _isRegister = widget.register; }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(
          color: AppTheme.muted.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text('🏏 Cricket A7', style: AppTheme.rajdhani(20, FontWeight.w700, AppTheme.cyan)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _isRegister = false),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                  color: !_isRegister ? AppTheme.cyan : Colors.transparent, width: 2))),
              child: Text('Sign In', textAlign: TextAlign.center,
                style: AppTheme.condensed(14, FontWeight.w700,
                  !_isRegister ? AppTheme.cyan : AppTheme.muted))),
          )),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _isRegister = true),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                  color: _isRegister ? AppTheme.cyan : Colors.transparent, width: 2))),
              child: Text('Register', textAlign: TextAlign.center,
                style: AppTheme.condensed(14, FontWeight.w700,
                  _isRegister ? AppTheme.cyan : AppTheme.muted))),
          )),
        ]),
        const SizedBox(height: 16),
        InputField(label: 'USERNAME', hint: 'your username', controller: _user),
        InputField(label: 'PASSWORD', hint: '••••••••', controller: _pass, obscure: true),
        if (_isRegister) ...[
          Text('Role', style: AppTheme.condensed(10, FontWeight.w700, AppTheme.cyan.withOpacity(0.8))),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: ['viewer', 'captain', 'organizer'].map((r) =>
            GestureDetector(
              onTap: () => setState(() => _role = r),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _role == r ? AppTheme.cyan.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _role == r ? AppTheme.cyan.withOpacity(0.4) : AppTheme.border),
                ),
                child: Text(r.toUpperCase(), style: AppTheme.condensed(12, FontWeight.w600,
                  _role == r ? AppTheme.cyan : AppTheme.muted)),
              ),
            )).toList()),
          const SizedBox(height: 12),
        ],
        if (appState.error != null) ...[
          Text(appState.error!, style: AppTheme.condensed(13, FontWeight.w600, AppTheme.red)),
          const SizedBox(height: 8),
        ],
        AppButton(
          label: _isRegister ? 'Create Account' : 'Sign In',
          onTap: _submit, gradient: AppTheme.primaryGrad,
          textColor: Colors.white, width: double.infinity, isLoading: appState.isLoading,
        ),
      ]),
    );
  }

  Future<void> _submit() async {
    final appState = context.read<AppState>();
    String? err;
    if (_isRegister) {
      err = await appState.register(_user.text.trim(), _pass.text, _role);
    } else {
      err = await appState.login(_user.text.trim(), _pass.text);
    }
    if (err == null && mounted) Navigator.pop(context);
  }
}
