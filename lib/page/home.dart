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
      duration: const Duration(milliseconds: 600),
    );

    // Staggered entrances (Emil Kowalski: 40-60ms stagger)
    _headerFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.50, curve: AppMotion.easeSmoothOut),
    );
    _card1Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.18, 0.68, curve: AppMotion.easeSmoothOut),
    );
    _card2Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.32, 0.82, curve: AppMotion.easeSmoothOut),
    );
    _card3Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.46, 0.96, curve: AppMotion.easeSmoothOut),
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
        pageBuilder: (_, animation, __) => screen,
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: const Offset(0.03, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: AppMotion.easeSmoothOut));
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Navigation Bar ──────────────────────────────────────────
            FadeTransition(
              opacity: _headerFade,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Naked, unboxed favehotel brand logo
                  const BrandWordmark(height: 38),
                  const Spacer(),
                  // Shift & Date Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.hairline),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x06000000),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.statusSuccess,
                          ),
                        ),
                        const SizedBox(width: 8),
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
            ),

            const SizedBox(height: 36),

            // ── Hero Section (Airbnb / Stripe Typography) ───────────────────
            FadeTransition(
              opacity: _headerFade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.coralDim,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.coralAccent.withOpacity(0.25)),
                    ),
                    child: const Text(
                      'HOUSEKEEPING PORTAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.coralAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Laundry Logbook',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.9,
                      height: 1.15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Record clean linen handovers, F&B fabrics, and separate stained items for rewash.',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Category 1: Fren Linen ──────────────────────────────────────
            FadeTransition(
              opacity: _card1Fade,
              child: _CategoryCard(
                title: 'Fren Linen',
                subtitle: 'Duvet covers, bedsheets, pillowcases, bath towels & batik cloth',
                metaLabel: '8 standard items',
                icon: Icons.king_bed_rounded,
                accentColor: AppColors.catFren,
                accentBg: AppColors.catFrenBg,
                onTap: () => _navigateTo(
                  context,
                  const LinenFormScreen(category: LinenCategory.fren),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Category 2: Fast Items ──────────────────────────────────────
            FadeTransition(
              opacity: _card2Fade,
              child: _CategoryCard(
                title: 'Fast Items',
                subtitle: 'Bath mats, mukena, sejadah, sarung & hotel flags',
                metaLabel: '6 specialized items',
                icon: Icons.dry_cleaning_rounded,
                accentColor: AppColors.catFast,
                accentBg: AppColors.catFastBg,
                onTap: () => _navigateTo(
                  context,
                  const LinenFormScreen(category: LinenCategory.fast),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Category 3: Rewash Station (Standalone) ─────────────────────
            FadeTransition(
              opacity: _card3Fade,
              child: _CategoryCard(
                title: 'Rewash Station',
                subtitle: 'Dedicated station for stained, torn, or defective Fren & Fast linens',
                metaLabel: 'Fren & Fast Station',
                icon: Icons.autorenew_rounded,
                accentColor: AppColors.catRewash,
                accentBg: AppColors.catRewashBg,
                onTap: () => _navigateTo(
                  context,
                  const RewashScreen(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Footer Bar ──────────────────────────────────────────────────
            FadeTransition(
              opacity: _card3Fade,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.hairline),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x04000000),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.table_view_rounded,
                      size: 16,
                      color: AppColors.statusSuccess,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Direct Excel export ready (.xlsx)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showExitDialog(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.logout_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Exit',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.hairline),
        ),
        title: const Text(
          'Close Logbook',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        content: const Text(
          'Are you sure you want to close the laundry logbook application?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandMagenta,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Exit Application'),
          ),
        ],
      ),
    );
  }
}

// ── Category Card Component (Emil Kowalski Physics) ───────────────────────────

class _CategoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String metaLabel;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.metaLabel,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Emil Kowalski rule: Press scales to 0.98 over 160ms ease-out
    final scale = _isPressed ? 0.98 : 1.0;

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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.surfaceCardHover : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withOpacity(0.4)
                    : AppColors.hairline,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.accentColor.withOpacity(0.08)
                      : const Color(0x050F172A),
                  blurRadius: _isHovered ? 20 : 8,
                  offset: Offset(0, _isHovered ? 6 : 2),
                ),
                BoxShadow(
                  color: const Color(0x03000000),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Container: Concentric (R_outer 18, pad 18, R_inner 12)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.accentBg,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: widget.accentColor.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Text Description Block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Subtle Meta Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: widget.accentBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.accentColor.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              widget.metaLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: widget.accentColor,
                                fontFeatures: const [FontFeature.tabularFigures()],
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
                // Smooth Animated Chevron
                AnimatedSlide(
                  duration: AppMotion.quick,
                  offset: _isHovered ? const Offset(0.2, 0) : Offset.zero,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: _isHovered ? widget.accentColor : AppColors.textMuted,
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
