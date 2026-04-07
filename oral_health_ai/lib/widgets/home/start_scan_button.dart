import 'package:flutter/material.dart';

class StartScanButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StartScanButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF067E80),
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: const Color(0x55067E80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Start New Scan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}