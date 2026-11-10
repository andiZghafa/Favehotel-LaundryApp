import 'package:flutter/material.dart';
import 'package:laundry_app/models/linen_models.dart';
import 'package:laundry_app/page/linen_form_screen.dart';

class FastScreen extends StatelessWidget {
  const FastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LinenFormScreen(category: LinenCategory.fast);
  }
}
