// [LEARNEST_CONFIRMED_V3.0] - 定稿日期: 2026-01-06 (修正双底座版)
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:ui';
import 'dart:io';
import 'calculator_page.dart';
import 'app_image_editor_page.dart';
import '../core/constants.dart';

// --- 特斯拉 0.93 缩放物理引擎 (保留) ---
class TeslaScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const TeslaScaleWrapper({super.key, required this.child, this.onTap});
  @override
  State<TeslaScaleWrapper> createState() => _TeslaScaleWrapperState();
}

class _TeslaScaleWrapperState extends State<TeslaScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

class AppCameraPage extends StatefulWidget {
  const AppCameraPage({super.key});
  @override
  State<AppCameraPage> createState() => _AppCameraPageState();
}

class _AppCameraPageState extends State<AppCameraPage> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  String _currentSubject = '数学';
  String _currentLang = 'A/中';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  Subject _getSelectedSubjectEnum() {
    switch (_currentSubject) {
      case '数学':
      case '奥数':
        return Subject.math;
      case '物理':
        return Subject.physics;
      case '化学':
        return Subject.chemistry;
      default:
        return Subject.math;
    }
  }

  // --- 核心拍照逻辑 (完整保留) ---
  Future<void> _takePictureAndCrop() async {
    if (!_isInitialized ||
        _controller == null ||
        _controller!.value.isTakingPicture) return;
    try {
      final XFile photo = await _controller!.takePicture();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppImageEditorPage(
            imagePath: photo.path,
            subject: _getSelectedSubjectEnum(),
          ),
        ),
      );
    } catch (e) {
      debugPrint("拍照出错: $e");
    }
  }

  void _toggleFlash() async {
    if (!_isInitialized) return;
    _isFlashOn = !_isFlashOn;
    await _controller!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  void _navigateToCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalculatorPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 修正：使用 Material 代替 Scaffold，并删掉内部 Column 和 _buildTeslaDock
    // 这样它就只会显示相机内容，底座由外部的 main.dart 提供
    return Material(
      color: Colors.black,
      child: _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    if (!_isInitialized || _controller == null)
      return Container(color: Colors.black);
    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_controller!)),
        _buildCameraOverlay(),
      ],
    );
  }

  Widget _buildCameraOverlay() {
    return SafeArea(
      child: Stack(
        children: [
          // 1. 顶部栏 (保留)
          Positioned(
            top: 25,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TeslaScaleWrapper(
                  onTap: _showReferralSheet,
                  child: _buildTeslaCircleBtn(Icons.qr_code_scanner, size: 33),
                ),
                Row(
                  children: [
                    _buildLanguagePicker(),
                    const SizedBox(width: 20),
                    TeslaScaleWrapper(
                      onTap: _navigateToCalculator,
                      child: _buildTeslaCircleBtn(
                        Icons.calculate_outlined,
                        size: 33,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. 中心：瞄准框 (保留)
          Center(
            child: CustomPaint(
              size: const Size(312, 160),
              painter: SniperReticlePainter(),
            ),
          ),

          // 2.1 学科选择器 (保留)
          Positioned(
            bottom: 165,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['数学', '物理', '化学', '奥数']
                  .map(
                    (s) => TeslaScaleWrapper(
                      onTap: () => setState(() => _currentSubject = s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          s,
                          style: TextStyle(
                            color: _currentSubject == s
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 18,
                            fontWeight: _currentSubject == s
                                ? FontWeight.bold
                                : FontWeight.normal,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // 3. 底部拍照区 (保留)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TeslaScaleWrapper(
                  onTap: _showFilePickerSheet,
                  child: _buildTeslaCircleBtn(
                    Icons.photo_library_outlined,
                    size: 33,
                  ),
                ),
                TeslaScaleWrapper(
                  onTap: _takePictureAndCrop,
                  child: _buildRedShutter(),
                ),
                TeslaScaleWrapper(
                  onTap: _toggleFlash,
                  child: _buildTeslaCircleBtn(
                    _isFlashOn
                        ? Icons.flashlight_on
                        : Icons.flashlight_off_outlined,
                    size: 33,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 交互菜单 (保留) ---
  Widget _buildLanguagePicker() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color(0xFF171A20),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onSelected: (val) =>
            setState(() => _currentLang = val == '中文' ? 'A/中' : val),
        child: _buildTeslaLanguageBtn(),
        itemBuilder: (context) => ['English', '中文', 'Español', '日本語']
            .map(
              (l) => PopupMenuItem(
                value: l,
                child: Center(
                  child: Text(
                    l,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showReferralSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.35,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '推荐码',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            TextField(
              decoration: InputDecoration(
                hintText: '输入推荐码',
                filled: true,
                fillColor: const Color(0xFFF4F4F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '确认',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 320,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            children: [
              _buildFileMenuOption(
                Icons.photo_library_outlined,
                '提取图片',
                '从相册导入题目照片',
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.black12, height: 1),
              const SizedBox(height: 15),
              _buildFileMenuOption(
                Icons.picture_as_pdf_outlined,
                '提取 PDF',
                '导入 PDF 试卷或文档',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileMenuOption(IconData icon, String title, String subtitle) {
    return TeslaScaleWrapper(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF171A20),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.black45),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  // 💡 物理删除：_buildTeslaDock, _buildDockItem, _buildPlaceholderPage 已删除，由外部管理

  Widget _buildRedShutter() {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        color: Color(0xFFE82127),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.camera_alt, color: Colors.white, size: 38),
    );
  }

  Widget _buildTeslaCircleBtn(IconData icon, {double size = 24}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

  Widget _buildTeslaLanguageBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _currentLang,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SniperReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      Offset(center.dx - 10, center.dy),
      Offset(center.dx + 10, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      paint,
    );
    double l = 18;
    canvas.drawLine(Offset.zero, Offset(l, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, l), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - l, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, l), paint);
    canvas.drawLine(Offset(0, size.height), Offset(l, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - l), paint);
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - l, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
