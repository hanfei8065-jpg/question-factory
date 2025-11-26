import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/camera_service.dart';
import '../services/test_mode_service.dart';
import '../services/openai_service.dart';
import '../theme/theme.dart';
import 'workspace_page.dart';
import 'solving_page.dart';
import '../widgets/crop_bar_overlay.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recognition_mode.dart';
import '../models/camera_state.dart';

// ...existing code...

  Future<void> _checkOfflineCache() async {
    // 暂时不需要检查缓存
  }

  Future<void> _checkShowGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownGuide = prefs.getBool('hasShownCameraGuide') ?? false;
    if (!hasShownGuide) {
      setState(() {
        _showGuide = true;
        _showDynamicGuide = true;
      });
      await prefs.setBool('hasShownCameraGuide', true);
    }
  }

  Future<void> _loadTestImages() async {
    try {
      final Directory testImagesDir = Directory('test_images');
      if (await testImagesDir.exists()) {
        final testImages = await testImagesDir
            .list()
            .where(
              (entity) =>
                  entity is File &&
                  (entity.path.endsWith('.jpg') ||
                      entity.path.endsWith('.png')),
            )
            .map((entity) => entity as File)
            .toList();

        setState(() {
          _testImages.addAll(testImages);
        });
      }
    } catch (e) {
      print('Error loading test images: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _frameAnimationController.dispose();
    _breathingController.dispose();
    _apertureController.dispose();
    if (!TestModeService().isTestMode) {
      CameraService().dispose();
    }
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    print('🔍 检查相机权限...');
    final status = await Permission.camera.status;
    print('📷 相机权限状态: $status');
    print('📹 当前相机状态: $_cameraState');
    print('💬 气泡显示状态: $_showPermissionBubble');
    
    // 临时：跳过权限检查，直接初始化相机
    print('✅ 临时强制认为权限已授予');
    // 只有在相机未初始化时才初始化
    if (_cameraState != CameraState.preview &&
        _cameraState != CameraState.processing) {
      print('🚀 开始初始化相机...');
      await _initCamera();
    } else {
      print('✓ 相机已初始化，只需隐藏气泡');
      // 已经初始化，只需隐藏气泡
      if (mounted) {
        setState(() {
          _showPermissionBubble = false;
        });
      }
    }
  }

  Future<void> _initCamera() async {
    print('📸 _initCamera 开始执行');
    try {
      print('1️⃣ 调用 CameraService().initialize()');
      await CameraService().initialize();
      print('2️⃣ 相机初始化成功，开始图像流');
      await CameraService().startImageStream(_processImageStream);
      print('3️⃣ 图像流启动成功');

      if (mounted) {
        setState(() {
          _previewSize = Size(
            CameraService().previewSize?.width ?? 1280,
            CameraService().previewSize?.height ?? 720,
          );
          _cameraState = CameraState.preview;
          _showPermissionBubble = false;
        });
        print('✨ 相机初始化完成，状态已更新');
      }
    } catch (e) {
      print('❌ 相机初始化失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '相机初始化失败：$e';
          _cameraState = CameraState.initializing;
        });
      }
    }
  }

  void _processImageStream(CameraImage image) {
    // 限制边缘检测的频率，避免过度消耗资源
    if (_edgeDetectionTimer?.isActive ?? false) {
      return;
    }

    _edgeDetectionTimer = Timer(const Duration(milliseconds: 200), () async {
      if (!mounted) return;

      // 边缘检测暂时移除
      print('Edge detection is disabled');
    });
  }

  void _handleConfirm() async {
    if (_capturedImage == null || _imageFile == null) return;

    await _frameAnimationController.reverse();

    // 跳转到新的解题页
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SolvingPage(
            questionImages: [_imageFile!], // 单题模式
          ),
        ),
      );

      // 返回预览状态
      setState(() {
        _cameraState = CameraState.preview;
        _capturedImage = null;
        _imageFile = null;
      });
    }
  }

  void _handleRetake() {
    setState(() {
      _cameraState = CameraState.preview;
      _capturedImage = null;
      _imageFile = null;
    });
    _frameAnimationController.reverse();
  }

  void _handleAdjust() {
    // TODO: 实现图片调整功能
  }

  /// 从相册/文件系统选择图片或PDF
  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final File file = File(image.path);
        
        // 跳转到长条裁剪框模式
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CropBarOverlay(
                imageFile: file,
                onConfirm: () {
                  Navigator.pop(context); // 关闭crop overlay
                  // 直接导航到solving page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SolvingPage(
                        questionImages: [file],
                      ),
                    ),
                  );
                },
                onCancel: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '图片选择失败：$e';
      });
    }
  }

    /// 手电筒开关处理
  Future<void> _handleFlashlightToggle() async {
    final controller = CameraService().controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      setState(() {
        _errorMessage = '手电筒控制失败：$e';
      });
    }
  }

  /// 进入解题页（多题模式）
  void _enterSolvingPage() {
    if (_batchImages.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SolvingPage(
          questionImages: _batchImages, // 传递多张图片（1-3题）
        ),
      ),
    );
    
    // 清空批量图片
    setState(() {
      _batchImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Phase B: Activation & Camera Overlay
    // Phase C: Crop/Edit State
    if (_isCropMode && _capturedFile != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 冻结图片
            Positioned.fill(
              child: Image.file(_capturedFile!, fit: BoxFit.cover),
            ),
            // 裁剪遮罩与裁剪框
            Positioned.fill(
              child: CropView(
                cropRect: _cropRect,
                onRectChanged: (rect) {
                  setState(() => _cropRect = rect);
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Retake按钮
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.white, size: 32, shadows: [Shadow(color: Colors.black54, blurRadius: 6)]),
                onPressed: () {
                  setState(() {
                    _isCropMode = false;
                    _capturedFile = null;
                  });
                },
                splashRadius: 32,
              ),
              // Solve按钮
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF358373),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                      elevation: 4,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter', fontSize: 18),
                    ),
                    icon: const Icon(Icons.arrow_forward_ios, size: 22, color: Colors.white),
                    label: const Text('SOLVE'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppSolvingPage(
                            question: "示例题目内容",
                            answer: "示例答案",
                            explanation: "示例解析",
                            subject: "math",
                            difficulty: "1",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
}

// =====================
// Helper Widgets & Painters (file bottom, top-level)
// =====================

// CropView Widget
class CropView extends StatefulWidget {
  final Rect cropRect;
  final ValueChanged<Rect> onRectChanged;
  const CropView({required this.cropRect, required this.onRectChanged, Key? key}) : super(key: key);
  @override
  State<CropView> createState() => _CropViewState();
}

class _CropViewState extends State<CropView> {
  late Rect _rect;
  Offset? _dragStart;
  int? _dragCorner; // 0:LT, 1:RT, 2:LB, 3:RB

  @override
  void initState() {
    super.initState();
    _rect = widget.cropRect;
  }

  void _startDrag(Offset pos) {
    final corners = [
      _rect.topLeft,
      _rect.topRight,
      _rect.bottomLeft,
      _rect.bottomRight,
    ];
    for (int i = 0; i < 4; i++) {
      if ((corners[i] - pos).distance < 28) {
        _dragCorner = i;
        _dragStart = pos;
        return;
      }
    }
    _dragCorner = null;
    _dragStart = null;
  }

  void _updateDrag(Offset pos) {
    if (_dragCorner == null || _dragStart == null) return;
    final delta = pos - _dragStart!;
    Rect newRect = _rect;
    switch (_dragCorner) {
      case 0:
        newRect = Rect.fromPoints(_rect.topLeft + delta, _rect.bottomRight);
        break;
      case 1:
        newRect = Rect.fromPoints(Offset(_rect.left, _rect.bottom), _rect.topRight + delta);
        break;
      case 2:
        newRect = Rect.fromPoints(Offset(_rect.right, _rect.top), _rect.bottomLeft + delta);
        break;
      case 3:
        newRect = Rect.fromPoints(_rect.topLeft, _rect.bottomRight + delta);
        break;
    }
    final minSize = 80.0;
    newRect = Rect.fromLTRB(
      newRect.left.clamp(0, double.infinity),
      newRect.top.clamp(0, double.infinity),
      newRect.right.clamp(newRect.left + minSize, MediaQuery.of(context).size.width),
      newRect.bottom.clamp(newRect.top + minSize, MediaQuery.of(context).size.height),
    );
    setState(() => _rect = newRect);
    widget.onRectChanged(_rect);
  }

  void _endDrag() {
    _dragCorner = null;
    _dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _startDrag(details.localPosition),
      onPanUpdate: (details) => _updateDrag(details.localPosition),
      onPanEnd: (_) => _endDrag(),
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _CropPainter(_rect),
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  final Rect rect;
  _CropPainter(this.rect);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    Path mask = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    mask.addRect(rect);
    canvas.drawPath(mask, paint);
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, borderPaint);
    final handlePaint = Paint()
      ..color = const Color(0xFF5FCEB3)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final r = rect;
    final len = 28.0;
    canvas.drawLine(r.topLeft, r.topLeft + Offset(len, 0), handlePaint);
    canvas.drawLine(r.topLeft, r.topLeft + Offset(0, len), handlePaint);
    canvas.drawLine(r.topRight, r.topRight + Offset(-len, 0), handlePaint);
    canvas.drawLine(r.topRight, r.topRight + Offset(0, len), handlePaint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + Offset(len, 0), handlePaint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + Offset(0, -len), handlePaint);
    canvas.drawLine(r.bottomRight, r.bottomRight + Offset(-len, 0), handlePaint);
    canvas.drawLine(r.bottomRight, r.bottomRight + Offset(0, -len), handlePaint);
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.2;
    for (int i = 1; i < 3; i++) {
      final dx = r.left + i * r.width / 3;
      canvas.drawLine(Offset(dx, r.top), Offset(dx, r.bottom), gridPaint);
      final dy = r.top + i * r.height / 3;
      canvas.drawLine(Offset(r.left, dy), Offset(r.right, dy), gridPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
// Academic Scope Overlay Painter
class _AcademicScopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double frameSize = size.shortestSide * 0.68;
    final double frameLeft = (size.width - frameSize) / 2;
    final double frameTop = (size.height - frameSize) / 2;
    final double cornerLen = 32;
    final double cornerWidth = 4;
    final double crossLen = 16;
    final double crossWidth = 2.5;
    final Color clawColor = const Color(0xFF5FCEB3); // 亮青
    final Color lineColor = Colors.white;
    final Paint clawPaint = Paint()
      ..color = clawColor
      ..strokeWidth = cornerWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = crossWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // 四角L形（亮青）
    // 左上
    canvas.drawLine(Offset(frameLeft, frameTop), Offset(frameLeft + cornerLen, frameTop), clawPaint);
    canvas.drawLine(Offset(frameLeft, frameTop), Offset(frameLeft, frameTop + cornerLen), clawPaint);
    // 右上
    canvas.drawLine(Offset(frameLeft + frameSize, frameTop), Offset(frameLeft + frameSize - cornerLen, frameTop), clawPaint);
    canvas.drawLine(Offset(frameLeft + frameSize, frameTop), Offset(frameLeft + frameSize, frameTop + cornerLen), clawPaint);
    // 左下
    canvas.drawLine(Offset(frameLeft, frameTop + frameSize), Offset(frameLeft + cornerLen, frameTop + frameSize), clawPaint);
    canvas.drawLine(Offset(frameLeft, frameTop + frameSize), Offset(frameLeft, frameTop + frameSize - cornerLen), clawPaint);
    // 右下
    canvas.drawLine(Offset(frameLeft + frameSize, frameTop + frameSize), Offset(frameLeft + frameSize - cornerLen, frameTop + frameSize), clawPaint);
    canvas.drawLine(Offset(frameLeft + frameSize, frameTop + frameSize), Offset(frameLeft + frameSize, frameTop + frameSize - cornerLen), clawPaint);
    // 中心十字（白色）
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(center.translate(-crossLen, 0), center.translate(crossLen, 0), linePaint);
    canvas.drawLine(center.translate(0, -crossLen), center.translate(0, crossLen), linePaint);
    // 中心圆（白色）
    canvas.drawCircle(center, 10, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// 98k瞄准镜Painter
// 98k瞄准镜Painter
class _SniperReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double frameSize = size.shortestSide * 0.68;
    final double frameLeft = (size.width - frameSize) / 2;
    final double frameTop = (size.height - frameSize) / 2;
    final double cornerLen = 36;
    final double cornerWidth = 6;
    final double crossLen = 18;
    final double crossWidth = 3;
    final Color clawColor = const Color(0xFF5FCEB3); // 品牌亮青
    final Color crossColor = Colors.white;
    final Paint clawPaint = Paint()
      ..color = clawColor
      ..strokeWidth = cornerWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        // 四角L形
        // 左上
        canvas.drawLine(Offset(frameLeft, frameTop), Offset(frameLeft + cornerLen, frameTop), clawPaint);
        canvas.drawLine(Offset(frameLeft, frameTop), Offset(frameLeft, frameTop + cornerLen), clawPaint);
        // 右上
        canvas.drawLine(Offset(frameLeft + frameSize, frameTop), Offset(frameLeft + frameSize - cornerLen, frameTop), clawPaint);
        canvas.drawLine(Offset(frameLeft + frameSize, frameTop), Offset(frameLeft + frameSize, frameTop + cornerLen), clawPaint);
        // 左下
        canvas.drawLine(Offset(frameLeft, frameTop + frameSize), Offset(frameLeft + cornerLen, frameTop + frameSize), clawPaint);
        canvas.drawLine(Offset(frameLeft, frameTop + frameSize), Offset(frameLeft, frameTop + frameSize - cornerLen), clawPaint);
        // 右下
        canvas.drawLine(Offset(frameLeft + frameSize, frameTop + frameSize), Offset(frameLeft + frameSize - cornerLen, frameTop + frameSize), clawPaint);
        canvas.drawLine(Offset(frameLeft + frameSize, frameTop + frameSize), Offset(frameLeft + frameSize, frameTop + frameSize - cornerLen), clawPaint);
        // 中心十字
        final Paint crossPaint = Paint()
          ..color = crossColor
          ..strokeWidth = crossWidth
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        final Offset center = Offset(size.width / 2, size.height / 2);
        canvas.drawLine(center.translate(-crossLen, 0), center.translate(crossLen, 0), crossPaint);
        canvas.drawLine(center.translate(0, -crossLen), center.translate(0, crossLen), crossPaint);
        // 中心圆
        canvas.drawCircle(center, 12, crossPaint);
      }

      @override
      bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
    }
}
