import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/models/linen_models.dart';
import 'package:laundry_app/page/linen_form_screen.dart';
import 'package:laundry_app/page/monthly_recap_screen.dart';
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

    // Emil Kowalski stagger: 40-60ms cascading entrances
    _headerFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: AppMotion.easeSmoothOut),
    );
    _card1Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.15, 0.65, curve: AppMotion.easeSmoothOut),
    );
    _card2Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.28, 0.78, curve: AppMotion.easeSmoothOut),
    );
    _card3Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.40, 0.92, curve: AppMotion.easeSmoothOut),
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
      maxWidth: 1140,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;
          final double horizontalPadding = isDesktop ? 36.0 : 20.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Navigation Bar ──────────────────────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Official favehotel unboxed logo (height 44)
                      const BrandWordmark(height: 44),
                      const Spacer(),

                      // Center Department Pill (Desktop only)
                      if (isDesktop) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.hotel_rounded, size: 14, color: AppColors.brandMagenta),
                              SizedBox(width: 6),
                              Text(
                                'Housekeeping Dept • favehotel Padjajaran',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Monthly Recap Action Chip
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _navigateTo(context, const MonthlyRecapScreen()),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.brandMagentaLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.brandMagenta.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.brandMagenta),
                                SizedBox(width: 6),
                                Text(
                                  'Rekap Bulanan',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandMagenta,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Shift & Date Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.hairline),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x05000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
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
                                fontWeight: FontWeight.w600,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Hero Section (Airbnb / Stripe Executive Typography) ─────
                FadeTransition(
                  opacity: _headerFade,
                  child: isDesktop
                      ? _buildDesktopHero()
                      : _buildMobileHero(),
                ),

                const SizedBox(height: 30),

                // ── Category Grid (Responsive: 3-column desktop / 1-column mobile)
                if (isDesktop) ...[
                  _buildDesktopCategoryRow(context),
                ] else ...[
                  _buildMobileCategoryColumn(context),
                ],

                const SizedBox(height: 32),

                // ── Bottom Utility Strip ────────────────────────────────────
                FadeTransition(
                  opacity: _card3Fade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.hairline),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x03000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.table_view_rounded,
                          size: 18,
                          color: AppColors.statusSuccess,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Standardized Excel export format (.xlsx) • Daily Housekeeping Log',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _navigateTo(context, const MonthlyRecapScreen()),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.summarize_outlined,
                                    size: 15,
                                    color: AppColors.brandMagenta,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Rekap Bulanan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.brandMagenta,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showExitDialog(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 15,
                                    color: AppColors.textMuted,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Exit Logbook',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopHero() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Left Column: Headline and description
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.coralDim,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.coralAccent.withOpacity(0.25)),
                ),
                child: const Text(
                  'HOTEL HOUSEKEEPING PORTAL',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.coralAccent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Laundry & Linen Logbook',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  height: 1.15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Record clean linen handovers, specialized F&B fabrics, and separate stained or damaged linens for rewash.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right Column: Quick Status Widget
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.hairline),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x04000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill('3 Categories', 'Fren, Fast, Rewash', Icons.layers_rounded, AppColors.brandMagenta),
                Container(width: 1, height: 36, color: AppColors.hairline),
                _buildStatPill('Export Ready', 'Excel Format (.xlsx)', Icons.file_download_done_rounded, AppColors.statusSuccess),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileHero() {
    return Column(
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
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.coralAccent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Laundry Logbook',
          style: TextStyle(
            fontSize: 30,
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
    );
  }

  Widget _buildDesktopCategoryRow(BuildContext context) {
    // IntrinsicHeight stretches all 3 cards to match the tallest one
    return IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fren Linen Card
        Expanded(
          child: FadeTransition(
            opacity: _card1Fade,
            child: _CategoryCardDesktop(
              title: 'Fren Linen',
              subtitle: 'Bedding, duvet covers, sheets, pillowcases & bath towels',
              metaLabel: '8 standard items',
              tags: const ['Duvet', 'Bedsheet', 'Bath Towel', 'Batik Cloth'],
              icon: Icons.king_bed_rounded,
              accentColor: AppColors.catFren,
              accentBg: AppColors.catFrenBg,
              onTap: () => _navigateTo(
                context,
                const LinenFormScreen(category: LinenCategory.fren),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Fast Items Card
        Expanded(
          child: FadeTransition(
            opacity: _card2Fade,
            child: _CategoryCardDesktop(
              title: 'Fast Items',
              subtitle: 'Bath mats, mukena, sejadah, sarung & hotel flags',
              metaLabel: '6 specialized items',
              tags: const ['Bath Mat', 'Mukena', 'Sejadah', 'Hotel Flag'],
              icon: Icons.dry_cleaning_rounded,
              accentColor: AppColors.catFast,
              accentBg: AppColors.catFastBg,
              onTap: () => _navigateTo(
                context,
                const LinenFormScreen(category: LinenCategory.fast),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Rewash Station Card
        Expanded(
          child: FadeTransition(
            opacity: _card3Fade,
            child: _CategoryCardDesktop(
              title: 'Rewash Station',
              subtitle: 'Dedicated station for stained, torn, or defective linens',
              metaLabel: 'Fren & Fast Station',
              tags: const ['Stain Logs', 'Dual Tab', 'Defects', 'Rewash'],
              icon: Icons.autorenew_rounded,
              accentColor: AppColors.catRewash,
              accentBg: AppColors.catRewashBg,
              onTap: () => _navigateTo(
                context,
                const RewashScreen(),
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildMobileCategoryColumn(BuildContext context) {
    return Column(
      children: [
        FadeTransition(
          opacity: _card1Fade,
          child: _CategoryCardMobile(
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
        FadeTransition(
          opacity: _card2Fade,
          child: _CategoryCardMobile(
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
        FadeTransition(
          opacity: _card3Fade,
          child: _CategoryCardMobile(
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
      ],
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

// ── Desktop Category Card Component ──────────────────────────────────────────

class _CategoryCardDesktop extends StatefulWidget {
  final String title;
  final String subtitle;
  final String metaLabel;
  final List<String> tags;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;
  final VoidCallback onTap;

  const _CategoryCardDesktop({
    required this.title,
    required this.subtitle,
    required this.metaLabel,
    required this.tags,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
    required this.onTap,
  });

  @override
  State<_CategoryCardDesktop> createState() => _CategoryCardDesktopState();
}

class _CategoryCardDesktopState extends State<_CategoryCardDesktop> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.985 : 1.0;

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
            height: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.surfaceCardHover : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withOpacity(0.45)
                    : AppColors.hairline,
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.accentColor.withOpacity(0.09)
                      : const Color(0x050F172A),
                  blurRadius: _isHovered ? 24 : 10,
                  offset: Offset(0, _isHovered ? 8 : 3),
                ),
                const BoxShadow(
                  color: Color(0x02000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Icon on left, meta badge on right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: widget.accentBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.accentColor.withOpacity(0.25),
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.accentColor,
                        size: 26,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: widget.accentColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Pill tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfacePill,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Push footer to card bottom regardless of tag row count
                const Spacer(),

                // Action Footer Button
                Row(
                  children: [
                    Text(
                      'Open Logbook',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedSlide(
                      duration: AppMotion.quick,
                      offset: _isHovered ? const Offset(0.25, 0) : Offset.zero,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: widget.accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mobile Category Card Component ────────────────────────────────────────────

class _CategoryCardMobile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String metaLabel;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;
  final VoidCallback onTap;

  const _CategoryCardMobile({
    required this.title,
    required this.subtitle,
    required this.metaLabel,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
    required this.onTap,
  });

  @override
  State<_CategoryCardMobile> createState() => _CategoryCardMobileState();
}

class _CategoryCardMobileState extends State<_CategoryCardMobile> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
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
                const BoxShadow(
                  color: Color(0x03000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
