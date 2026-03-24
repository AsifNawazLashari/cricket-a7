import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from HTML :root vars
  static const Color bg       = Color(0xFF07111F);
  static const Color bg2      = Color(0xFF0B1A2E);
  static const Color panel    = Color(0xFF0E2040);
  static const Color panel2   = Color(0xFF0A1930);
  static const Color cyan     = Color(0xFF00D4FF);
  static const Color cyan2    = Color(0xFF00A8CC);
  static const Color green    = Color(0xFF00FF88);
  static const Color yellow   = Color(0xFFFFD93D);
  static const Color red      = Color(0xFFFF4757);
  static const Color orange   = Color(0xFFFF8C00);
  static const Color text     = Color(0xFFE8F4FF);
  static const Color muted    = Color(0xFF6B8AAA);
  static const Color gn       = Color(0xFF00A860);
  static const Color gn2      = Color(0xFF00CC74);

  static const Color border   = Color(0x26004FFF); // rgba(0,180,255,.15)
  static const Color border2  = Color(0x14004FFF); // rgba(0,180,255,.08)

  // Gradients
  static const LinearGradient primaryGrad = LinearGradient(
    colors: [Color(0xFF0080CC), Color(0xFF0060AA)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient goldGrad = LinearGradient(
    colors: [Color(0xFFFFD93D), Color(0xFFCC9900)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient redGrad = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFCC2233)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient cardGrad = LinearGradient(
    colors: [Color(0xFF0D2040), Color(0xFF091828)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient heroBg = LinearGradient(
    colors: [Color(0xFF0A1930), Color(0xFF07111F)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  // Text styles
  static TextStyle rajdhani(double size, FontWeight w, [Color? c]) =>
      GoogleFonts.rajdhani(fontSize: size, fontWeight: w, color: c ?? text);

  static TextStyle barlow(double size, FontWeight w, [Color? c]) =>
      GoogleFonts.barlow(fontSize: size, fontWeight: w, color: c ?? text);

  static TextStyle condensed(double size, [FontWeight? w, Color? c]) =>
      GoogleFonts.barlowCondensed(
        fontSize: size, fontWeight: w ?? FontWeight.w500, color: c ?? text,
        letterSpacing: 0.6,
      );

  // ThemeData
  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: bg,
    primaryColor: cyan,
    colorScheme: const ColorScheme.dark(
      primary: cyan, secondary: yellow, surface: panel,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg2, foregroundColor: text,
      titleTextStyle: rajdhani(18, FontWeight.w700, cyan),
      elevation: 0,
    ),
    textTheme: GoogleFonts.barlowTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: text, displayColor: text),
    dividerColor: border,
    cardColor: panel,
  );

  // Ball color helpers
  static Color ballColor(String type, int runs) {
    if (type == 'wicket') return red;
    if (type == 'wide' || type == 'noball') return orange;
    if (runs == 6) return yellow;
    if (runs == 4) return green;
    if (runs == 0) return muted;
    return cyan;
  }

  static String ballLabel(String type, int runs) {
    if (type == 'wicket') return 'W';
    if (type == 'wide') return 'Wd';
    if (type == 'noball') return 'Nb';
    if (type == 'bye') return '${runs}b';
    if (type == 'legbye') return '${runs}lb';
    return '$runs';
  }
}
