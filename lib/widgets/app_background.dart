import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// Luminous, executive hospitality background.
/// Clean porcelain canvas with subtle atmospheric ambient warmth.
/// Responsive desktop-centering container with smooth scrolling.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool applySafeArea;
  final double maxWidth;

  const AppBackground({
    super.key,
    required this.child,
    this.applySafeArea = true,
    this.maxWidth = 640,
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
            top: -100,
            right: -60,
            child: Container(
              width: 480,
              height: 480,
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
          // Ambient Warmth 2: Soft lavender glow at top-left
          Positioned(
            top: 140,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
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
