import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

/// Displays the favehotel wordmark from `assets/IKON.png`.
///
/// The source PNG is 200×200 with ~70% vertical dead-white space baked in.
/// BoxFit.cover on a wide/short container crops the top+bottom white margins
/// and reveals just the wordmark row — the aspect ratio maths:
///   container 200×56  →  scale = 200/200 = 1.0  →  full width, centered crop
///   shows the middle 56px of the 200px original (y≈72..128) which is the wordmark.
class BrandWordmark extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const BrandWordmark({
    super.key,
    this.width = 200,
    this.height = 56,
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
            color: Colors.black.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/IKON.png',
        // cover: fills width, crops top+bottom white margins → wordmark fills frame
        fit: BoxFit.cover,
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
    );
  }
}
