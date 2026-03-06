import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palantir Color Palette ────────────────────────────────────────
class Palantir {
  Palantir._();

  static const Color bg = Color(0xFF060A10);
  static const Color surface = Color(0xFF0B1018);
  static const Color surfaceLight = Color(0xFF111820);
  static const Color border = Color(0xFF1A2030);
  static const Color borderLight = Color(0xFF2A3040);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentDim = Color(0xFFD97706);
  static const Color text = Color(0xFFE6EDF3);
  static const Color textMuted = Color(0xFF6E7681);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color info = Color(0xFF3B82F6);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color purple = Color(0xFFA855F7);
  static const Color pink = Color(0xFFEC4899);
  static const Color orange = Color(0xFFF97316);
}

// ── NATO APP-6 Symbology Colors ──────────────────────────────────
class NatoColors {
  NatoColors._();

  static const Color friendly = Color(0xFF3B82F6);   // Blue — Allied / Coalition
  static const Color hostile  = Color(0xFFEF4444);    // Red — Threats / Adversary
  static const Color neutral  = Color(0xFF22C55E);    // Green — Neutral / Civilian
  static const Color unknown  = Color(0xFFEAB308);    // Yellow — Unknown / Suspect
}

// ── Attack Type Colors ────────────────────────────────────────────
class AttackColors {
  AttackColors._();

  static const Color ballistic = Color(0xFFEF4444);
  static const Color cruise = Color(0xFFF97316);
  static const Color drone = Color(0xFF06B6D4);
  static const Color artillery = Color(0xFFEAB308);
  static const Color cyber = Color(0xFFA855F7);
  static const Color sabotage = Color(0xFFEC4899);
}

// ── Severity Colors ───────────────────────────────────────────────
class SeverityColors {
  SeverityColors._();

  static const Color critical = Color(0xFFEF4444);
  static const Color high = Color(0xFFF97316);
  static const Color medium = Color(0xFFEAB308);
  static const Color low = Color(0xFF6E7681);
}

// ── Status Colors ─────────────────────────────────────────────────
class StatusColors {
  StatusColors._();

  static const Color active = Color(0xFFEF4444);
  static const Color damaged = Color(0xFFF97316);
  static const Color neutralized = Color(0xFF22C55E);
  static const Color unknown = Color(0xFF6E7681);
  static const Color intercepted = Color(0xFF22C55E);
  static const Color impact = Color(0xFFEF4444);
  static const Color ongoing = Color(0xFFF59E0B);
}

// ── Text Styles ───────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color color = Palantir.text,
    double? letterSpacing,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing ?? 0.5,
    );
  }

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = Palantir.text,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // Convenience presets
  static TextStyle get headline =>
      mono(size: 18, weight: FontWeight.w700, color: Palantir.accent);

  static TextStyle get sectionTitle =>
      mono(size: 13, weight: FontWeight.w600, letterSpacing: 1.5);

  static TextStyle get label =>
      mono(size: 11, weight: FontWeight.w500, color: Palantir.textMuted, letterSpacing: 1.2);

  static TextStyle get body => sans(size: 15);

  static TextStyle get bodySmall => sans(size: 13, color: Palantir.textMuted);

  static TextStyle get badge =>
      mono(size: 10, weight: FontWeight.w700, letterSpacing: 1.0);

  static TextStyle get stat =>
      mono(size: 16, weight: FontWeight.w700, color: Palantir.accent);

  static TextStyle get statLabel =>
      mono(size: 11, weight: FontWeight.w500, color: Palantir.textMuted);
}

// ── App Theme ─────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palantir.bg,
    colorScheme: const ColorScheme.dark(
      surface: Palantir.surface,
      primary: Palantir.accent,
      secondary: Palantir.cyan,
      error: Palantir.danger,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Palantir.surface,
      foregroundColor: Palantir.text,
      elevation: 0,
      titleTextStyle: AppTextStyles.mono(
        size: 14,
        weight: FontWeight.w700,
        color: Palantir.accent,
        letterSpacing: 2.0,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Palantir.surface,
      selectedItemColor: Palantir.accent,
      unselectedItemColor: Palantir.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Palantir.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Palantir.border, width: 1),
      ),
    ),
    dividerColor: Palantir.border,
    iconTheme: const IconThemeData(color: Palantir.textMuted, size: 16),
  );
}
