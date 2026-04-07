import 'package:flutter/material.dart';

class AuthDividerText extends StatelessWidget {
  final String text;

  const AuthDividerText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFE3E3E7),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFB0B0B5),
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFE3E3E7),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}