import 'package:flutter/material.dart';
import 'package:laundry_app/theme/app_theme.dart';

class CustomSlidingTabBar extends StatelessWidget {
  final int selectedIndex;
  final List<String> tabs;
  final List<int>? itemCounts;
  final ValueChanged<int> onTabSelected;

  const CustomSlidingTabBar({
    super.key,
    required this.selectedIndex,
    required this.tabs,
    this.itemCounts,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceGlassBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth) / tabs.length;

          return Stack(
            children: [
              // Sliding Active Pill Indicator
              AnimatedPositioned(
                duration: AppMotion.fast,
                curve: AppMotion.easeSmoothOut,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brandMagenta, AppColors.brandMagentaDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandMagenta.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab text buttons
              Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = selectedIndex == index;
                  final count = itemCounts != null && index < itemCounts!.length ? itemCounts![index] : 0;

                  return Expanded(
                    child: InkWell(
                      onTap: () => onTabSelected(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tabs[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.coralAccent : AppColors.surfaceCardLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.black87 : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
