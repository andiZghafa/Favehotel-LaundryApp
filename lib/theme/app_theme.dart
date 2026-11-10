import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Design System Tokens for Housekeeping Laundry App
/// Adhering to brand palette, WCAG AA accessibility, and transitions-dev motion tokens.
class AppColors {
  // Brand Palette
  static const Color plumDark = Color(0xFF1A0B2E);
  static const Color purpleDeep = Color(0xFF2D1B69);
  static const Color brandMagenta = Color(0xFF900C46);
  static const Color brandMagentaDark = Color(0xFF7A0A3C);
  static const Color coralAccent = Color(0xFFFF6B6B);
  static const Color peachLight = Color(0xFFFFE4E1);

  // Surface & Card Colors (High contrast, clean elevation)
  static const Color surfaceGlass = Color(0x33FFFFFF); // 20% white
  static const Color surfaceGlassBorder = Color(0x4DFFFFFF); // 30% white
  static const Color surfaceCard = Color(0xFF24153B);
  static const Color surfaceCardLight = Color(0xFF321E4E);
  static const Color surfaceInput = Color(0xFF1F1133);

  // Text Colors (Accessible WCAG AA on dark backings)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE2D9F3);
  static const Color textMuted = Color(0xFFAFA3C7);

  // Status & Category Signals
  static const Color catFren = Color(0xFF900C46);
  static const Color catFast = Color(0xFF2D1B69);
  static const Color catRewash = Color(0xFFE05252);
  static const Color statusSuccess = Color(0xFF2EC4B6);
  static const Color statusWarning = Color(0xFFFF9F1C);
}

class AppMotion {
  // Transitions-dev & transitions-polish duration tokens
  static const Duration stagger = Duration(milliseconds: 40);
  static const Duration micro = Duration(milliseconds: 80);
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 400);

  // Transitions-dev curve tokens
  static const Curve easeSmoothOut = Cubic(0.22, 1.0, 0.36, 1.0);
  static const Curve easeBounce = Cubic(0.34, 1.36, 0.64, 1.0);
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseDark = ThemeData.dark();
    return ThemeData(
      brightness: Brightness.dark,
      textTheme: GoogleFonts.poppinsTextTheme(baseDark.textTheme),
      primaryColor: AppColors.brandMagenta,
      scaffoldBackgroundColor: AppColors.plumDark,
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(false),
        trackVisibility: WidgetStatePropertyAll(false),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandMagenta,
        secondary: AppColors.coralAccent,
        surface: AppColors.surfaceCard,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
