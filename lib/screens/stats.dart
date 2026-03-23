import 'package:flutter/material.dart';
import '../theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.black.withOpacity(0.2),
            child: TabBar(
              indicatorColor: AppTheme.cyan,
              labelColor: AppTheme.cyan,
              unselectedLabelColor: AppTheme.muted,
              labelStyle: AppTheme.condensed(12, FontWeight.bold),
              tabs: const [Tab(text: '🏏 BATTING'), Tab(text: '⚡ BOWLING')],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBattingTable(),
                _buildBowlingTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattingTable() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildStatHeader(['#', 'PLAYER', 'INN', 'RUNS', 'SR', '6s']),
        _buildBatRow('1', 'Babar Azam', 'KAR', '5', '245', '142.5', '8'),
        _buildBatRow('2', 'Fakhar Zaman', 'LAH', '5', '210', '155.0', '12'),
        _buildBatRow('3', 'Mohammad Rizwan', 'MUL', '4', '189', '128.2', '4'),
      ],
    );
  }

  Widget _buildBowlingTable() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildStatHeader(['#', 'PLAYER', 'INN', 'WKTS', 'ECON', 'AVG']),
        _buildBowlRow('1', 'Shaheen Afridi', 'LAH', '5', '12', '6.50', '14.2'),
        _buildBowlRow('2', 'Rashid Khan', 'LAH', '5', '10', '5.80', '16.5'),
        _buildBowlRow('3', 'Haris Rauf', 'LAH', '4', '8', '8.20', '18.0'),
      ],
    );
  }

  Widget _buildStatHeader(List<String> columns) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text(columns[0], style: AppTheme.condensed(10))),
          Expanded(flex: 3, child: Text(columns[1], style: AppTheme.condensed(10))),
          Expanded(child: Text(columns[2], style: AppTheme.condensed(10), textAlign: TextAlign.right)),
          Expanded(child: Text(columns[3], style: AppTheme.condensed(10), textAlign: TextAlign.right)),
          Expanded(child: Text(columns[4], style: AppTheme.condensed(10), textAlign: TextAlign.right)),
          Expanded(child: Text(columns[5], style: AppTheme.condensed(10), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildBatRow(String rank, String name, String team, String inn, String runs, String sr, String sixes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text(rank, style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.yellow))),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.text)),
                Text(team, style: AppTheme.barlow(10, FontWeight.w400, AppTheme.muted)),
              ],
            ),
          ),
          Expanded(child: Text(inn, style: AppTheme.barlow(12), textAlign: TextAlign.right)),
          Expanded(child: Text(runs, style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.cyan), textAlign: TextAlign.right)),
          Expanded(child: Text(sr, style: AppTheme.barlow(12), textAlign: TextAlign.right)),
          Expanded(child: Text(sixes, style: AppTheme.barlow(12), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildBowlRow(String rank, String name, String team, String inn, String wkts, String econ, String avg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text(rank, style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.yellow))),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.text)),
                Text(team, style: AppTheme.barlow(10, FontWeight.w400, AppTheme.muted)),
              ],
            ),
          ),
          Expanded(child: Text(inn, style: AppTheme.barlow(12), textAlign: TextAlign.right)),
          Expanded(child: Text(wkts, style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.cyan), textAlign: TextAlign.right)),
          Expanded(child: Text(econ, style: AppTheme.barlow(12), textAlign: TextAlign.right)),
          Expanded(child: Text(avg, style: AppTheme.barlow(12), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
