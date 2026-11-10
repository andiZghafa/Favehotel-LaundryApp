import 'package:flutter/material.dart';
import 'package:laundry_app/page/summary_export_screen.dart';

class Fren2Screen extends StatelessWidget {
  final Map<String, int> frenItems;
  final Map<String, String> frenNotes;
  final Map<String, int>? rewashItems;
  final Map<String, String>? rewashNotes;

  const Fren2Screen({
    super.key,
    required this.frenItems,
    required this.frenNotes,
    this.rewashItems,
    this.rewashNotes,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryExportScreen(
      categoryName: 'FREN',
      items: frenItems,
      notes: frenNotes,
    );
  }
}
