import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// Clean, unboxed favehotel brand wordmark using the official high-resolution
/// transparent asset `assets/new_IKON.png` (1370x370).
/// Renders natively onto the canvas with NO white container, NO box, and NO border.
class BrandWordmark extends StatelessWidget {
  final double? width;
  final double height;

  const BrandWordmark({
    super.key,
    this.width,
    this.height = 42,
    double? borderRadius, // kept for parameter compatibility
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/new_IKON.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/New-IKON.png',
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
            const SizedBox(width: 8),
            Text(
              'Padjajaran • Bogor',
              style: TextStyle(
                fontSize: height * 0.32,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
