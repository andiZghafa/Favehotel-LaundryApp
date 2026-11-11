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
      duration: const Duration(milliseconds: 650),
    );
    _headerFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: AppMotion.easeSmoothOut),
    );
    _card1Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.20, 0.68, curve: AppMotion.easeSmoothOut),
    );
    _card2Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.82, curve: AppMotion.easeSmoothOut),
    );
    _card3Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.50, 0.96, curve: AppMotion.easeSmoothOut),
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
          final tween = Tween(begin: const Offset(0.04, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: AppMotion.easeSmoothOut));
          return FadeTransition(
            opacity: animation,
            child:
                SlideTransition(position: animation.drive(tween), child: child),
          );
        },
        transitionDuration: AppMotion.fast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return AppBackground(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Header ───────────────────────────────────────────────
            FadeTransition(
              opacity: _headerFade,
              child: _HeroHeader(formattedDate: formattedDate),
            ),

            const SizedBox(height: 28),

            // ── Category Cards ────────────────────────────────────────────
            FadeTransition(
              opacity: _card1Fade,
              child: _CategoryCard(
                title: 'Fren Linen',
                subtitle:
                    'Duvet covers, bedsheets, pillowcases & bath towels',
                metaLabel: '8 items',
                icon: Icons.king_bed_outlined,
                accentColor: AppColors.catFren,
                onTap: () => _navigateTo(
                  context,
                  const LinenFormScreen(category: LinenCategory.fren),
                ),
              ),
            ),

            const SizedBox(height: 12),

            FadeTransition(
              opacity: _card2Fade,
              child: _CategoryCard(
                title: 'Fast Items',
                subtitle:
                    'Bath mats, mukena, sejadah, sarung & hotel flags',
                metaLabel: '6 items',
                icon: Icons.dry_cleaning_outlined,
                accentColor: AppColors.catFast,
                onTap: () => _navigateTo(
                  context,
                  const LinenFormScreen(category: LinenCategory.fast),
                ),
              ),
            ),

            const SizedBox(height: 12),

            FadeTransition(
              opacity: _card3Fade,
              child: _CategoryCard(
                title: 'Rewash Station',
                subtitle:
                    'Log stained, torn or discolored linens from Fren & Fast',
                metaLabel: 'Fren & Fast',
                icon: Icons.autorenew_rounded,
                accentColor: AppColors.catRewash,
                onTap: () =>
                    _navigateTo(context, const RewashScreen()),
              ),
            ),

            const SizedBox(height: 24),

            // ── Footer ────────────────────────────────────────────────────
            FadeTransition(
              opacity: _card3Fade,
              child: _FooterRow(onClose: () => _showExitDialog(context)),
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
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.hairline),
        ),
        title: const Text(
          'Close Logbook',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: const Text(
          'Are you sure you want to close the application?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
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
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

// ── Hero Header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final String formattedDate;
  const _HeroHeader({required this.formattedDate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: logo left | date chip right
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo — full width, properly cropped via BoxFit.cover
            const BrandWordmark(width: 200, height: 56, borderRadius: 10),
            const Spacer(),
            // Date chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 13, color: AppColors.coralAccent),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 11.5,
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

        // Section label pill
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.coralDim,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.coralAccent.withOpacity(0.4)),
          ),
          child: const Text(
            'Housekeeping',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.coralAccent,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Display headline
        const Text(
          'Laundry Logbook',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
            height: 1.15,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Record linen handovers and log stained items for rewash.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Category Card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String metaLabel;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.metaLabel,
    required this.icon,
    required this.accentColor,
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
          scale: _isPressed ? 0.97 : 1.0,
          duration: AppMotion.quick,
          curve: AppMotion.easeSmoothOut,
          child: AnimatedContainer(
            duration: AppMotion.quick,
            curve: AppMotion.easeSmoothOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.surface2 : AppColors.surface1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withOpacity(0.55)
                    : AppColors.hairline,
              ),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon box — concentric radius
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    // Slightly lighter background so icons are visible
                    color: widget.accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: widget.accentColor.withOpacity(0.45)),
                  ),
                  child: Icon(widget.icon,
                      color: widget.accentColor, size: 22),
                ),
                const SizedBox(width: 14),

                // Text
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: widget.accentColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              widget.metaLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: widget.accentColor,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                AnimatedSlide(
                  duration: AppMotion.quick,
                  offset:
                      _isHovered ? const Offset(0.2, 0) : Offset.zero,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: _isHovered
                        ? widget.accentColor
                        : AppColors.textDisabled,
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

// ── Footer Row ────────────────────────────────────────────────────────────────

class _FooterRow extends StatelessWidget {
  final VoidCallback onClose;
  const _FooterRow({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface1.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          const Icon(Icons.table_view_outlined,
              size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Exports directly to Excel (.xlsx)',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout_rounded,
                    size: 13, color: AppColors.textDisabled),
                SizedBox(width: 4),
                Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
