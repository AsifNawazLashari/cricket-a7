import 'package:flutter/material.dart';
import '../theme.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.black.withOpacity(0.2),
            child: TabBar(
              indicatorColor: AppTheme.cyan,
              indicatorWeight: 2,
              labelColor: AppTheme.cyan,
              unselectedLabelColor: AppTheme.muted,
              labelStyle: AppTheme.condensed(12, FontWeight.bold),
              tabs: const [
                Tab(text: 'FIXTURES'),
                Tab(text: 'BRACKET'),
                Tab(text: 'POINTS'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFixturesTab(),
                _buildBracketTab(),
                _buildPointsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixturesTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildTournamentHeader('ASHES CUP 2025', 'T20 • 20 OVERS • 12/24 PLAYED'),
        _buildFixtureRow('KAR', 'LAH', 'GROUP STAGE', 'LIVE', AppTheme.red),
        _buildFixtureRow('PES', 'ISL', 'GROUP STAGE', 'SOON', AppTheme.muted),
        _buildFixtureRow('MUL', 'QUE', 'GROUP STAGE', 'DONE', AppTheme.green, result: 'MUL won by 4 wkts'),
      ],
    );
  }

  Widget _buildTournamentHeader(String title, String meta) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.panel.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.cyan)),
              Text(meta, style: AppTheme.condensed(10)),
            ],
          ),
          Icon(Icons.bolt, color: AppTheme.muted, size: 18),
        ],
      ),
    );
  }

  Widget _buildFixtureRow(String t1, String t2, String stage, String status, Color statusColor, {String? result}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glassCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(t1, style: AppTheme.rajdhani(18, FontWeight.bold, AppTheme.text)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('vs', style: AppTheme.barlow(12, FontWeight.w400, AppTheme.muted)),
                    ),
                    Text(t2, style: AppTheme.rajdhani(18, FontWeight.bold, AppTheme.text)),
                  ],
                ),
                if (result != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(result, style: AppTheme.barlow(10, FontWeight.w600, AppTheme.green)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('22/22 players registered', style: AppTheme.condensed(10)),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              border: Border.all(color: statusColor.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status, style: AppTheme.condensed(10, FontWeight.bold, statusColor)),
          )
        ],
      ),
    );
  }

  Widget _buildBracketTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_tree_outlined, size: 48, color: AppTheme.muted),
          const SizedBox(height: 12),
          Text('Knockout Bracket Generation', style: AppTheme.rajdhani(18, FontWeight.bold, AppTheme.muted)),
          Text('Available at end of Group Stage', style: AppTheme.barlow(12, FontWeight.w400, AppTheme.muted)),
        ],
      ),
    );
  }

  Widget _buildPointsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('ASHES CUP 2025', style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.green)),
        const Divider(color: AppTheme.border),
        _buildPtsHeader(),
        _buildPtsRow(1, 'KAR', 5, 4, 1, 8, '+1.240', true),
        _buildPtsRow(2, 'LAH', 5, 3, 2, 6, '+0.850', true),
        _buildPtsRow(3, 'ISL', 5, 2, 3, 4, '-0.120', false),
        _buildPtsRow(4, 'PES', 5, 1, 4, 2, '-1.940', false),
      ],
    );
  }

  Widget _buildPtsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('#', style: AppTheme.condensed(10))),
          Expanded(flex: 3, child: Text('TEAM', style: AppTheme.condensed(10))),
          Expanded(child: Text('P', style: AppTheme.condensed(10))),
          Expanded(child: Text('W', style: AppTheme.condensed(10))),
          Expanded(child: Text('L', style: AppTheme.condensed(10))),
          Expanded(child: Text('PTS', style: AppTheme.condensed(10))),
          Expanded(flex: 2, child: Text('NRR', style: AppTheme.condensed(10), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildPtsRow(int rank, String team, int p, int w, int l, int pts, String nrr, bool qualified) {
    return Container(
      color: qualified ? AppTheme.green.withOpacity(0.08) : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('$rank', style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.yellow))),
          Expanded(flex: 3, child: Text(team, style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.text))),
          Expanded(child: Text('$p', style: AppTheme.barlow(12))),
          Expanded(child: Text('$w', style: AppTheme.barlow(12))),
          Expanded(child: Text('$l', style: AppTheme.barlow(12))),
          Expanded(child: Text('$pts', style: AppTheme.rajdhani(14, FontWeight.bold, AppTheme.green))),
          Expanded(
            flex: 2,
            child: Text(
              nrr,
              style: AppTheme.barlow(12, FontWeight.bold, nrr.startsWith('-') ? AppTheme.red : AppTheme.green),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
