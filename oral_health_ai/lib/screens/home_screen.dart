import 'package:flutter/material.dart';
import '../models/scan_item.dart';
import '../widgets/home/compare_past_scans_button.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/recent_scans_card.dart';
import '../widgets/home/start_scan_button.dart';
import '../widgets/home/summary_card.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<ScanItem> scans = const [
    ScanItem(
      date: 'Feb 20, 2026',
      riskPercent: 12,
      riskLevel: RiskLevel.normal,
    ),
    ScanItem(
      date: 'Feb 14, 2026',
      riskPercent: 45,
      riskLevel: RiskLevel.caution,
    ),
    ScanItem(
      date: 'Feb 8, 2026',
      riskPercent: 85,
      riskLevel: RiskLevel.highRisk,
    ),
    ScanItem(
      date: 'Jan 30, 2026',
      riskPercent: 8,
      riskLevel: RiskLevel.normal,
    ),
    ScanItem(
      date: 'Jan 22, 2026',
      riskPercent: 5,
      riskLevel: RiskLevel.normal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                onProfileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              SummaryCard(
                lastScanResult: scans.first.label,
                totalScans: scans.length,
              ),
              const SizedBox(height: 18),
              ComparePastScansButton(
                onPressed: () {
                  // TODO: 비교 화면 연결
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'RECENT SCANS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9B9BA1),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              RecentScansCard(scans: scans),
              const Spacer(),
              StartScanButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CameraScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}