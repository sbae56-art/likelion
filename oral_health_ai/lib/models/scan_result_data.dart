import 'scan_item.dart';

class ScanResultData {
  final double probability;
  final RiskLevel riskLevel;
  final String summary;
  final Map<String, String> details;
  final List<String> recommendations;

  const ScanResultData({
    required this.probability,
    required this.riskLevel,
    required this.summary,
    required this.details,
    required this.recommendations,
  });

  factory ScanResultData.fromPredictResponse(Map<String, dynamic> json) {
    return ScanResultData(
      probability: (json['prob_percent'] as num?)?.toDouble() ?? 0,
      riskLevel: ScanItem.fromApiLabel(json['level']?.toString()),
      summary: json['summary']?.toString() ?? '',
      details: _readDetails(json['details']),
      recommendations: _readRecommendations(json['recommendations']),
    );
  }

  factory ScanResultData.fromDetailResponse(Map<String, dynamic> json) {
    return ScanResultData(
      probability: (json['probability'] as num?)?.toDouble() ?? 0,
      riskLevel: ScanItem.fromApiLabel(json['status_labels']?.toString()),
      summary: json['status_labels']?.toString() ?? '',
      details: _readDetails(json['details']),
      recommendations: _readRecommendations(json['advice_list']),
    );
  }

  static Map<String, String> _readDetails(dynamic rawDetails) {
    if (rawDetails is Map<String, dynamic>) {
      return rawDetails.map((key, value) => MapEntry(key, value.toString()));
    }

    if (rawDetails is Map) {
      return rawDetails.map((key, value) => MapEntry(key.toString(), value.toString()));
    }

    return const {};
  }

  static List<String> _readRecommendations(dynamic rawRecommendations) {
    if (rawRecommendations is List) {
      return rawRecommendations.map((item) => item.toString()).toList();
    }

    return const [];
  }
}
