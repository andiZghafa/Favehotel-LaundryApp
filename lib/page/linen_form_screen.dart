import 'package:flutter/material.dart';
import 'package:laundry_app/models/linen_models.dart';
import 'package:laundry_app/page/summary_export_screen.dart';
import 'package:laundry_app/theme/app_theme.dart';
import 'package:laundry_app/widgets/app_background.dart';
import 'package:laundry_app/widgets/app_dialogs.dart';
import 'package:laundry_app/widgets/linen_counter_card.dart';

class LinenFormScreen extends StatefulWidget {
  final LinenCategory category;

  const LinenFormScreen({
    super.key,
    required this.category,
  });

  @override
  State<LinenFormScreen> createState() => _LinenFormScreenState();
}

class _LinenFormScreenState extends State<LinenFormScreen> {
  late List<String> _itemList;
  final Map<String, int> _items = {};
  final Map<String, String> _notes = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _itemList = List.from(widget.category.defaultItems);
    for (var item in _itemList) {
      _items[item] = 0;
      _notes[item] = '';
    }
  }

  int get totalPieces {
    int total = 0;
    _items.forEach((_, count) => total += count);
    return total;
  }

  void _navigateDirectToSummary() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SummaryExportScreen(
          categoryName: widget.category.title,
          items: _items,
          notes: _notes,
          isRewash: false,
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
    final filteredItems = _itemList.where((item) {
      return item.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final catColor = widget.category == LinenCategory.fren
        ? AppColors.catFren
        : AppColors.catFast;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.displayTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.category.subtitle,
                        style: const TextStyle(
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
                // Add Custom Item Action Button
                Material(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final newItem = await AppDialogs.showAddItemDialog(context);
                      if (newItem != null && newItem.isNotEmpty && !_items.containsKey(newItem)) {
                        setState(() {
                          _itemList.add(newItem);
                          _items[newItem] = 0;
                          _notes[newItem] = '';
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

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceCard,
                hintText: 'Filter ${widget.category.displayTitle.toLowerCase()}...',
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

          // Item List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return LinenCounterCard(
                  key: ValueKey(item),
                  itemName: item,
                  count: _items[item] ?? 0,
                  note: _notes[item] ?? '',
                  isRewash: false,
                  onCountChanged: (newCount) {
                    setState(() => _items[item] = newCount);
                  },
                  onNoteChanged: (newNote) {
                    setState(() => _notes[item] = newNote);
                  },
                );
              },
            ),
          ),

          // Bottom Floating Bar (Concentric outer radius = 24, padding = 14, inner = 12)
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
                      'Total pieces',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$totalPieces pcs',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateDirectToSummary,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(
                      'Review & Export',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: catColor,
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
