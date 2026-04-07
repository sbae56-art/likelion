import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String lastScanResult;
  final int totalScans;

  const SummaryCard({
    super.key,
    required this.lastScanResult,
    required this.totalScans,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryBlock(
              label: 'Last scan result',
              value: lastScanResult,
              alignRight: false,
            ),
          ),
          Expanded(
            child: _SummaryBlock(
              label: 'Total scans',
              value: totalScans.toString(),
              alignRight: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool alignRight;

  const _SummaryBlock({
    required this.label,
    required this.value,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA6A6AD),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}