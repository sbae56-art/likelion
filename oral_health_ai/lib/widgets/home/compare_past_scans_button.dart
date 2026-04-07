import 'package:flutter/material.dart';

class ComparePastScansButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ComparePastScansButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.compare_arrows_rounded,
          size: 18,
          color: Color(0xFF0C8A8A),
        ),
        label: const Text(
          'Compare Past Scans',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0C8A8A),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFEFF7F7),
          side: const BorderSide(
            color: Color(0xFFB9DEDE),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}