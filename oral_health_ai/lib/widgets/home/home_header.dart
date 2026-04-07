import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Ora',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 33,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: 'Q',
                style: TextStyle(
                  color: Color(0xFF0C8A8A),
                  fontSize: 33,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF15979B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}