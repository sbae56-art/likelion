import 'package:flutter/material.dart';
import '../../models/scan_item.dart';

class ScanRow extends StatelessWidget {
  final ScanItem item;

  const ScanRow({
    super.key,
    required this.item,
  });

  Color _dotColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.normal:
        return const Color(0xFF35C759);
      case RiskLevel.caution:
        return const Color(0xFFFF9F0A);
      case RiskLevel.highRisk:
        return const Color(0xFFFF453A);
    }
  }

  Color _chipBgColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.normal:
        return const Color(0xFFEAF7EE);
      case RiskLevel.caution:
        return const Color(0xFFFFF1DE);
      case RiskLevel.highRisk:
        return const Color(0xFFFFE7EA);
    }
  }

  Color _chipTextColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.normal:
        return const Color(0xFF35C759);
      case RiskLevel.caution:
        return const Color(0xFFFF9F0A);
      case RiskLevel.highRisk:
        return const Color(0xFFFF5B66);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _dotColor(item.riskLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${item.riskPercent}%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _chipBgColor(item.riskLevel),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _chipTextColor(item.riskLevel),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Color(0xFFD0D0D5),
          ),
        ],
      ),
    );
  }
}