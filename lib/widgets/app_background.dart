import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// App Background — Linear-inspired dark canvas.
/// Near-flat near-black plum [AppColors.canvas] with one single centered
/// radial glow (brand magenta, 20% opacity) as the only decorative depth cue.
/// No loud diagonal gradients.
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
    Widget content = Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.canvas,
      child: Stack(
        children: [
          // Single radial glow — the only decorative element (Linear rule: no atmospheric gradients)
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 480,
                height: 480,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandMagenta.withOpacity(0.22),
                      AppColors.brandMagenta.withOpacity(0.0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
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
