import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// Displays the favehotel wordmark from `assets/IKON.png`.
///
/// The source PNG is 200×200 with ~70% vertical dead-white space.
/// We use BoxFit.cover + Alignment.center inside a ~3.4:1 horizontal
/// container to crop away the top/bottom margins and show only the wordmark.
///
/// Background: dark surface-1 panel with a hairline border — not a white box.
class BrandWordmark extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const BrandWordmark({
    super.key,
    this.width = 140,
    this.height = 40,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        // Horizontal inset trims the outer white margins of the PNG
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Image.asset(
          'assets/IKON.png',
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              'favehotel',
              style: TextStyle(
                fontSize: height * 0.36,
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
