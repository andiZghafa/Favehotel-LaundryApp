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
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    '${widget.categoryName} Summary',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // balance for back button
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total stats banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brandMagenta.withOpacity(0.9),
                          AppColors.brandMagentaDark.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandMagenta.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.categoryName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: AppColors.peachLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Total Items Logged',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                          ),
                          child: Text(
                            '$totalPieces pcs',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Handler Name Card
                  Container(
                    padding: const EdgeInsets.all(20),
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
                            Icon(Icons.person_pin, color: AppColors.coralAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Handler / Housekeeping Person',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _handlerController,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceInput,
                            hintText: 'Enter your name (e.g. Budi, Siti)...',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textMuted),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.surfaceGlassBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.coralAccent, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Items List Breakdown
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceGlassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isRewash ? 'FREN Rewash Items' : 'Item Breakdown',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (activeEntries.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No items entered in this group.',
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
                            'FAST Rewash Items',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (activeSecondaryEntries.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'No items entered in this group.',
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
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.statusSuccess.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.statusSuccess),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.statusSuccess, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Export Successful!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
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

                  const SizedBox(height: 32),

                  // Export Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _handleExport,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.file_download_outlined, size: 22),
                      label: Text(
                        _isExporting ? 'Generating Excel...' : 'Export to Excel (.xlsx)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandMagenta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Return Home button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_outlined, color: AppColors.textSecondary),
                      label: const Text(
                        'Finish & Return to Home',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
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
                      fontStyle: FontStyle.italic,
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
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
