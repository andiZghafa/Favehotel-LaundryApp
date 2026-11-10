import 'package:flutter/material.dart';
import 'package:laundry_app/page/summary_export_screen.dart';

class Fast2Screen extends StatelessWidget {
  final Map<String, int> fastItems;
  final Map<String, String> fastNotes;
  final Map<String, int>? rewashItems;
  final Map<String, String>? rewashNotes;

  const Fast2Screen({
    super.key,
    required this.fastItems,
    required this.fastNotes,
    this.rewashItems,
    this.rewashNotes,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryExportScreen(
      categoryName: 'FAST',
      items: fastItems,
      notes: fastNotes,
    );
  }
}
