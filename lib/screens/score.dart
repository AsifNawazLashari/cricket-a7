import 'package:flutter/material.dart';
import '../theme.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({Key? key}) : super(key: key);

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  // Advanced State Placeholders
  String score = "45";
  String wkts = "1";
  String overs = "4.2";
  String crr = "10.38";

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildHeroHeader(),
        _buildOverStrip(),
        _buildCreaseRow(),
        _buildRunSection(context),
        _buildActionRow(),
      ],
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFA050F1E), Color(0xFD030A14)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KARACHI KINGS VS LAHORE QALANDARS • 20 OV', style: AppTheme.condensed(10)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('KARACHI KINGS', style: AppTheme.condensed(10)),
                    Text('$score/$wkts', style: AppTheme.rajdhani(42, FontWeight.bold, AppTheme.text)),
                    Text('$overs ov • Ex: 4', style: AppTheme.condensed(10)),
                  ],
                ),
              ),
              Container(width: 1, height: 50, color: AppTheme.border),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cyan.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cyan.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(crr, style: AppTheme.rajdhani(22, FontWeight.bold, AppTheme.cyan)),
                      Text('CRR', style: AppTheme.condensed(9)),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOverStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: AppTheme.cyan.withOpacity(0.03),
      child: Row(
        children: [
          Text('OVER 5', style: AppTheme.condensed(10)),
          const SizedBox(width: 12),
          _buildBall('1', AppTheme.cyan, AppTheme.cyan.withOpacity(0.1)),
          _buildBall('0', AppTheme.muted, Colors.transparent),
          _buildBall('4', AppTheme.green, AppTheme.green.withOpacity(0.1)),
          _buildBall('Wd', AppTheme.muted, AppTheme.bg2),
        ],
      ),
    );
  }

  Widget _buildBall(String label, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 32, height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5)), color: bg),
      child: Text(label, style: AppTheme.rajdhani(13, FontWeight.bold, color)),
    );
  }

  Widget _buildCreaseRow() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(child: _buildCreaseCard('⚡ STRIKER', 'Babar Azam', '32 (18)', true)),
          const SizedBox(width: 8),
          Expanded(child: _buildCreaseCard('NON-STRIKER', 'Sharjeel Khan', '12 (9)', false)),
        ],
      ),
    );
  }

  Widget _buildCreaseCard(String label, String name, String stats, bool isStriker) {
    Color borderColor = isStriker ? AppTheme.yellow : AppTheme.cyan;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.05),
        border: Border.all(color: borderColor.withOpacity(0.2)),
        borderLeft: BorderSide(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.condensed(9, FontWeight.bold, AppTheme.muted)),
          const SizedBox(height: 4),
          Text(name, style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.text)),
          Text(stats, style: AppTheme.condensed(11)),
        ],
      ),
    );
  }

  Widget _buildRunSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RECORD DELIVERY', style: AppTheme.condensed(11)),
              // UNDO BUTTON - Critical for pro apps
              GestureDetector(
                onTap: () => print("Undo Last Event"),
                child: Row(
                  children: [
                    Icon(LucideIcons.undo, size: 14, color: AppTheme.yellow),
                    const SizedBox(width: 4),
                    Text('UNDO', style: AppTheme.condensed(11, FontWeight.bold, AppTheme.yellow)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: [
              _buildRunBtn('0', AppTheme.muted),
              _buildRunBtn('1', AppTheme.cyan),
              _buildRunBtn('2', AppTheme.cyan),
              _buildRunBtn('3', AppTheme.cyan),
              _buildRunBtn('4', AppTheme.green),
              _buildRunBtn('6', AppTheme.yellow),
              _buildRunBtn('W', AppTheme.red, onTap: () => _showAdvancedWicketModal(context)),
              _buildRunBtn('5', AppTheme.cyan),
            ],
          ),
          const SizedBox(height: 12),
          Text('EXTRAS (ADVANCED)', style: AppTheme.condensed(11)),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 2.2,
            children: [
              _buildExtraBtn('Wide', () => _showAdvancedExtrasModal(context, 'Wide')),
              _buildExtraBtn('No Ball', () => _showAdvancedExtrasModal(context, 'No Ball')),
              _buildExtraBtn('Bye', () => {}),
              _buildExtraBtn('Leg Bye', () => {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunBtn(String lbl, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => print("Scored $lbl"),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.4), width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
        ),
        alignment: Alignment.center,
        child: Text(lbl, style: AppTheme.rajdhani(24, FontWeight.bold, color)),
      ),
    );
  }

  Widget _buildExtraBtn(String lbl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.cyan.withOpacity(0.04),
          border: Border.all(color: AppTheme.cyan.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(lbl, style: AppTheme.condensed(11, FontWeight.bold, AppTheme.text)),
      ),
    );
  }

  Widget _buildActionRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionBtn('🎳 Bowler', AppTheme.cyan),
          _actionBtn('👤 Next Bat', AppTheme.cyan),
          _actionBtn('🛑 End', AppTheme.red),
        ],
      ),
    );
  }

  Widget _actionBtn(String lbl, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Text(lbl, style: AppTheme.barlow(12, FontWeight.w600, color)),
    );
  }

  // --- ADVANCED CRICKETING LOGIC MODALS ---

  void _showAdvancedExtrasModal(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bg2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$type + Runs Off Bat/Byes', style: AppTheme.rajdhani(20, FontWeight.bold, AppTheme.cyan)),
              const SizedBox(height: 8),
              Text('In local/international cricket, how many runs were taken OFF this $type?', style: AppTheme.condensed(12, FontWeight.w400, AppTheme.muted)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: List.generate(7, (index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.panel, side: BorderSide(color: AppTheme.cyan.withOpacity(0.3))),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('+$index', style: AppTheme.rajdhani(16, FontWeight.bold, AppTheme.text)),
                  );
                }),
              )
            ],
          ),
        );
      }
    );
  }

  void _showAdvancedWicketModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bg2,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WICKET FALLEN', style: AppTheme.rajdhani(22, FontWeight.bold, AppTheme.red)),
              const SizedBox(height: 16),
              Text('HOW OUT?', style: AppTheme.condensed(12, FontWeight.bold, AppTheme.muted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['Bowled', 'Caught', 'LBW', 'Run Out', 'Stumped', 'Hit Wicket'].map((e) {
                  return ChoiceChip(
                    label: Text(e, style: AppTheme.barlow(12, FontWeight.bold)),
                    selected: false,
                    onSelected: (val) {},
                    backgroundColor: AppTheme.panel,
                    side: BorderSide(color: AppTheme.red.withOpacity(0.3)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Advanced Crossing Logic
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Did the batsmen cross?', style: AppTheme.barlow(14, FontWeight.bold, AppTheme.text)),
                  Switch(value: false, onChanged: (v){}, activeColor: AppTheme.yellow),
                ],
              ),
              const SizedBox(height: 10),
              Text('Note: ICC laws state new batter always takes strike for a catch, but local rules may vary.', style: AppTheme.condensed(10, FontWeight.w400, AppTheme.muted)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('CONFIRM WICKET & SELECT BATTER', style: AppTheme.rajdhani(16, FontWeight.bold, Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }
}
