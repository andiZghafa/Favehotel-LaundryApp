import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// Clean, unboxed favehotel brand wordmark.
/// Renders directly onto the canvas with NO background box, NO border, and NO shadow.
/// Uses the high-resolution cropped transparent asset `assets/logo_clean.png`.
class BrandWordmark extends StatelessWidget {
  final double? width;
  final double height;

  const BrandWordmark({
    super.key,
    this.width,
    this.height = 36,
    double? borderRadius, // kept for signature compatibility
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo_clean.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'fave',
            style: TextStyle(
              fontSize: height * 0.72,
              fontWeight: FontWeight.w800,
              color: AppColors.brandMagenta,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'hotel',
            style: TextStyle(
              fontSize: height * 0.72,
              fontWeight: FontWeight.w400,
              color: AppColors.brandMagenta,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Padjajaran • Bogor',
            style: TextStyle(
              fontSize: height * 0.32,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
