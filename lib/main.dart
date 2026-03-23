import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'api_service.dart';

// Import screens (We will create these next)
import 'screens/home.dart';
import 'screens/tournaments.dart';
import 'screens/teams.dart';
import 'screens/score.dart';
import 'screens/stats.dart';
import 'screens/admin.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const AshesCricketApp(),
    ),
  );
}

class AshesCricketApp extends StatelessWidget {
  const AshesCricketApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ashes Cricket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.bg,
        primaryColor: AppTheme.cyan,
        colorScheme: const ColorScheme.dark(
          primary: AppTheme.cyan,
          secondary: AppTheme.yellow,
          background: AppTheme.bg,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const TournamentsScreen(),
    const TeamsScreen(),
    const ScoreScreen(),
    const StatsScreen(),
    const AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDev = appState.hasRole(['developer']);
    final canScore = appState.hasRole(['developer', 'organizer', 'captain']);

    // Build Nav Items dynamically based on roles
    List<BottomNavigationBarItem> navItems = [
      _buildNavItem(LucideIcons.home, 'HOME'),
      _buildNavItem(LucideIcons.calendar, 'FIXTURES'),
      _buildNavItem(LucideIcons.users, 'TEAMS'),
      if (canScore) _buildNavItem(LucideIcons.target, 'SCORE'),
      _buildNavItem(LucideIcons.barChart2, 'STATS'),
      if (isDev) _buildNavItem(LucideIcons.settings, 'ADMIN'),
    ];

    // Filter pages array to match nav items length
    List<Widget> activePages = [
      _pages[0],
      _pages[1],
      _pages[2],
      if (canScore) _pages[3],
      _pages[4],
      if (isDev) _pages[5],
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bg.withOpacity(0.95),
            border: const Border(bottom: BorderSide(color: AppTheme.border)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🏏', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text('ASHES CRICKET', style: AppTheme.rajdhani(20)),
                    ],
                  ),
                  appState.user != null
                      ? GestureDetector(
                          onTap: () => appState.logout(),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.cyan.withOpacity(0.1),
                            child: Text(
                              appState.user!['username'].substring(0, 2).toUpperCase(),
                              style: AppTheme.rajdhani(14),
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: () => _showAuthModal(context),
                          style: TextButton.styleFrom(
                            side: const BorderSide(color: AppTheme.cyan),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('SIGN IN', style: AppTheme.condensed(12, FontWeight.bold, AppTheme.cyan)),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
      body: activePages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.bg2,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: AppTheme.cyan,
          unselectedItemColor: AppTheme.muted,
          selectedLabelStyle: AppTheme.condensed(10, FontWeight.bold, AppTheme.cyan),
          unselectedLabelStyle: AppTheme.condensed(10, FontWeight.bold, AppTheme.muted),
          onTap: (index) => setState(() => _currentIndex = index),
          items: navItems,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Icon(icon, size: 22),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Icon(icon, size: 24, color: AppTheme.cyan, shadows: AppTheme.glowCyanSm),
      ),
      label: label,
    );
  }

  void _showAuthModal(BuildContext context) {
    // Auth Modal implementation to go here (BottomSheet)
  }
}
