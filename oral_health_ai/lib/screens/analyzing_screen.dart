import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/scan_service.dart';
import 'camera_scan_helpers.dart';
import 'result_screen.dart';
import '../widgets/scan/analysis_progress_bar.dart';
import '../widgets/scan/mouth_guide.dart';

class AnalyzingScreen extends StatefulWidget {
  final XFile imageFile;

  const AnalyzingScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  double progress = 0.0;
  int dotCount = 1;
  Timer? progressTimer;
  Timer? dotTimer;

  @override
  void initState() {
    super.initState();
    _startAnalysis();

    progressTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      setState(() {
        progress += 0.02;
        if (progress >= 0.84) {
          progress = 0.84;
          timer.cancel();
        }
      });
    });

    dotTimer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      setState(() {
        dotCount = dotCount % 3 + 1;
      });
    });
  }

  Future<void> _startAnalysis() async {
    final result = await ScanService.analyzeImage(widget.imageFile);

    if (!mounted) return;

    progressTimer?.cancel();
    dotTimer?.cancel();

    if (result['success'] == true) {
      setState(() {
        progress = 1.0;
      });

      final scanResult = scanResultFromAnalyzeMap(result);

      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: scanResult),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? '분석에 실패했습니다.'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    progressTimer?.cancel();
    dotTimer?.cancel();
    super.dispose();
  }

  String get dots => '.' * dotCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 80),
              Container(
                width: 220,
                height: 180,
                alignment: Alignment.center,
                child: MouthGuide(glowing: true),
              ),
              const SizedBox(height: 30),
              Text(
                'AI is analyzing your scan$dots',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final active = index < dotCount;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF00C7D8)
                          : const Color(0xFF1D2D31),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const Spacer(),
              AnalysisProgressBar(value: progress),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}