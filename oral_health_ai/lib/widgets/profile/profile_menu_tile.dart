import 'package:flutter/material.dart';

class ProfileMenuTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLast;
  final bool isLogout;

  const ProfileMenuTile({
    super.key,
    required this.title,
    required this.onTap,
    this.isLast = false,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isLogout ? const Color(0xFFFF5B4D) : Colors.black;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (!isLogout)
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFC2C2C7),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE8E8EC),
          ),
      ],
    );
  }
}