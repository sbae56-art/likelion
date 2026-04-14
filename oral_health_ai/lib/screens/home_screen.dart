import 'package:flutter/material.dart';
import '../models/scan_item.dart';
import '../models/scan_result_data.dart';
import '../services/scan_service.dart';
import '../widgets/home/compare_past_scans_button.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/recent_scans_card.dart';
import '../widgets/home/start_scan_button.dart';
import '../widgets/home/summary_card.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';
import 'result_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ScanItem> scans = const [];
  bool isLoading = true;
  bool isOpeningDetail = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
    });

    final result = await ScanService.getHistory();
    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final recentScans = (data['recent_scans'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ScanItem.fromJson)
          .toList();

      setState(() {
        scans = recentScans;
        isLoading = false;
      });
      return;
    }

    setState(() {
      scans = const [];
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? '히스토리를 불러오지 못했습니다.'),
      ),
    );
  }

  Future<void> _openScanDetail(ScanItem item) async {
    if (isOpeningDetail) return;

    setState(() {
      isOpeningDetail = true;
    });

    final result = await ScanService.getScanDetail(item.scanId);
    if (!mounted) return;

    setState(() {
      isOpeningDetail = false;
    });

    if (result['success'] == true) {
      final detail = ScanResultData.fromDetailResponse(
        result['data'] as Map<String, dynamic>,
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultDetailScreen(result: detail),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? '상세 결과를 불러오지 못했습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestLabel = scans.isEmpty ? 'No scans yet' : scans.first.label;

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
                lastScanResult: latestLabel,
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
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0C8A8A),
                    ),
                  ),
                )
              else
                RecentScansCard(
                  scans: scans,
                  onTap: _openScanDetail,
                ),
              const Spacer(),
              StartScanButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CameraScreen(),
                    ),
                  );
                  if (!mounted) return;
                  _loadHistory();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}