import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/tournaments_screen.dart';
import 'screens/teams_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const CricketA7App(),
    ),
  );
}

class CricketA7App extends StatelessWidget {
  const CricketA7App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Cricket A7',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: const MainShell(),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  final _pages = const [
    HomeScreen(),
    TournamentsScreen(),
    TeamsScreen(),
    StatsScreen(),
    AdminScreen(),
  ];

  final _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: 'Fixtures'),
    _NavItem(icon: Icons.groups_outlined, activeIcon: Icons.groups, label: 'Teams'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Stats'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Admin'),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(child: IndexedStack(index: _tab, children: _pages)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bg2.withOpacity(0.95),
          border: Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Row(
            children: _navItems.asMap().entries.where((e) {
              // Hide Admin tab unless developer/organizer
              if (e.key == 4 && !appState.isOrganizer) return false;
              return true;
            }).map((e) {
              final i = e.key; final item = e.value;
              final active = _tab == i;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.cyan.withOpacity(0.06) : Colors.transparent,
                    border: Border(top: BorderSide(
                      color: active ? AppTheme.cyan : Colors.transparent, width: 2)),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(active ? item.activeIcon : item.icon,
                      color: active ? AppTheme.cyan : AppTheme.muted, size: 22),
                    const SizedBox(height: 3),
                    Text(item.label, style: AppTheme.condensed(9, FontWeight.w600,
                      active ? AppTheme.cyan : AppTheme.muted)),
                  ]),
                ),
              ));
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
