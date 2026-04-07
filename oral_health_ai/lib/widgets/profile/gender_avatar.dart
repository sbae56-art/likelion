import 'package:flutter/material.dart';
import '../../models/user_profile.dart';

class GenderAvatar extends StatelessWidget {
  final GenderType gender;
  final double size;
  final String? imagePath;

  const GenderAvatar({
    super.key,
    required this.gender,
    this.size = 92,
    this.imagePath,
  });

  Color _startColor() {
    switch (gender) {
      case GenderType.male:
        return const Color(0xFF2E58B7);
      case GenderType.female:
        return const Color(0xFFE2D30F);
      case GenderType.other:
        return const Color(0xFF1499A2);
    }
  }

  Color _endColor() {
    switch (gender) {
      case GenderType.male:
        return const Color(0xFF5A88E5);
      case GenderType.female:
        return const Color(0xFFE8E38C);
      case GenderType.other:
        return const Color(0xFF60D2CF);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(imagePath!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_startColor(), _endColor()],
        ),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.45,
        color: Colors.white,
      ),
    );
  }
}