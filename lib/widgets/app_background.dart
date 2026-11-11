import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// Luminous, executive hospitality background.
/// Clean porcelain canvas with subtle atmospheric ambient warmth.
/// Responsive desktop container (defaults to 1140px max-width on widescreen)
/// eliminating the empty desert on desktop while keeping mobile tight and focused.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool applySafeArea;
  final double maxWidth;

  const AppBackground({
    super.key,
    required this.child,
    this.applySafeArea = true,
    this.maxWidth = 1140,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget content = Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.canvas,
      child: Stack(
        children: [
          // Ambient Warmth 1: Soft brand rose glow at top-right
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: size.width > 1200 ? 640 : 480,
              height: size.width > 1200 ? 640 : 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandMagenta.withOpacity(0.045),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Ambient Warmth 2: Soft lavender glow at bottom-left
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.035),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Centered Responsive Content Container
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        ],
      ),
    );

    if (applySafeArea) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(child: content),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: content,
    );
  }
}
