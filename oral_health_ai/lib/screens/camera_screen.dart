import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/scan_item.dart';
import '../models/scan_result_data.dart';
import '../services/scan_service.dart';
import '../widgets/scan/mouth_guide.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _isAnalyzing = false;
  String _analysisMessage = 'Analyzing your scan...';

  RiskLevel _mapRiskLevel(String raw) {
    final level = raw.toLowerCase().trim();
    if (level == 'risk' || level == 'highrisk' || level == 'high_risk') {
      return RiskLevel.highRisk;
    }
    if (level == 'caution' || level == 'warning' || level == 'moderate') {
      return RiskLevel.caution;
    }
    return RiskLevel.normal;
  }

  ScanResultData _toScanResultData(Map<String, dynamic> result) {
    final riskTypeString = result['riskType']?.toString() ?? 'normal';
    final int riskPercent =
        result['riskPercent'] is int ? result['riskPercent'] as int : 0;
    final String summary =
        result['message']?.toString().trim().isNotEmpty == true
            ? result['message'].toString()
            : riskTypeString == 'highRisk'
                ? 'High Risk Detected'
                : riskTypeString == 'caution'
                    ? 'Caution'
                    : 'Normal';

    final detailsRaw = result['details'];
    final recsRaw = result['recommendations'];

    final Map<String, String> details = {};
    if (detailsRaw is Map) {
      for (final entry in detailsRaw.entries) {
        details[entry.key.toString()] = entry.value.toString();
      }
    }

    final List<String> recommendations = [];
    if (recsRaw is List) {
      for (final item in recsRaw) {
        recommendations.add(item.toString());
      }
    }

    return ScanResultData(
      probability: riskPercent.toDouble(),
      riskLevel: _mapRiskLevel(riskTypeString),
      summary: summary,
      details: details,
      recommendations: recommendations,
    );
  }

  Future<void> _analyzePickedFile(XFile photo, String analyzingText) async {
    if (!mounted) return;

    setState(() {
      _isAnalyzing = true;
      _analysisMessage = analyzingText;
    });

    final result = await ScanService.analyzeImage(photo);

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });

    if (result['success'] == true) {
      final scanResult = _toScanResultData(result);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: scanResult),
        ),
      );
      return;
    }

    final errorMessage =
        result['message']?.toString() ?? 'Failed to analyze scan.';

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Analysis Failed'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _takePictureAndAnalyze(BuildContext context) async {
    if (_isAnalyzing) return;

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
    );

    if (photo == null || !context.mounted) return;

    await _analyzePickedFile(photo, 'Analyzing your scan...');
  }

  Future<void> _pickFromGalleryAndAnalyze(BuildContext context) async {
    if (_isAnalyzing) return;

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (photo == null || !context.mounted) return;

    await _analyzePickedFile(photo, 'Analyzing your image...');
  }

  Widget _buildAnalyzingOverlay() {
    if (!_isAnalyzing) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.74),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _analysisMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.only(
              top: 52,
              left: 18,
              right: 18,
              bottom: 14,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _isAnalyzing ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Oral Scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF16171B),
                    Color(0xFF121317),
                    Color(0xFF0E0F12),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, -40),
                      child: const MouthGuide(),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 0.72),
                    child: Text(
                      'Position your mouth within the guide',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.42),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  _buildAnalyzingOverlay(),
                ],
              ),
            ),
          ),
          Container(
            height: 96,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _isAnalyzing ? null : () {},
                  icon: const Icon(
                    Icons.replay_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                GestureDetector(
                  onTap: _isAnalyzing
                      ? null
                      : () => _takePictureAndAnalyze(context),
                  child: Opacity(
                    opacity: _isAnalyzing ? 0.5 : 1,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _isAnalyzing
                      ? null
                      : () => _pickFromGalleryAndAnalyze(context),
                  child: Opacity(
                    opacity: _isAnalyzing ? 0.5 : 1,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.65),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
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