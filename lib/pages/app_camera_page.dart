import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// 确保这两个文件路径是存在的
import 'camera/camera_painters.dart';
import 'real_solving_page.dart';

class AppCameraPage extends StatefulWidget {
  const AppCameraPage({super.key});

  @override
  State<AppCameraPage> createState() => _AppCameraPageState();
}

class _AppCameraPageState extends State<AppCameraPage>
    with TickerProviderStateMixin {
  CameraController? _controller;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;
  bool _isCameraActive = false;
  bool _isFlashOn = false;

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    if (_controller == null) return;
    setState(() {
      _isFlashOn = !_isFlashOn;
      _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    });
  }

  void _activateSniperMode() => setState(() => _isCameraActive = true);

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.isTakingPicture)
      return;
    try {
      final image = await _controller!.takePicture();
      _controller!.setFlashMode(FlashMode.off);
      setState(() {
        _capturedImage = image;
        _isFlashOn = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _retake() => setState(() => _capturedImage = null);

  void _goToSolvePage() {
    if (_capturedImage == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolvingPage(imagePath: _capturedImage!.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgWhite = Color(0xFFF5F7FA);
    const Color primaryGreen = Color(0xFF358373);
    const Color iconSlate = Color(0xFF1E293B);

    // 1. 裁剪页
    if (_capturedImage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
            CustomPaint(
              painter: CropOverlayPainter(
                Rect.fromLTWH(
                  40,
                  150,
                  MediaQuery.of(context).size.width - 80,
                  400,
                ),
              ),
            ),
            CustomPaint(
              painter: GridPainter(
                Rect.fromLTWH(
                  40,
                  150,
                  MediaQuery.of(context).size.width - 80,
                  400,
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _retake,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _goToSolvePage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      "开始解题",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

    // 2. 待机页 (闭眼状态)
    if (!_isCameraActive) {
      return Scaffold(
        backgroundColor: bgWhite,
        body: Stack(
          children: [
            // 左上角优惠
            Positioned(
              top: 60,
              left: 20,
              child: Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFFB86B),
                size: 32,
              ),
            ),
            // 右上角计算器
            Positioned(
              top: 60,
              right: 20,
              child: Icon(Icons.calculate_outlined, color: iconSlate, size: 32),
            ),

            // 中间呼吸圆 (视觉锚点)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100), // 稍微偏上
                child: ScaleTransition(
                  scale: _breathingAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryGreen, width: 2),
                    ),
                  ),
                ),
              ),
            ),

            // 底部操作栏 (手部操作区)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.image_outlined, color: iconSlate, size: 28), // 导入
                  // 快门触发器
                  GestureDetector(
                    onTap: _activateSniperMode,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.flashlight_on_outlined,
                    color: iconSlate,
                    size: 28,
                  ), // 手电
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 3. 开启状态 (狙击模式)
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraInitialized && _controller != null)
            CameraPreview(_controller!),
          CustomPaint(painter: SniperReticlePainter()),
          // 顶部闪光灯
          Positioned(
            top: 60,
            right: 20,
            child: IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
          ),
          // 底部真实快门
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
