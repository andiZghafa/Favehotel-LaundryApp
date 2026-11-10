import 'package:flutter/material.dart';
import 'package:laundry_app/page/home.dart';
import 'package:laundry_app/services/excel_service.dart';
import 'package:laundry_app/theme/app_theme.dart';
import 'package:laundry_app/widgets/app_background.dart';

class SummaryExportScreen extends StatefulWidget {
  final String categoryName;
  final Map<String, int> items;
  final Map<String, String> notes;
  final bool isRewash;

  // For Rewash category with dual tabs (Option A)
  final Map<String, int>? secondaryItems;
  final Map<String, String>? secondaryNotes;

  const SummaryExportScreen({
    super.key,
    required this.categoryName,
    required this.items,
    required this.notes,
    this.isRewash = false,
    this.secondaryItems,
    this.secondaryNotes,
  });

  @override
  State<SummaryExportScreen> createState() => _SummaryExportScreenState();
}

class _SummaryExportScreenState extends State<SummaryExportScreen> {
  final TextEditingController _handlerController = TextEditingController();
  bool _isExporting = false;
  ExcelExportResult? _lastResult;

  @override
  void dispose() {
    _handlerController.dispose();
    super.dispose();
  }

  int get totalPieces {
    int total = 0;
    widget.items.forEach((_, count) => total += count);
    if (widget.secondaryItems != null) {
      widget.secondaryItems!.forEach((_, count) => total += count);
    }
    return total;
  }

  String get _friendlyCategoryLabel {
    switch (widget.categoryName.toUpperCase()) {
      case 'FREN':
        return 'Fren Linen';
      case 'FAST':
        return 'Fast Items';
      case 'REWASH':
        return 'Rewash Station';
      default:
        return widget.categoryName;
    }
  }

  Future<void> _handleExport() async {
    final handler = _handlerController.text.trim();
    if (handler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Please enter the Handler name first.'),
            ],
          ),
          backgroundColor: AppColors.statusWarning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
      _lastResult = null;
    });

    ExcelExportResult result;
    if (widget.isRewash) {
      result = await ExcelExportService.exportRewashLog(
        handlerName: handler,
        frenRewashItems: widget.items,
        frenRewashNotes: widget.notes,
        fastRewashItems: widget.secondaryItems ?? {},
        fastRewashNotes: widget.secondaryNotes ?? {},
      );
    } else {
      result = await ExcelExportService.exportSingleCategory(
        categoryName: widget.categoryName,
        handlerName: handler,
        items: widget.items,
        notes: widget.notes,
      );
    }

    setState(() {
      _isExporting = false;
      _lastResult = result;
    });

    if (result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(result.message)),
            ],
          ),
          backgroundColor: AppColors.statusSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeEntries = widget.items.entries
        .where((e) => e.value > 0 || (widget.notes[e.key]?.isNotEmpty ?? false))
        .toList();

    final activeSecondaryEntries = (widget.secondaryItems?.entries ?? [])
        .where((e) => e.value > 0 || (widget.secondaryNotes?[e.key]?.isNotEmpty ?? false))
        .toList();

    return AppBackground(
      child: Column(
        children: [
          // Top Workbench Header Bar
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
                      const Text(
                        'Review & Export',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$_friendlyCategoryLabel worksheet',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total stats banner (Concentric outer radius = 20, padding = 18, inner = 12)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brandMagenta.withOpacity(0.92),
                          AppColors.brandMagentaDark.withOpacity(0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _friendlyCategoryLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.peachLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Total items logged',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.28)),
                          ),
                          child: Text(
                            '$totalPieces pcs',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: Colors.white,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Handler Name Card (Concentric outer = 20, padding = 18, inner = 12)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceGlassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_outline_rounded, color: AppColors.coralAccent, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Housekeeping handler',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _handlerController,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceInput,
                            hintText: 'Enter staff name (e.g. Budi, Siti)...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                            prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textMuted, size: 19),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.surfaceGlassBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.coralAccent, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Items List Breakdown
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceGlassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isRewash ? 'Fren Linen Rewash' : 'Item breakdown',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (activeEntries.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              'No items logged in this group.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          )
                        else
                          ...activeEntries.map((e) {
                            final note = widget.notes[e.key];
                            return _buildItemRow(e.key, e.value, note);
                          }),

                        if (widget.isRewash) ...[
                          const Divider(color: AppColors.surfaceGlassBorder, height: 28),
                          const Text(
                            'Fast Items Rewash',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (activeSecondaryEntries.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0),
                              child: Text(
                                'No items logged in this group.',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            )
                          else
                            ...activeSecondaryEntries.map((e) {
                              final note = widget.secondaryNotes?[e.key];
                              return _buildItemRow(e.key, e.value, note);
                            }),
                        ],
                      ],
                    ),
                  ),

                  if (_lastResult != null && _lastResult!.success) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.statusSuccess.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.statusSuccess.withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.statusSuccess, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Export complete',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _lastResult!.message,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Export Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _handleExport,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.file_download_outlined, size: 20),
                      label: Text(
                        _isExporting ? 'Generating Excel...' : 'Export to Excel (.xlsx)',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandMagenta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Return Home button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_outlined, color: AppColors.textSecondary, size: 18),
                      label: const Text(
                        'Return to Home',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String name, int qty, String? note) {
    final hasNote = note != null && note.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasNote)
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.coralAccent,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceInput,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$qty',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
