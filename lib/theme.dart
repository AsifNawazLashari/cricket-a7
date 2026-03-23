import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // CSS Variables translation
  static const Color bg = Color(0xFF07111F);
  static const Color bg2 = Color(0xFF0B1A2E);
  static const Color panel = Color(0xFF0E2040);
  static const Color cyan = Color(0xFF00D4FF);
  static const Color cyan2 = Color(0xFF00A8CC);
  static const Color green = Color(0xFF00FF88);
  static const Color yellow = Color(0xFFFFD93D);
  static const Color red = Color(0xFFFF4757);
  static const Color text = Color(0xFFE8F4FF);
  static const Color muted = Color(0xFF6B8AAA);
  static const Color border = Color(0x2600B4FF); // rgba(0,180,255,0.15)

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0080CC), Color(0xFF0060AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD93D), Color(0xFFCC9900)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFCC2233)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xE60D2040), Color(0xF2091828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow Effects
  static List<BoxShadow> glowCyan = [
    BoxShadow(color: cyan.withOpacity(0.3), blurRadius: 20, spreadRadius: 0)
  ];
  
  static List<BoxShadow> glowCyanSm = [
    BoxShadow(color: cyan.withOpacity(0.2), blurRadius: 10, spreadRadius: 0)
  ];

  static List<BoxShadow> shadowCard = [
    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 4))
  ];

  // Text Styles (Barlow, Rajdhani, Barlow Condensed)
  static TextStyle barlow(double size, [FontWeight weight = FontWeight.w400, Color color = text]) {
    return GoogleFonts.barlow(fontSize: size, fontWeight: weight, color: color);
  }

  static TextStyle rajdhani(double size, [FontWeight weight = FontWeight.bold, Color color = cyan]) {
    return GoogleFonts.rajdhani(fontSize: size, fontWeight: weight, color: color, letterSpacing: 1.2);
  }

  static TextStyle condensed(double size, [FontWeight weight = FontWeight.w600, Color color = muted]) {
    return GoogleFonts.barlowCondensed(fontSize: size, fontWeight: weight, color: color, letterSpacing: 1.5);
  }

  // Card Decoration
  static BoxDecoration glassCard = BoxDecoration(
    color: const Color(0xBF0A1930), // rgba(10,25,48,.75)
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: border),
    boxShadow: shadowCard,
  );
}
