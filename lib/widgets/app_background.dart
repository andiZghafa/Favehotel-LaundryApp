import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// App Background — rich plum canvas with two ambient glows.
/// Canvas #1A0C38: dark but visibly purple (not pitch-black).
/// Two radial glows give depth without a noisy diagonal gradient:
///   • Top-center: magenta glow (the brand warmth)
///   • Bottom-right: deep purple (depth cue)
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool applySafeArea;
  final double maxWidth;

  const AppBackground({
    super.key,
    required this.child,
    this.applySafeArea = true,
    this.maxWidth = 600,
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
          // Top-center magenta ambient glow
          Positioned(
            top: -80,
            left: size.width * 0.1,
            right: size.width * 0.1,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandMagenta.withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom-right deep purple depth glow
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5B46B8).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
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

    return Scaffold(backgroundColor: AppColors.canvas, body: content);
  }
}
