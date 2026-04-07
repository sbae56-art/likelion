enum RiskLevel { normal, caution, highRisk }

class ScanItem {
  final String date;
  final int riskPercent;
  final RiskLevel riskLevel;

  const ScanItem({
    required this.date,
    required this.riskPercent,
    required this.riskLevel,
  });

  String get label {
    switch (riskLevel) {
      case RiskLevel.normal:
        return 'Normal';
      case RiskLevel.caution:
        return 'Caution';
      case RiskLevel.highRisk:
        return 'High Risk';
    }
  }
}