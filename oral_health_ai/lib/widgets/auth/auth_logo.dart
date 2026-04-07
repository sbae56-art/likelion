import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Ora',
            style: TextStyle(
              color: Colors.black,
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'Q',
            style: TextStyle(
              color: Color(0xFF0C8A8A),
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}