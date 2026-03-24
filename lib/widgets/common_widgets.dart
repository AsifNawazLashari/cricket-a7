import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ── GlassCard ─────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color? borderColor;

  const GlassCard({super.key, required this.child, this.padding, this.radius = 18, this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppTheme.panel.withOpacity(0.75),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppTheme.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
    ),
    child: padding != null ? Padding(padding: padding!, child: child) : child,
  );
}

// ── SectionHeader ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Row(children: [
      Container(width: 3, height: 12, decoration: BoxDecoration(
        color: AppTheme.cyan, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: AppTheme.condensed(11, FontWeight.w700, AppTheme.muted)),
      const Spacer(),
      if (trailing != null) trailing!,
    ]),
  );
}

// ── AppButton ─────────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color, textColor, borderColor;
  final double? width;
  final bool small, isLoading;
  final Widget? icon;

  const AppButton({
    super.key, required this.label, this.onTap,
    this.gradient, this.color, this.textColor, this.borderColor,
    this.width, this.small = false, this.isLoading = false, this.icon,
  });

  factory AppButton.primary({required String label, VoidCallback? onTap, double? width, bool small = false, Widget? icon}) =>
    AppButton(label: label, onTap: onTap, gradient: AppTheme.primaryGrad,
      textColor: Colors.white, width: width, small: small, icon: icon);

  factory AppButton.gold({required String label, VoidCallback? onTap, double? width, bool small = false}) =>
    AppButton(label: label, onTap: onTap, gradient: AppTheme.goldGrad,
      textColor: AppTheme.bg, width: width, small: small);

  factory AppButton.red({required String label, VoidCallback? onTap, double? width, bool small = false}) =>
    AppButton(label: label, onTap: onTap, gradient: AppTheme.redGrad,
      textColor: Colors.white, width: width, small: small);

  factory AppButton.outline({required String label, VoidCallback? onTap, double? width, bool small = false}) =>
    AppButton(label: label, onTap: onTap, color: Colors.transparent,
      borderColor: AppTheme.border, textColor: AppTheme.text, width: width, small: small);

  @override
  Widget build(BuildContext context) {
    final h = small ? 34.0 : 44.0;
    final fs = small ? 12.0 : 14.0;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width, height: h,
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? (color ?? AppTheme.panel) : null,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: gradient != null ? [BoxShadow(
            color: (gradient!.colors.first).withOpacity(0.3), blurRadius: 12, offset: const Offset(0,3))] : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[icon!, const SizedBox(width: 6)],
          if (isLoading)
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          else
            Text(label, style: AppTheme.condensed(fs, FontWeight.w700, textColor ?? AppTheme.text)),
        ]),
      ),
    );
  }
}

// ── LiveBadge ─────────────────────────────────────────────────────────────
class LiveBadge extends StatefulWidget {
  const LiveBadge({super.key});
  @override State<LiveBadge> createState() => _LiveBadgeState();
}
class _LiveBadgeState extends State<LiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.red.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.red.withOpacity(0.4)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(animation: _c, builder: (_,__) => Container(
        width: 7, height: 7, decoration: BoxDecoration(
          color: AppTheme.red.withOpacity(0.2 + _c.value * 0.8),
          shape: BoxShape.circle,
        ),
      )),
      const SizedBox(width: 6),
      Text('LIVE', style: AppTheme.condensed(10, FontWeight.w700, AppTheme.red)),
    ]),
  );
}

// ── BallDot ───────────────────────────────────────────────────────────────
class BallDot extends StatelessWidget {
  final BallEvent ball;
  final double size;
  const BallDot({super.key, required this.ball, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.ballColor(ball.type, ball.runs);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
        color: color.withOpacity(0.15),
      ),
      alignment: Alignment.center,
      child: Text(ball.label, style: AppTheme.rajdhani(size * 0.38, FontWeight.w700, color)),
    );
  }
}

// ── OverStrip ─────────────────────────────────────────────────────────────
class OverStrip extends StatelessWidget {
  final List<BallEvent> balls;
  const OverStrip({super.key, required this.balls});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: AppTheme.panel2,
    child: Row(children: [
      Text('This over: ', style: AppTheme.condensed(11, FontWeight.w500, AppTheme.muted)),
      ...balls.map((b) => Padding(
        padding: const EdgeInsets.only(right: 4),
        child: BallDot(ball: b, size: 26),
      )),
      if (balls.isEmpty) Text('—', style: AppTheme.condensed(11, FontWeight.w500, AppTheme.muted)),
    ]),
  );
}

// ── StatsRow ──────────────────────────────────────────────────────────────
class StatsRow extends StatelessWidget {
  final List<({String label, String value, Color? color})> items;
  const StatsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
    child: Row(children: items.asMap().entries.map((e) {
      final i = e.key; final item = e.value;
      return Expanded(child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(border: Border(
          right: i < items.length - 1 ? BorderSide(color: AppTheme.border) : BorderSide.none,
        )),
        child: Column(children: [
          Text(item.value, style: AppTheme.rajdhani(17, FontWeight.w700, item.color ?? AppTheme.text)),
          const SizedBox(height: 2),
          Text(item.label, style: AppTheme.condensed(9, FontWeight.w500, AppTheme.muted)),
        ]),
      ));
    }).toList()),
  );
}

// ── BatterRow (scorecard) ─────────────────────────────────────────────────
class BatterRow extends StatelessWidget {
  final BatterStat stat;
  final bool isStriker;
  const BatterRow({super.key, required this.stat, this.isStriker = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: isStriker ? AppTheme.yellow.withOpacity(0.04) : Colors.transparent,
      border: Border(bottom: BorderSide(color: AppTheme.border.withOpacity(0.5))),
    ),
    child: Row(children: [
      if (isStriker)
        Padding(padding: const EdgeInsets.only(right: 4),
          child: Text('⚡', style: TextStyle(fontSize: 11)))
      else
        const SizedBox(width: 18),
      Expanded(child: Text(stat.playerName,
        style: AppTheme.barlow(13, isStriker ? FontWeight.w700 : FontWeight.w500,
          stat.isOut ? AppTheme.muted : AppTheme.text),
        overflow: TextOverflow.ellipsis)),
      if (stat.isRetiredHurt)
        Text(' ret hurt', style: AppTheme.condensed(9, FontWeight.w500, AppTheme.yellow)),
      if (stat.isOut && stat.dismissalType != null)
        Padding(padding: const EdgeInsets.only(right: 8),
          child: Text(_shortDismissal(stat), style: AppTheme.condensed(9, FontWeight.w400, AppTheme.muted), overflow: TextOverflow.ellipsis)),
      _mono(stat.runs.toString(), AppTheme.cyan, bold: true),
      const SizedBox(width: 2),
      _mono('(${stat.balls})', AppTheme.muted),
      const SizedBox(width: 8),
      _mono(stat.fours.toString(), AppTheme.green),
      const SizedBox(width: 8),
      _mono(stat.sixes.toString(), AppTheme.yellow),
      const SizedBox(width: 8),
      _mono(stat.sr.toStringAsFixed(1), AppTheme.muted),
    ]),
  );

  String _shortDismissal(BatterStat s) {
    final dt = s.dismissalType ?? '';
    if (dt == 'bowled') return 'b';
    if (dt == 'caught') return 'c';
    if (dt == 'lbw') return 'lbw';
    if (dt == 'stumped') return 'st';
    if (dt == 'runout') return 'run out';
    if (dt == 'hitwicket') return 'hw';
    return dt;
  }

  Widget _mono(String s, Color c, {bool bold = false}) =>
    SizedBox(width: 36, child: Text(s, textAlign: TextAlign.right,
      style: AppTheme.rajdhani(13, bold ? FontWeight.w700 : FontWeight.w500, c)));
}

// ── BowlerRow ─────────────────────────────────────────────────────────────
class BowlerRow extends StatelessWidget {
  final BowlerStat stat;
  final bool isActive;
  const BowlerRow({super.key, required this.stat, this.isActive = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: isActive ? AppTheme.cyan.withOpacity(0.04) : Colors.transparent,
      border: Border(bottom: BorderSide(color: AppTheme.border.withOpacity(0.5))),
    ),
    child: Row(children: [
      if (isActive)
        Padding(padding: const EdgeInsets.only(right: 4),
          child: Text('🎳', style: const TextStyle(fontSize: 11)))
      else
        const SizedBox(width: 18),
      Expanded(child: Text(stat.playerName,
        style: AppTheme.barlow(13, isActive ? FontWeight.w700 : FontWeight.w500))),
      _mono(stat.overStr, AppTheme.muted),
      const SizedBox(width: 8),
      _mono(stat.runs.toString(), AppTheme.text),
      const SizedBox(width: 8),
      _mono(stat.wickets.toString(), AppTheme.red, bold: true),
      const SizedBox(width: 8),
      _mono(stat.maidens.toString(), AppTheme.green),
      const SizedBox(width: 8),
      _mono(stat.econ.toStringAsFixed(2), AppTheme.muted),
    ]),
  );

  Widget _mono(String s, Color c, {bool bold = false}) =>
    SizedBox(width: 36, child: Text(s, textAlign: TextAlign.right,
      style: AppTheme.rajdhani(13, bold ? FontWeight.w700 : FontWeight.w500, c)));
}

// ── PartnershipBar ────────────────────────────────────────────────────────
class PartnershipBar extends StatelessWidget {
  final int runs, balls;
  const PartnershipBar({super.key, required this.runs, required this.balls});

  @override
  Widget build(BuildContext context) {
    final sr = balls > 0 ? (runs / balls * 100).toStringAsFixed(1) : '0.0';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cyan.withOpacity(0.15)),
      ),
      child: Row(children: [
        Text('🤝 Partnership', style: AppTheme.condensed(11, FontWeight.w600, AppTheme.muted)),
        const Spacer(),
        Text('$runs runs', style: AppTheme.rajdhani(15, FontWeight.w700, AppTheme.cyan)),
        const SizedBox(width: 8),
        Text('($balls balls)', style: AppTheme.condensed(11, FontWeight.w500, AppTheme.muted)),
        const SizedBox(width: 8),
        Text('SR: $sr', style: AppTheme.condensed(11, FontWeight.w500, AppTheme.yellow)),
      ]),
    );
  }
}

// ── InputField ────────────────────────────────────────────────────────────
class InputField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;

  const InputField({
    super.key, required this.label, required this.hint,
    required this.controller, this.obscure = false, this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTheme.condensed(10, FontWeight.w700, AppTheme.cyan.withOpacity(0.8))),
      const SizedBox(height: 5),
      TextField(
        controller: controller, obscureText: obscure, keyboardType: keyboardType,
        style: AppTheme.barlow(14, FontWeight.w400),
        decoration: InputDecoration(
          hintText: hint, hintStyle: AppTheme.barlow(14, FontWeight.w400, AppTheme.muted),
          filled: true, fillColor: AppTheme.cyan.withOpacity(0.04),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.cyan.withOpacity(0.4)),
          ),
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}

// ── FreehitBanner ─────────────────────────────────────────────────────────
class FreeHitBanner extends StatelessWidget {
  const FreeHitBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [AppTheme.orange.withOpacity(0.2), AppTheme.yellow.withOpacity(0.1)]),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.orange.withOpacity(0.5)),
    ),
    child: Row(children: [
      const Text('🔓', style: TextStyle(fontSize: 16)),
      const SizedBox(width: 8),
      Text('FREE HIT — No dismissal except Run Out',
        style: AppTheme.condensed(12, FontWeight.w700, AppTheme.orange)),
    ]),
  );
}

// ── PowerplayBanner ───────────────────────────────────────────────────────
class PowerplayBanner extends StatelessWidget {
  const PowerplayBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [AppTheme.cyan.withOpacity(0.15), AppTheme.cyan2.withOpacity(0.05)]),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.cyan.withOpacity(0.4)),
    ),
    child: Row(children: [
      const Text('⚡', style: TextStyle(fontSize: 16)),
      const SizedBox(width: 8),
      Text('POWERPLAY — Field restrictions in effect',
        style: AppTheme.condensed(12, FontWeight.w700, AppTheme.cyan)),
    ]),
  );
}
