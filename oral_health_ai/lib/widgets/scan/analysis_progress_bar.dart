import 'package:flutter/material.dart';

class AnalysisProgressBar extends StatelessWidget {
  final double value;

  const AnalysisProgressBar({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);

    return Container(
      width: 190,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2E),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: clamped,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF00C7D8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}