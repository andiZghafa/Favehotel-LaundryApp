import 'package:flutter/material.dart';

class ScrollToContinueWidget extends StatelessWidget {
  const ScrollToContinueWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Scroll up to continue',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 8),
        Icon(Icons.arrow_upward, color: Colors.grey[400], size: 20),
      ],
    );
  }
}
