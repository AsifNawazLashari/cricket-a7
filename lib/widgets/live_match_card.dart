import 'package:flutter/material.dart';
import '../theme.dart';

class LiveMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final VoidCallback? onTap;

  const LiveMatchCard({Key? key, required this.match, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.cyan.withOpacity(0.3)),
          boxShadow: AppTheme.glowCyanSm,
        ),
        child: Column(
          children: [
            // Badge Row
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.red.withOpacity(0.15),
                      border: Border.all(color: AppTheme.red.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(color: AppTheme.red, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text('LIVE', style: AppTheme.condensed(10, FontWeight.bold, AppTheme.red)),
                      ],
                    ),
                  ),
                  Text('${match['tournament']} • ${match['stage']}', style: AppTheme.condensed(11)),
                ],
              ),
            ),
            
            // Teams & Score Row
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: Row(
                children: [
                  // Team 1
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFlag(match['t1_code']),
                        const SizedBox(height: 4),
                        Text(match['t1_name'], style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.text), overflow: TextOverflow.ellipsis),
                        Text(match['t1_code'], style: AppTheme.barlow(10, FontWeight.w400, AppTheme.muted)),
                      ],
                    ),
                  ),
                  
                  // Score Center
                  Column(
                    children: [
                      Text(match['score'] ?? '--/--', style: AppTheme.rajdhani(36, FontWeight.bold, AppTheme.cyan)),
                      Text('${match['overs']} ov', style: AppTheme.barlow(12, FontWeight.w400, AppTheme.muted)),
                      const SizedBox(height: 2),
                      Text('${match['batting_team']} batting', style: AppTheme.condensed(11)),
                    ],
                  ),
                  
                  // Team 2
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildFlag(match['t2_code']),
                        const SizedBox(height: 4),
                        Text(match['t2_name'], style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.text), overflow: TextOverflow.ellipsis),
                        Text(match['t2_code'], style: AppTheme.barlow(10, FontWeight.w400, AppTheme.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Strip
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  _buildStatItem('CRR', match['crr'] ?? '0.00', AppTheme.green),
                  _buildStatItem(match['target'] != null ? 'TARGET' : 'OVERS', match['target'] ?? match['max_overs'], AppTheme.yellow),
                  _buildStatItem('WKTS LEFT', match['wkts_left'] ?? '10', AppTheme.text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag(String code) {
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: AppTheme.panel,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.cyan.withOpacity(0.25), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      alignment: Alignment.center,
      child: Text(code.substring(0, 1), style: AppTheme.rajdhani(20, FontWeight.bold, AppTheme.cyan)),
    );
  }

  Widget _buildStatItem(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppTheme.border)),
        ),
        child: Column(
          children: [
            Text(val, style: AppTheme.rajdhani(18, FontWeight.bold, color)),
            const SizedBox(height: 2),
            Text(label, style: AppTheme.condensed(9)),
          ],
        ),
      ),
    );
  }
}
