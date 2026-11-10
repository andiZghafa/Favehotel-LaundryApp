import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/models/linen_models.dart';
import 'package:laundry_app/page/linen_form_screen.dart';
import 'package:laundry_app/page/rewash_screen.dart';
import 'package:laundry_app/theme/app_theme.dart';
import 'package:laundry_app/widgets/app_background.dart';

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

    // Staggered entrances (better-ui / transitions-dev stagger rules)
    _headerFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: AppMotion.easeSmoothOut),
    );

    _card1Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.65, curve: AppMotion.easeSmoothOut),
    );

    _card2Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.8, curve: AppMotion.easeSmoothOut),
    );

    _card3Fade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.5, 0.95, curve: AppMotion.easeSmoothOut),
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
          const begin = Offset(0.06, 0.0);
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
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(now);

    return AppBackground(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Header Section with Staggered Entrance
            FadeTransition(
              opacity: _headerFade,
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandMagenta.withOpacity(0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/IKON.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.local_laundry_service,
                        size: 55,
                        color: AppColors.brandMagenta,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'HOUSEKEEPING',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'LAUNDRY LOGBOOK MANAGEMENT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                      color: AppColors.peachLight,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceGlassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.coralAccent),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Category 1: FREN Card
            FadeTransition(
              opacity: _card1Fade,
              child: _CategoryMenuCard(
                title: '1. FREN',
                subtitle: 'Bedding, Duvets, Sheets & Bath Linens',
                itemCountSummary: '8 standard linen items',
                icon: Icons.king_bed_outlined,
                accentColor: AppColors.brandMagenta,
                onTap: () => _navigateTo(
                  context,
                  const LinenFormScreen(category: LinenCategory.fren),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category 2: FAST Card
            FadeTransition(
              opacity: _card2Fade,
              child: _CategoryMenuCard(
                title: '2. FAST',
                subtitle: 'F&B Linens, Mukena, Sejadah, Sarung & Flags',
                itemCountSummary: '6 specialized items',
                icon: Icons.dry_cleaning_outlined,
                accentColor: AppColors.purpleDeep,
                onTap: () => _navigateTo(
                  context,
                  const LinenFormScreen(category: LinenCategory.fast),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category 3: REWASH Card (Standalone Category)
            FadeTransition(
              opacity: _card3Fade,
              child: _CategoryMenuCard(
                title: '3. REWASH',
                subtitle: 'Dedicated Station for Stained & Defective Linens',
                itemCountSummary: 'FREN & FAST stain logging',
                icon: Icons.autorenew_rounded,
                accentColor: AppColors.coralAccent,
                badgeText: 'STANDALONE',
                onTap: () => _navigateTo(
                  context,
                  const RewashScreen(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Exit App Button
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surfaceCard,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Exit Application', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Are you sure you want to close the Housekeeping Logbook?',
                      style: TextStyle(color: AppColors.textSecondary),
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
                        ),
                        child: const Text('Exit'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.exit_to_app_rounded, size: 18, color: AppColors.textMuted),
              label: const Text(
                'Exit App',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryMenuCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String itemCountSummary;
  final IconData icon;
  final Color accentColor;
  final String? badgeText;
  final VoidCallback onTap;

  const _CategoryMenuCard({
    required this.title,
    required this.subtitle,
    required this.itemCountSummary,
    required this.icon,
    required this.accentColor,
    this.badgeText,
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
    // Exact better-ui rule: Press scales to 0.96 over 150ms with ease-out
    final double scale = _isPressed ? 0.96 : (_isHovered ? 1.015 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
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
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.surfaceCardLight : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withOpacity(0.7)
                    : AppColors.surfaceGlassBorder,
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.accentColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: Offset(0, _isHovered ? 8 : 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Concentric Icon Avatar (R_outer = R_inner + padding)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.accentColor.withOpacity(0.5)),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (widget.badgeText != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: widget.accentColor, width: 0.8),
                                ),
                                child: Text(
                                  widget.badgeText!,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: widget.accentColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.itemCountSummary,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  AnimatedSlide(
                    duration: AppMotion.quick,
                    offset: _isHovered ? const Offset(0.2, 0) : Offset.zero,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: _isHovered ? AppColors.coralAccent : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
