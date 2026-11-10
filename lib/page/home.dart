import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/models/linen_models.dart';
import 'package:laundry_app/page/linen_form_screen.dart';
import 'package:laundry_app/page/rewash_screen.dart';
import 'package:laundry_app/theme/app_theme.dart';
import 'package:laundry_app/widgets/app_background.dart';
import 'package:laundry_app/widgets/brand_wordmark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _headerFade;
  late Animation<double> _card1Fade;
  late Animation<double> _card2Fade;
  late Animation<double> _card3Fade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _headerFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: AppMotion.easeSmoothOut),
    );

    _card1Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.18, 0.65, curve: AppMotion.easeSmoothOut),
    );

    _card2Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.32, 0.80, curve: AppMotion.easeSmoothOut),
    );

    _card3Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.46, 0.95, curve: AppMotion.easeSmoothOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.05, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: AppMotion.easeSmoothOut),
          );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: animation.drive(tween), child: child),
          );
        },
        transitionDuration: AppMotion.fast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(now);

    return AppBackground(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Edge-aligned Top Masthead + Intro (Linear / Airbnb Workbench hierarchy)
            FadeTransition(
              opacity: _headerFade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const BrandWordmark(
                        width: 138,
                        height: 40,
                        borderRadius: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: AppColors.coralAccent,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Housekeeping Logbook',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      height: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select a category to record clean linen handovers or log stained items for rewash.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Category 1: Fren Linen
            FadeTransition(
              opacity: _card1Fade,
              child: _CategoryMenuCard(
                title: 'Fren Linen',
                subtitle: 'Duvet covers, bedsheets, pillowcases, bath towels, and batik cloth',
                metaLabel: '8 items',
                icon: Icons.king_bed_outlined,
                accentColor: AppColors.brandMagenta,
                onTap: () => _navigateTo(
                  context,
                  const LinenFormScreen(category: LinenCategory.fren),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Category 2: Fast Items
            FadeTransition(
              opacity: _card2Fade,
              child: _CategoryMenuCard(
                title: 'Fast Items',
                subtitle: 'Bath mats, mukena, sejadah, sarung, and hotel flags',
                metaLabel: '6 items',
                icon: Icons.dry_cleaning_outlined,
                accentColor: const Color(0xFF7B52AB),
                onTap: () => _navigateTo(
                  context,
                  const LinenFormScreen(category: LinenCategory.fast),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Category 3: Rewash Station (Standalone Category)
            FadeTransition(
              opacity: _card3Fade,
              child: _CategoryMenuCard(
                title: 'Rewash Station',
                subtitle: 'Log stained, discolored, or torn linens from Fren and Fast inventories',
                metaLabel: 'Fren & Fast',
                icon: Icons.autorenew_rounded,
                accentColor: AppColors.coralAccent,
                onTap: () => _navigateTo(
                  context,
                  const RewashScreen(),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Subtle Footer / Exit Row
            FadeTransition(
              opacity: _card3Fade,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.table_view_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Exports directly to Excel (.xlsx)',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surfaceCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Close Logbook',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content: const Text(
                              'Are you sure you want to close the application?',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: AppColors.textMuted),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  SystemNavigator.pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandMagenta,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Exit'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(44, 36),
                      ),
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      label: const Text(
                        'Close',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CategoryMenuCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String metaLabel;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _CategoryMenuCard({
    required this.title,
    required this.subtitle,
    required this.metaLabel,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_CategoryMenuCard> createState() => _CategoryMenuCardState();
}

class _CategoryMenuCardState extends State<_CategoryMenuCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // make-interfaces-feel-better #12: Press scales to 0.96 over 150ms with ease-out
    final double scale = _isPressed ? 0.96 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: AppMotion.quick,
          curve: AppMotion.easeSmoothOut,
          child: AnimatedContainer(
            duration: AppMotion.quick,
            curve: AppMotion.easeSmoothOut,
            // Concentric border radius: outer 20px, padding 18px, inner icon 12px
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.surfaceCardLight
                  : AppColors.surfaceCard.withOpacity(0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withOpacity(0.65)
                    : Colors.white.withOpacity(0.12),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.28 : 0.18),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: Offset(0, _isHovered ? 6 : 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Concentric Icon Container (44x44 hit/visual box, radius 12)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.accentColor.withOpacity(0.45),
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Content column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.metaLabel,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: AnimatedSlide(
                    duration: AppMotion.quick,
                    offset: _isHovered ? const Offset(0.18, 0) : Offset.zero,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: _isHovered ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
