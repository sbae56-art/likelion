import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'analyzing_screen.dart';
import '../widgets/scan/mouth_guide.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  // 📸 사진을 찍고 다음 화면으로 넘기는 함수
  Future<void> _takePictureAndAnalyze(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    // 카메라 실행 (갤러리에서 고르게 하려면 ImageSource.gallery 로 변경)
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            // 다음 화면(AnalyzingScreen)으로 찍은 사진 파일 전달!
            builder: (_) => AnalyzingScreen(imageFile: photo),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.only(top: 52, left: 18, right: 18, bottom: 14),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: () {},
                  icon: const Icon(
                    Icons.replay_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                // ⭐ 핵심: 촬영 버튼을 눌렀을 때 사진 찍는 함수 실행 ⭐
                GestureDetector(
                  onTap: () => _takePictureAndAnalyze(context),
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
                
                GestureDetector(
                  onTap: () {},
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}