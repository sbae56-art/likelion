import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/scan/analysis_progress_bar.dart';
import '../widgets/scan/mouth_guide.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

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