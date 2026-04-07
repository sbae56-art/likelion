import 'package:flutter/material.dart';
import '../../models/scan_item.dart';
import 'scan_row.dart';

class RecentScansCard extends StatelessWidget {
  final List<ScanItem> scans;

  const RecentScansCard({
    super.key,
    required this.scans,
  });

  @override
  Widget build(BuildContext context) {
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
              ScanRow(item: item),
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