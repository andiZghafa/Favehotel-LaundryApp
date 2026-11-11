import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens inspired by Airbnb, Stripe & Emil Kowalski's Design Engineering.
/// Light, luminous, luxury hotel aesthetic.
/// Brand Palette: favehotel Magenta (#A3004C), Rose/Coral (#E11D48), Warm Slate.
class AppColors {
  // ── Canvas & Surfaces (Clean, Luminous, Executive Hospitality) ─────────────
  static const Color canvas       = Color(0xFFF8FAFC); // Slate-50: crisp, airy canvas
  static const Color surfaceCard   = Color(0xFFFFFFFF); // Pure white card surfaces
  static const Color surfaceCardHover = Color(0xFFF1F5F9); // Slate-100: gentle hover lift
  static const Color surfaceInput  = Color(0xFFF8FAFC); // Subtle inset well for inputs
  static const Color surfacePill   = Color(0xFFF1F5F9); // Chip & pill backgrounds

  // ── Hairlines & Borders ───────────────────────────────────────────────────
  static const Color hairline       = Color(0xFFE2E8F0); // 1px Slate-200 border
  static const Color hairlineStrong = Color(0xFFCBD5E1); // Slate-300: active/hover border
  static const Color hairlineFocus  = Color(0xFFA3004C); // Brand magenta focus ring

  // ── Text (High contrast, deep ink for effortless readability) ─────────────
  static const Color textPrimary   = Color(0xFF0F172A); // Slate-900: deep charcoal ink
  static const Color textSecondary = Color(0xFF475569); // Slate-600: balanced readability
  static const Color textMuted     = Color(0xFF94A3B8); // Slate-400: captions & meta
  static const Color textDisabled  = Color(0xFFCBD5E1); // Slate-300: inactive

  // ── Brand Voltage (favehotel Magenta & Warm Coral) ────────────────────────
  static const Color brandMagenta     = Color(0xFFA3004C); // Official favehotel magenta
  static const Color brandMagentaDark = Color(0xFF7E0038); // Deep magenta for gradients
  static const Color brandMagentaLight = Color(0xFFFDF2F8); // Pink-50: soft tint for badges
  static const Color coralAccent      = Color(0xFFE11D48); // Rose-600: vibrant interactive accent
  static const Color coralDim         = Color(0xFFFFF1F2); // Rose-50: soft pill backgrounds
  static const Color peachLight       = Color(0xFFFFE4E6); // Rose-100

  // ── Category Signals ──────────────────────────────────────────────────────
  static const Color catFren   = Color(0xFFA3004C); // favehotel Magenta for FREN
  static const Color catFast   = Color(0xFF4F46E5); // Indigo-600 for FAST
  static const Color catRewash = Color(0xFFE11D48); // Coral/Rose for Rewash

  // ── Category Soft Backgrounds (For icon wells & badges) ───────────────────
  static const Color catFrenBg   = Color(0xFFFDF2F8);
  static const Color catFastBg   = Color(0xFFEEF2FF);
  static const Color catRewashBg = Color(0xFFFFF1F2);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color statusSuccess = Color(0xFF059669); // Emerald-600
  static const Color statusWarning = Color(0xFFD97706); // Amber-600

  // ── Legacy Aliases (Ensure zero breakage across codebase) ──────────────────
  static const Color canvasDark       = canvas;
  static const Color plumDark         = Color(0xFF0F172A);
  static const Color purpleDeep       = Color(0xFF4F46E5);
  static const Color surfaceGlass     = Color(0xFFFFFFFF);
  static const Color surfaceGlassBorder = hairline;
  static const Color surface1         = surfaceCard;
  static const Color surface2         = surfaceCardHover;
  static const Color surface3         = surfacePill;
  static const Color surfaceCardLight = surfaceCardHover;
}

class AppMotion {
  // Emil Kowalski & transitions-dev motion tokens
  static const Duration micro   = Duration(milliseconds: 90);
  static const Duration quick   = Duration(milliseconds: 160);
  static const Duration fast    = Duration(milliseconds: 240);
  static const Duration medium  = Duration(milliseconds: 320);
  static const Duration slow    = Duration(milliseconds: 400);

  // Emil Kowalski custom curves: fast entrance, smooth settle, never sluggish
  static const Curve easeSmoothOut = Cubic(0.23, 1.0, 0.32, 1.0);
  static const Curve easeBounce    = Cubic(0.34, 1.36, 0.64, 1.0);
  static const Curve easeDrawer    = Cubic(0.32, 0.72, 0.0, 1.0);
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      brightness: Brightness.light,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      primaryColor: AppColors.brandMagenta,
      scaffoldBackgroundColor: AppColors.canvas,
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(false),
        trackVisibility: WidgetStatePropertyAll(false),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandMagenta,
        secondary: AppColors.coralAccent,
        surface: AppColors.surfaceCard,
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

  // Alias for backward compatibility
  static ThemeData get darkTheme => lightTheme;
}
