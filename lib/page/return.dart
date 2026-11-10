import 'package:flutter/material.dart';
import 'package:laundry_app/page/rewash_screen.dart';

class ReturnScreen extends StatelessWidget {
  final Map<String, int>? frenItems;
  final Map<String, String>? frenNotes;

  const ReturnScreen({
    super.key,
    this.frenItems,
    this.frenNotes,
  });

  @override
  Widget build(BuildContext context) {
    return const RewashScreen();
  }
}
