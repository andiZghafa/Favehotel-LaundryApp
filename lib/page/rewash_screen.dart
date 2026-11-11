import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:laundry_app/models/linen_models.dart';
import 'package:laundry_app/page/summary_export_screen.dart';
import 'package:laundry_app/theme/app_theme.dart';
import 'package:laundry_app/widgets/app_background.dart';
import 'package:laundry_app/widgets/app_dialogs.dart';
import 'package:laundry_app/widgets/custom_tab_bar.dart';
import 'package:laundry_app/widgets/linen_counter_card.dart';

class RewashScreen extends StatefulWidget {
  const RewashScreen({super.key});

  @override
  State<RewashScreen> createState() => _RewashScreenState();
}

class _RewashScreenState extends State<RewashScreen> {
  int _selectedTabIndex = 0; // 0: Fren Linen, 1: Fast Items
  String _searchQuery = '';

  late List<String> _frenItemsList;
  late List<String> _fastItemsList;

  final Map<String, int> _frenRewashItems = {};
  final Map<String, String> _frenRewashNotes = {};

  final Map<String, int> _fastRewashItems = {};
  final Map<String, String> _fastRewashNotes = {};

  @override
  void initState() {
    super.initState();
    _frenItemsList = List.from(LinenCategory.fren.defaultItems);
    for (var item in _frenItemsList) {
      _frenRewashItems[item] = 0;
      _frenRewashNotes[item] = '';
    }

    _fastItemsList = List.from(LinenCategory.fast.defaultItems);
    for (var item in _fastItemsList) {
      _fastRewashItems[item] = 0;
      _fastRewashNotes[item] = '';
    }
  }

  int get totalFrenRewash {
    int sum = 0;
    _frenRewashItems.forEach((_, count) => sum += count);
    return sum;
  }

  int get totalFastRewash {
    int sum = 0;
    _fastRewashItems.forEach((_, count) => sum += count);
    return sum;
  }

  int get totalRewashPieces => totalFrenRewash + totalFastRewash;

  void _navigateToSummary() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SummaryExportScreen(
          categoryName: 'REWASH',
          items: _frenRewashItems,
          notes: _frenRewashNotes,
          isRewash: true,
          secondaryItems: _fastRewashItems,
          secondaryNotes: _fastRewashNotes,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0.04, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: AppMotion.easeSmoothOut));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: AppMotion.fast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeList = _selectedTabIndex == 0 ? _frenItemsList : _fastItemsList;
    final activeMap = _selectedTabIndex == 0 ? _frenRewashItems : _fastRewashItems;
    final activeNotes = _selectedTabIndex == 0 ? _frenRewashNotes : _fastRewashNotes;

    final filteredItems = activeList.where((item) {
      return item.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return AppBackground(
      maxWidth: 1140,
      child: Column(
        children: [
          // Top Workbench Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
            child: Row(
              children: [
                Material(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.hairline),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rewash Station',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Log stained, torn, or defective linens by category',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final newItem = await AppDialogs.showAddItemDialog(context);
                      if (newItem != null && newItem.isNotEmpty) {
                        setState(() {
                          if (_selectedTabIndex == 0) {
                            if (!_frenRewashItems.containsKey(newItem)) {
                              _frenItemsList.add(newItem);
                              _frenRewashItems[newItem] = 0;
                              _frenRewashNotes[newItem] = '';
                            }
                          } else {
                            if (!_fastRewashItems.containsKey(newItem)) {
                              _fastItemsList.add(newItem);
                              _fastRewashItems[newItem] = 0;
                              _fastRewashNotes[newItem] = '';
                            }
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.hairline),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: AppColors.coralAccent, size: 18),
                          SizedBox(width: 5),
                          Text(
                            'Add item',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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

          // Sliding Segmented Tab Bar (Option A)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
            child: CustomSlidingTabBar(
              selectedIndex: _selectedTabIndex,
              tabs: const ['Fren Linen', 'Fast Items'],
              itemCounts: [totalFrenRewash, totalFastRewash],
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                  _searchQuery = '';
                });
              },
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceCard,
                hintText: _selectedTabIndex == 0
                    ? 'Filter Fren rewash items...'
                    : 'Filter Fast rewash items...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.hairline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.hairline),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: AppColors.coralAccent, width: 1.5),
                ),
              ),
            ),
          ),

          // Responsive Item Grid (2 columns on desktop >= 768, 1 column on mobile)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 768;

                if (isWide) {
                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 148,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return LinenCounterCard(
                        key: ValueKey('${_selectedTabIndex}_$item'),
                        itemName: item,
                        count: activeMap[item] ?? 0,
                        note: activeNotes[item] ?? '',
                        isRewash: true,
                        onCountChanged: (newCount) {
                          setState(() => activeMap[item] = newCount);
                        },
                        onNoteChanged: (newNote) {
                          setState(() => activeNotes[item] = newNote);
                        },
                      );
                    },
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return LinenCounterCard(
                      key: ValueKey('${_selectedTabIndex}_$item'),
                      itemName: item,
                      count: activeMap[item] ?? 0,
                      note: activeNotes[item] ?? '',
                      isRewash: true,
                      onCountChanged: (newCount) {
                        setState(() => activeMap[item] = newCount);
                      },
                      onNoteChanged: (newNote) {
                        setState(() => activeNotes[item] = newNote);
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: const Border(
                top: BorderSide(color: AppColors.hairline),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C0F172A),
                  blurRadius: 20,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total rewash',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$totalRewashPieces pcs',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppColors.coralAccent,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToSummary,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(
                      'Review & Export',
                      style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coralAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
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
