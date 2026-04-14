import 'package:flutter/material.dart';
import '../../models/scan_item.dart';
import 'scan_row.dart';

class RecentScansCard extends StatelessWidget {
  final List<ScanItem> scans;
  final ValueChanged<ScanItem>? onTap;

  const RecentScansCard({
    super.key,
    required this.scans,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Text(
          'No scans yet. Take your first oral scan to see results here.',
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Color(0xFF8F8F95),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: List.generate(scans.length, (index) {
          final item = scans[index];
          final isLast = index == scans.length - 1;

          return Column(
            children: [
              ScanRow(
                item: item,
                onTap: onTap == null ? null : () => onTap!(item),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEAEAF0),
                ),
            ],
          );
        }),
      ),
    );
  }
}