import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system tokens — Linear-inspired dark canvas adapted to brand palette.
/// Canvas: #0D0620 (deep plum, nearly black). Surface ladder: 3 steps.
/// Brand accent: coral #FF6B6B + magenta #900C46. No loud gradients.
class AppColors {
  // ── Canvas & surfaces ──────────────────────────────────────────────────────
  static const Color canvas      = Color(0xFF0D0620); // near-black plum canvas
  static const Color surface1    = Color(0xFF160A30); // cards, panels
  static const Color surface2    = Color(0xFF1E1040); // hovered/featured card
  static const Color surface3    = Color(0xFF251550); // elevated inner surface
  static const Color surfaceInput = Color(0xFF0F0520); // input background

  // ── Hairlines ──────────────────────────────────────────────────────────────
  static const Color hairline      = Color(0xFF2A1A4A); // 1px card borders
  static const Color hairlineStrong = Color(0xFF3D2A65); // hover, focus borders

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF6F4FF); // ink — near-white w/ purple tint
  static const Color textSecondary = Color(0xFFCDC6E8); // secondary prose
  static const Color textMuted     = Color(0xFF8A80AD); // placeholder, meta
  static const Color textDisabled  = Color(0xFF4D4568); // disabled

  // ── Brand accents ──────────────────────────────────────────────────────────
  static const Color coralAccent    = Color(0xFFFF6B6B); // coral — primary interactive accent
  static const Color coralDim       = Color(0x33FF6B6B); // coral at 20%
  static const Color brandMagenta   = Color(0xFF900C46); // magenta — CTA, Rewash glow
  static const Color brandMagentaDark = Color(0xFF7A0A3C);
  static const Color peachLight     = Color(0xFFFFE4E1); // kept for compatibility

  // ── Category signals ───────────────────────────────────────────────────────
  static const Color catFren  = Color(0xFFB33060); // magenta-rose
  static const Color catFast  = Color(0xFF4D3A9A); // deep purple
  static const Color catRewash = Color(0xFFFF6B6B); // coral

  // ── Semantic ───────────────────────────────────────────────────────────────
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
