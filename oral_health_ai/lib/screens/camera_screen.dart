import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  bool _isFlashOn = false;
  bool _flashSupported = true;

  int _cameraIndex = 0;
  String _analysisMessage = 'Analyzing your scan...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(selectedIndex: _cameraIndex);
    }
  }

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

  Future<void> _initializeCamera({int selectedIndex = 0}) async {
    try {
      setState(() {
        _isInitializing = true;
      });

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No camera available on this device.');
      }

      if (selectedIndex >= cameras.length) {
        selectedIndex = 0;
      }

      final oldController = _controller;
      if (oldController != null) {
        await oldController.dispose();
      }

      final controller = CameraController(
        cameras[selectedIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      bool flashSupported = true;
      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {
        flashSupported = false;
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameras = cameras;
        _cameraIndex = selectedIndex;
        _controller = controller;
        _isInitializing = false;
        _flashSupported = flashSupported;
        _isFlashOn = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (!_flashSupported) return;

    try {
      if (_isFlashOn) {
        await controller.setFlashMode(FlashMode.off);
      } else {
        await controller.setFlashMode(FlashMode.torch);
      }

      if (!mounted) return;

      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _flashSupported = false;
        _isFlashOn = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIndex = (_cameraIndex + 1) % _cameras.length;
    await _initializeCamera(selectedIndex: nextIndex);
  }

  Future<void> _captureAndAnalyze() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isCapturing ||
        _isAnalyzing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final XFile photo = await controller.takePicture();

      if (!mounted) return;

      setState(() {
        _isCapturing = false;
        _isAnalyzing = true;
        _analysisMessage = 'Analyzing your scan...';
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCapturing = false;
        _isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo capture failed: $e')),
      );
    }
  }

  Widget _buildPreview() {
    final controller = _controller;

    if (_isInitializing || controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(0, 0, 0, 0.32),
                Color.fromRGBO(0, 0, 0, 0.08),
                Color.fromRGBO(0, 0, 0, 0.32),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
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

  Widget _buildTopBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(top: 52, left: 18, right: 18, bottom: 14),
      child: Row(
        children: [
          IconButton(
            onPressed:
                (_isAnalyzing || _isCapturing) ? null : () => Navigator.pop(context),
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
          _flashSupported
              ? IconButton(
                  onPressed: (_isAnalyzing || _isCapturing) ? null : _toggleFlash,
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              : const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final disabled = _isAnalyzing || _isCapturing || _isInitializing;

    return Container(
      height: 96,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: disabled || _cameras.length < 2 ? null : _switchCamera,
            icon: const Icon(
              Icons.replay_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          GestureDetector(
            onTap: disabled ? null : _captureAndAnalyze,
            child: Opacity(
              opacity: disabled ? 0.5 : 1,
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _buildPreview()),
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
          _buildBottomBar(),
        ],
      ),
    );
  }
}