enum RiskLevel { normal, caution, highRisk }

class ScanItem {
  final int scanId;
  final String date;
  final double riskPercent;
  final RiskLevel riskLevel;
  final String summary;

  const ScanItem({
    required this.scanId,
    required this.date,
    required this.riskPercent,
    required this.riskLevel,
    required this.summary,
  });

  factory ScanItem.fromJson(Map<String, dynamic> json) {
    return ScanItem(
      scanId: (json['scan_id'] as num?)?.toInt() ?? 0,
      date: json['date']?.toString() ?? '',
      riskPercent: (json['prob_percent'] as num?)?.toDouble() ?? 0,
      riskLevel: fromApiLabel(json['level']?.toString()),
      summary: json['summary']?.toString() ?? '',
    );
  }

  static RiskLevel fromApiLabel(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'normal':
        return RiskLevel.normal;
      case 'caution':
        return RiskLevel.caution;
      default:
        return RiskLevel.highRisk;
    }
  }

  String get formattedPercent {
    final value = riskPercent % 1 == 0 ? riskPercent.toStringAsFixed(0) : riskPercent.toStringAsFixed(1);
    return '$value%';
  }

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