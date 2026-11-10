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
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: AppMotion.easeSmoothOut),
          );
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
      child: Column(
        children: [
          // Top Workbench Header Bar (Edge-aligned, Linear/Airbnb hierarchy)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              children: [
                Material(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.surfaceGlassBorder),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rewash Station',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Log stained or damaged items by group',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.surfaceGlassBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: AppColors.coralAccent, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Add item',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceCard,
                hintText: _selectedTabIndex == 0
                    ? 'Filter Fren rewash items...'
                    : 'Filter Fast rewash items...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 19),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceGlassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceGlassBorder),
                ),
              ),
            ),
          ),

          // List View
          Expanded(
            child: ListView.builder(
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
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: const Border(
                top: BorderSide(color: AppColors.surfaceGlassBorder),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: AppColors.coralAccent,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToSummary,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(
                      'Review & Export',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandMagenta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
