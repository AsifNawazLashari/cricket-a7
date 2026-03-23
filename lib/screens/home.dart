import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/live_match_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Data for UI demonstration
    final mockLiveMatch = {
      'tournament': 'ASHES CUP 2025',
      'stage': 'GROUP STAGE',
      't1_name': 'Karachi Kings', 't1_code': 'KAR',
      't2_name': 'Lahore Qalandars', 't2_code': 'LAH',
      'score': '145/4',
      'overs': '16.2',
      'batting_team': 'KAR',
      'crr': '8.92', 'max_overs': '20', 'wkts_left': '6'
    };

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
          child: Text('LIVE CRICKET SCORES', style: AppTheme.condensed(12), textAlign: TextAlign.center),
        ),
        
        _buildSectionTitle('🔴 MATCH CENTER'),
        LiveMatchCard(match: mockLiveMatch),

        _buildSectionTitle('📅 UPCOMING'),
        _buildUpcomingTile('Islamabad United', 'Peshawar Zalmi', 'Tomorrow, 8:00 PM'),
        _buildUpcomingTile('Quetta Gladiators', 'Multan Sultans', 'Saturday, 4:00 PM'),
        
        _buildSectionTitle('✅ RESULTS'),
        _buildResultTile('Lahore Qalandars', 'Multan Sultans', 'LAH won by 4 wickets'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      child: Row(
        children: [
          Container(width: 3, height: 12, color: AppTheme.cyan, margin: const EdgeInsets.only(right: 6)),
          Text(title, style: AppTheme.condensed(14)),
        ],
      ),
    );
  }

  Widget _buildUpcomingTile(String t1, String t2, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glassCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(t1, style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.text))),
          Text(' VS ', style: AppTheme.condensed(12, FontWeight.bold, AppTheme.muted)),
          Expanded(child: Text(t2, style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.text), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildResultTile(String t1, String t2, String result) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t1, style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.text)),
              Text(' VS ', style: AppTheme.condensed(12, FontWeight.bold, AppTheme.muted)),
              Text(t2, style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.text)),
            ],
          ),
          const SizedBox(height: 8),
          Text('🏆 $result', style: AppTheme.condensed(13, FontWeight.bold, AppTheme.green)),
        ],
      ),
    );
  }
}
