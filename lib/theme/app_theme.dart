import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens — rich plum-purple dark canvas.
/// Canvas: #1A0C38 (not pitch-black — the purple brand DNA is visible).
/// Three-step surface ladder with real contrast between levels.
/// Accents: coral #FF6B6B (interactive), magenta #900C46 (CTA/rewash).
class AppColors {
  // ── Canvas & surfaces ─────────────────────────────────────────────────────
  static const Color canvas      = Color(0xFF1A0C38); // rich plum — dark but alive
  static const Color surface1    = Color(0xFF241552); // cards, panels
  static const Color surface2    = Color(0xFF2E1C65); // hover / featured
  static const Color surface3    = Color(0xFF3A2478); // elevated inner
  static const Color surfaceInput = Color(0xFF160A2E); // input bg

  // ── Hairlines ─────────────────────────────────────────────────────────────
  static const Color hairline       = Color(0xFF3D2870); // 1px card borders
  static const Color hairlineStrong = Color(0xFF5A3E9A); // hover/focus borders

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF5F0FF); // near-white w/ purple tint
  static const Color textSecondary = Color(0xFFCDC1EE); // secondary prose
  static const Color textMuted     = Color(0xFF8E80B8); // placeholder, meta
  static const Color textDisabled  = Color(0xFF524478); // disabled

  // ── Brand accents ─────────────────────────────────────────────────────────
  static const Color coralAccent    = Color(0xFFFF6B6B); // primary interactive
  static const Color coralDim       = Color(0x2DFF6B6B); // coral at 18%
  static const Color brandMagenta   = Color(0xFF900C46); // CTA, rewash
  static const Color brandMagentaDark = Color(0xFF7A0A3C);
  static const Color peachLight     = Color(0xFFFFE4E1);

  // ── Category signals ──────────────────────────────────────────────────────
  static const Color catFren   = Color(0xFFB33060); // magenta-rose for FREN
  static const Color catFast   = Color(0xFF5B46B8); // bright purple for FAST
  static const Color catRewash = Color(0xFFFF6B6B); // coral for rewash

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color statusSuccess = Color(0xFF2EC4B6);
  static const Color statusWarning = Color(0xFFFF9F1C);

  // ── Legacy aliases (keep compiling) ───────────────────────────────────────
  static const Color plumDark        = canvas;
  static const Color purpleDeep      = Color(0xFF2D1B69);
  static const Color surfaceGlass    = Color(0x1AFFFFFF);
  static const Color surfaceGlassBorder = hairline;
  static const Color surfaceCard     = surface1;
  static const Color surfaceCardLight = surface2;
}

class AppMotion {
  static const Duration stagger = Duration(milliseconds: 40);
  static const Duration micro   = Duration(milliseconds: 80);
  static const Duration quick   = Duration(milliseconds: 150);
  static const Duration fast    = Duration(milliseconds: 250);
  static const Duration medium  = Duration(milliseconds: 350);
  static const Duration slow    = Duration(milliseconds: 400);

  static const Curve easeSmoothOut = Cubic(0.22, 1.0, 0.36, 1.0);
  static const Curve easeBounce    = Cubic(0.34, 1.36, 0.64, 1.0);
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseDark = ThemeData.dark();
    return ThemeData(
      brightness: Brightness.dark,
      textTheme: GoogleFonts.poppinsTextTheme(baseDark.textTheme),
      primaryColor: AppColors.coralAccent,
      scaffoldBackgroundColor: AppColors.canvas,
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(false),
        trackVisibility: WidgetStatePropertyAll(false),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.coralAccent,
        secondary: AppColors.brandMagenta,
        surface: AppColors.surface1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}
