import 'package:flutter/material.dart';

enum ScanResultType { normal, caution, highRisk }

class ResultScreen extends StatelessWidget {
  final ScanResultType type;

  const ResultScreen({
    super.key,
    required this.type,
  });

  _ResultConfig _getConfig() {
    switch (type) {
      case ScanResultType.normal:
        return _ResultConfig(
          type: type,
          title: 'Normal',
          subtitle: 'No signs of concern detected.',
          percent: null,
          accentColor: const Color(0xFF0C8A8A),
          iconBgColor: const Color(0xFFE8F2F2),
          primaryButtonText: 'View Oral Care Tips',
          bottomSectionTitle: 'RECOMMENDATIONS',
          details: const [
            _DetailItem('Teeth', 'Excellent', Color(0xFF0C8A8A)),
            _DetailItem('Gums', 'Healthy', Color(0xFF0C8A8A)),
            _DetailItem('Plaque', 'Very Low', Color(0xFF0C8A8A)),
            _DetailItem('Overall Risk', 'Low', Color(0xFF0C8A8A)),
          ],
          steps: const [
            'Brush twice daily with fluoride toothpaste',
            'Floss at least once a day',
            'Schedule your next check-up in 6 months',
          ],
          showDisclaimer: false,
        );

      case ScanResultType.caution:
        return _ResultConfig(
          type: type,
          title: 'Observation\nRecommended',
          subtitle:
              'Minor concerns detected. Maintain careful\noral hygiene.',
          percent: 45,
          accentColor: const Color(0xFFFF9500),
          iconBgColor: null,
          primaryButtonText: 'View Oral Care Tips',
          bottomSectionTitle: 'RECOMMENDATIONS',
          details: const [
            _DetailItem('Teeth', 'Good', Color(0xFF0C8A8A)),
            _DetailItem('Gums', 'Slight Concern', Color(0xFFFF9500)),
            _DetailItem('Plaque', 'Moderate', Color(0xFFFF9500)),
            _DetailItem('Overall Risk', 'Moderate', Color(0xFFFF9500)),
          ],
          steps: const [
            'Maintain careful hygiene practices',
            'Re-check in 2 weeks',
            'Monitor for any changes',
          ],
          showDisclaimer: false,
        );

      case ScanResultType.highRisk:
        return _ResultConfig(
          type: type,
          title: 'High Risk Detected',
          subtitle:
              'Early detection is key. We recommend\nseeing a specialist.',
          percent: 85,
          accentColor: const Color(0xFFFF453A),
          iconBgColor: null,
          primaryButtonText: 'Find Specialist',
          bottomSectionTitle: 'NEXT STEPS',
          details: const [
            _DetailItem('Teeth', 'Concern Found', Color(0xFFFF453A)),
            _DetailItem('Gums', 'Needs Care', Color(0xFFFF9500)),
            _DetailItem('Plaque', 'Moderate', Color(0xFFFF9500)),
            _DetailItem('Overall Risk', 'High', Color(0xFFFF453A)),
          ],
          steps: const [
            'Schedule a professional examination',
            'Avoid hard or sticky foods',
            'Use a prescribed antibacterial rinse',
          ],
          showDisclaimer: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

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
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  children: [
                    _buildTopResult(config),
                    const SizedBox(height: 26),
                    _SectionTitle(title: 'DETAILS'),
                    const SizedBox(height: 10),
                    _CardContainer(
                      child: Column(
                        children: List.generate(config.details.length, (index) {
                          final item = config.details[index];
                          final isLast = index == config.details.length - 1;
                          return _DetailRow(
                            label: item.label,
                            value: item.value,
                            valueColor: item.color,
                            isLast: isLast,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _SectionTitle(title: config.bottomSectionTitle),
                    const SizedBox(height: 10),
                    _CardContainer(
                      child: Column(
                        children: List.generate(config.steps.length, (index) {
                          final isLast = index == config.steps.length - 1;
                          return _StepRow(
                            index: index + 1,
                            text: config.steps[index],
                            isLast: isLast,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _PrimaryButton(
                      text: config.primaryButtonText,
                      onPressed: () {
                        // TODO: 팁 화면 또는 병원 연결
                      },
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Scan Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0C8A8A),
                        ),
                      ),
                    ),
                    if (config.showDisclaimer) ...[
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopResult(_ResultConfig config) {
    if (config.type == ScanResultType.normal) {
      return Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: config.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 36,
              color: Color(0xFF0C8A8A),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            config.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            config.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Color(0xFFA3A3AA),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          '${config.percent}%',
          style: TextStyle(
            fontSize: 58,
            height: 1,
            fontWeight: FontWeight.w800,
            color: config.accentColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          config.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          config.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Color(0xFFA3A3AA),
          ),
        ),
      ],
    );
  }
}

class _ResultConfig {
  final ScanResultType type;
  final String title;
  final String subtitle;
  final int? percent;
  final Color accentColor;
  final Color? iconBgColor;
  final String primaryButtonText;
  final String bottomSectionTitle;
  final List<_DetailItem> details;
  final List<String> steps;
  final bool showDisclaimer;

  const _ResultConfig({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.accentColor,
    required this.iconBgColor,
    required this.primaryButtonText,
    required this.bottomSectionTitle,
    required this.details,
    required this.steps,
    required this.showDisclaimer,
  });
}

class _DetailItem {
  final String label;
  final String value;
  final Color color;

  const _DetailItem(this.label, this.value, this.color);
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9B9BA1),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFEAEAF0),
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String text;
  final bool isLast;

  const _StepRow({
    required this.index,
    required this.text,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$index.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFADADB4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFEAEAF0),
          ),
      ],
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