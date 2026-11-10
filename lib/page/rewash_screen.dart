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
  int _selectedTabIndex = 0; // 0: FREN, 1: FAST
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
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Column(
                    children: [
                      Text(
                        'REWASH STATION',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Separate Stained & Defective Linens',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.peachLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.coralAccent, size: 24),
                  tooltip: 'Add Custom Item',
                  onPressed: () async {
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
                ),
              ],
            ),
          ),

          // Sliding Segmented Tab Bar (Option A)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: CustomSlidingTabBar(
              selectedIndex: _selectedTabIndex,
              tabs: const ['FREN LINEN', 'FAST ITEMS'],
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceCard,
                hintText: _selectedTabIndex == 0
                    ? 'Search FREN rewash items...'
                    : 'Search FAST rewash items...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.surfaceGlassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.surfaceGlassBorder),
                ),
              ),
            ),
          ),

          // List View
          Expanded(
            child: ListView.builder(
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
                  color: Colors.black.withOpacity(0.3),
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
                      'TOTAL REWASH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '$totalRewashPieces pcs',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.coralAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToSummary,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: const Text(
                      'Review & Export Rewash',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandMagenta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
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
