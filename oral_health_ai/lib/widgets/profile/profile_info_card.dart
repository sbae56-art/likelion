import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final List<Widget> children;

  const ProfileInfoCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isLast;

  const ProfileInfoRow({
    super.key,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9C9CA3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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