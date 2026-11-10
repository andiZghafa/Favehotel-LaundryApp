import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// Displays the favehotel wordmark from `assets/IKON.png` cropped to its
/// true horizontal aspect ratio, removing the excess vertical white margins
/// baked into the square source PNG.
class BrandWordmark extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const BrandWordmark({
    super.key,
    this.width = 144,
    this.height = 42,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.12),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset(
          'assets/IKON.png',
          width: width,
          height: height,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text(
              'favehotel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.brandMagenta,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
