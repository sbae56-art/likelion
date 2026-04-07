import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C8A8A),
          disabledBackgroundColor: const Color(0xFFA8D1D1),
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}