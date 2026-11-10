import 'package:flutter/material.dart';
import 'package:laundry_app/page/rewash_screen.dart';

class Return2Screen extends StatelessWidget {
  final Map<String, int>? fastItems;
  final Map<String, String>? fastNotes;

  const Return2Screen({
    super.key,
    this.fastItems,
    this.fastNotes,
  });

  @override
  Widget build(BuildContext context) {
    return const RewashScreen();
  }
}
