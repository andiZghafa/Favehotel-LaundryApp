import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// App Background with brand gradient and responsive desktop-centering container
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.plumDark,
            AppColors.purpleDeep,
            AppColors.brandMagenta,
            Color(0xFF6B1D43),
          ],
          stops: [0.0, 0.35, 0.8, 1.0],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );

    if (applySafeArea) {
      return Scaffold(
        body: SafeArea(child: content),
      );
    }

    return Scaffold(body: content);
  }
}
