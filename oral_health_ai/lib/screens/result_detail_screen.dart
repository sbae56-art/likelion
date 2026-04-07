import 'package:flutter/material.dart';
import '../widgets/result/oral_map_widget.dart';

class ResultDetailScreen extends StatelessWidget {
  const ResultDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.chevron_left,
                          color: Color(0xFF0C8A8A),
                          size: 22,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: Color(0xFF0C8A8A),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 58),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF0F0F2),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Color(0xFFFF453A),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'High Risk Detected',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF453A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the map to explore findings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA6A6AD),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const OralMapWidget(),
                    const SizedBox(height: 20),
                    _InfoCard(
                      child: Column(
                        children: const [
                          _RiskSummaryHeader(),
                          Divider(height: 1, thickness: 1, color: Color(0xFFEAEAF0)),
                          _DetailMetricRow(label: 'Risk Level', value: '85%', valueColor: Color(0xFFFF453A)),
                          Divider(height: 1, thickness: 1, color: Color(0xFFEAEAF0)),
                          _DetailMetricRow(label: 'Affected Area', value: 'Molar Region', valueColor: Color(0xFF0C8A8A)),
                          Divider(height: 1, thickness: 1, color: Color(0xFFEAEAF0)),
                          _DetailMetricRow(label: 'Confidence', value: 'High', valueColor: Color(0xFF0C8A8A), isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFE1DD),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFF7A6E),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Issue detected in lower right quadrant',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Early detection is key — schedule an exam soon',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFB2B2B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _PrimaryButton(
                      text: 'View Detailed Report',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Scan Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0C8A8A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'This is not a medical diagnosis. Please consult\na healthcare professional for medical advice.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFFC0C0C6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _RiskSummaryHeader extends StatelessWidget {
  const _RiskSummaryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF453A),
                width: 1.8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lower Right Quadrant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Abnormal tissue pattern detected',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA6A6AD),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isLast;

  const _DetailMetricRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 14, 14, isLast ? 16 : 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF067E80),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0x33067E80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}