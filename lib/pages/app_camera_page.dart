import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera/camera_painters.dart';
import 'app_solution_page.dart';
import '../services/translation_service.dart';

enum _CropHandle { topLeft, topRight, bottomLeft, bottomRight, center }

class AppCameraPage extends StatefulWidget {
  const AppCameraPage({super.key});

  @override
  State<AppCameraPage> createState() => _AppCameraPageState();
}

class _AppCameraPageState extends State<AppCameraPage>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late AnimationController _breachController;
  late Animation<double> _breachAnimation;

  int _selectedSubjectIndex = 0;
  bool _isCameraActive = true; // 🔥 直接激活相机
  bool _isFlashOn = false;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _cameraError; // Camera error message

  // Crop view state
  String? _capturedImagePath;
  int _rotationCount = 0;
  Rect? _cropRect;
  _CropHandle? _activeHandle;

  final List<String> _subjects = ['数学', '物理', '化学', '奥数'];

  @override
  void initState() {
    super.initState();

    // Breathing animation for closed state
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Breach animation for camera activation
    _breachController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _breachAnimation = CurvedAnimation(
      parent: _breachController,
      curve: Curves.easeOutCubic,
    );

    _initializeCamera();
    // 🔥 直接激活相机动画
    _breachController.forward();
    // ❌ Onboarding removed per user request
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission first
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _cameraError = 'Camera permission denied';
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _cameraError = 'No camera found on this device';
        });
        return;
      }

      // Dispose old controller if exists
      await _cameraController?.dispose();

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraError = null;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _cameraError = 'Camera error: ${e.toString()}';
        });
      }
    }
  }

  void _retryCamera() {
    setState(() {
      _cameraError = null;
      _isCameraInitialized = false;
    });
    _initializeCamera();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _breachController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _onShutterTap() async {
    if (!_isCameraActive) {
      // Activate camera mode
      setState(() => _isCameraActive = true);
      await _breachController.forward();
    } else {
      // Take picture
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        return;
      }

      try {
        final image = await _cameraController!.takePicture();

        // Initialize crop rect (large box, slightly smaller than screen edges)
        final screenSize = MediaQuery.of(context).size;
        final margin = 40.0; // 40px margin from edges
        final cropWidth = screenSize.width - (margin * 2);
        final cropHeight =
            screenSize.height -
            (margin * 2) -
            200; // Extra space for bottom controls

        setState(() {
          _capturedImagePath = image.path;
          _rotationCount = 0;
          _cropRect = Rect.fromCenter(
            center: Offset(
              screenSize.width / 2,
              (screenSize.height - 100) / 2,
            ), // Center vertically with offset for controls
            width: cropWidth,
            height: cropHeight,
          );
        });
      } catch (e) {
        debugPrint('Error taking picture: $e');
      }
    }
  }

  void _onRetakeTap() {
    setState(() {
      _capturedImagePath = null;
      _rotationCount = 0;
      _cropRect = null;
      _activeHandle = null;
    });
  }

  void _onRotateTap() {
    setState(() {
      _rotationCount = (_rotationCount + 1) % 4;
    });
  }

  void _onSolveTap() {
    if (_capturedImagePath == null) return;

    // Navigate to SolvingPage with captured image
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolvingPage(imagePath: _capturedImagePath!),
      ),
    );
  }

  _CropHandle? _detectHandle(Offset position, Rect cropRect) {
    const double touchRadius = 40.0; // Increased hit area for easy grabbing

    // Check corners first (priority over center)
    // Using distance check for precise corner detection
    if ((position - cropRect.topLeft).distance < touchRadius) {
      return _CropHandle.topLeft;
    }
    if ((position - cropRect.topRight).distance < touchRadius) {
      return _CropHandle.topRight;
    }
    if ((position - cropRect.bottomLeft).distance < touchRadius) {
      return _CropHandle.bottomLeft;
    }
    if ((position - cropRect.bottomRight).distance < touchRadius) {
      return _CropHandle.bottomRight;
    }

    // Check center (anywhere inside crop box)
    if (cropRect.contains(position)) {
      return _CropHandle.center;
    }

    return null;
  }

  void _onCropPanStart(DragStartDetails details, Size screenSize) {
    if (_cropRect == null) return;

    setState(() {
      _activeHandle = _detectHandle(details.localPosition, _cropRect!);
    });
  }

  void _onCropPanUpdate(DragUpdateDetails details, Size screenSize) {
    if (_cropRect == null || _activeHandle == null) return;

    const double minSize = 100.0; // Minimum crop box size
    final delta = details.delta;

    setState(() {
      switch (_activeHandle!) {
        case _CropHandle.center:
          // Move entire crop box (keeping size constant)
          double newLeft = (_cropRect!.left + delta.dx).clamp(
            0.0,
            screenSize.width - _cropRect!.width,
          );
          double newTop = (_cropRect!.top + delta.dy).clamp(
            0.0,
            screenSize.height - _cropRect!.height,
          );
          _cropRect = Rect.fromLTWH(
            newLeft,
            newTop,
            _cropRect!.width,
            _cropRect!.height,
          );
          break;

        case _CropHandle.topLeft:
          // Resize from top-left corner (adjust left and top edges)
          double newLeft = (_cropRect!.left + delta.dx).clamp(
            0.0,
            _cropRect!.right - minSize,
          );
          double newTop = (_cropRect!.top + delta.dy).clamp(
            0.0,
            _cropRect!.bottom - minSize,
          );
          _cropRect = Rect.fromLTRB(
            newLeft,
            newTop,
            _cropRect!.right,
            _cropRect!.bottom,
          );
          break;

        case _CropHandle.topRight:
          // Resize from top-right corner (adjust right and top edges)
          double newRight = (_cropRect!.right + delta.dx).clamp(
            _cropRect!.left + minSize,
            screenSize.width,
          );
          double newTop = (_cropRect!.top + delta.dy).clamp(
            0.0,
            _cropRect!.bottom - minSize,
          );
          _cropRect = Rect.fromLTRB(
            _cropRect!.left,
            newTop,
            newRight,
            _cropRect!.bottom,
          );
          break;

        case _CropHandle.bottomLeft:
          // Resize from bottom-left corner (adjust left and bottom edges)
          double newLeft = (_cropRect!.left + delta.dx).clamp(
            0.0,
            _cropRect!.right - minSize,
          );
          double newBottom = (_cropRect!.bottom + delta.dy).clamp(
            _cropRect!.top + minSize,
            screenSize.height,
          );
          _cropRect = Rect.fromLTRB(
            newLeft,
            _cropRect!.top,
            _cropRect!.right,
            newBottom,
          );
          break;

        case _CropHandle.bottomRight:
          // Resize from bottom-right corner (adjust right and bottom edges)
          double newRight = (_cropRect!.right + delta.dx).clamp(
            _cropRect!.left + minSize,
            screenSize.width,
          );
          double newBottom = (_cropRect!.bottom + delta.dy).clamp(
            _cropRect!.top + minSize,
            screenSize.height,
          );
          _cropRect = Rect.fromLTRB(
            _cropRect!.left,
            _cropRect!.top,
            newRight,
            newBottom,
          );
          break;
      }
    });
  }

  void _onCropPanEnd(DragEndDetails details) {
    setState(() {
      _activeHandle = null;
    });
  }

  List<Widget> _buildCornerHitAreas(Rect cropRect) {
    const double hitSize = 60; // Larger touch target
    const double visualSize = 12; // Visual indicator size
    const Color wechatGreen = Color(0xFF07C160);

    Widget buildCorner(Offset position, _CropHandle handle) {
      final bool isActive = _activeHandle == handle;

      return Positioned(
        left: position.dx - hitSize / 2,
        top: position.dy - hitSize / 2,
        child: Container(
          width: hitSize,
          height: hitSize,
          alignment: Alignment.center,
          child: Container(
            width: visualSize,
            height: visualSize,
            decoration: BoxDecoration(
              color: isActive ? wechatGreen : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
              ],
            ),
          ),
        ),
      );
    }

    return [
      buildCorner(cropRect.topLeft, _CropHandle.topLeft),
      buildCorner(cropRect.topRight, _CropHandle.topRight),
      buildCorner(cropRect.bottomLeft, _CropHandle.bottomLeft),
      buildCorner(cropRect.bottomRight, _CropHandle.bottomRight),
    ];
  }

  Widget _buildCropView(BuildContext context, Size screenSize) {
    const Color wechatGreen = Color(0xFF07C160);
    const Color darkGrey = Color(0xFF1E293B);

    // Use dynamic crop rect
    final Rect cropRect =
        _cropRect ??
        Rect.fromCenter(
          center: Offset(screenSize.width / 2, screenSize.height / 2),
          width: screenSize.width * 0.85,
          height: screenSize.width * 0.85 * 9 / 16,
        );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Static captured image (rotated)
          Positioned.fill(
            child: Transform.rotate(
              angle: _rotationCount * 3.14159 / 2,
              child: Image.file(File(_capturedImagePath!), fit: BoxFit.contain),
            ),
          ),

          // Interactive crop layer with gestures
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (details) => _onCropPanStart(details, screenSize),
              onPanUpdate: (details) => _onCropPanUpdate(details, screenSize),
              onPanEnd: _onCropPanEnd,
              child: Stack(
                children: [
                  // Frosted glass mask OUTSIDE crop area
                  ClipPath(
                    clipper: _InvertedRectClipper(cropRect),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),

                  // Crop frame with green corners and grid
                  CustomPaint(painter: CropFramePainter(cropRect: cropRect)),

                  // Corner hit areas (invisible but touchable)
                  ..._buildCornerHitAreas(cropRect),
                ],
              ),
            ),
          ),

          // Bottom control bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Retake
                    GestureDetector(
                      onTap: _onRetakeTap,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.refresh, color: darkGrey, size: 32),
                          SizedBox(height: 4),
                          Text(
                            '重拍',
                            style: TextStyle(fontSize: 12, color: darkGrey),
                          ),
                        ],
                      ),
                    ),

                    // Solve Button
                    GestureDetector(
                      onTap: _onSolveTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: wechatGreen,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3307C160),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          '开始解题',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Rotate
                    GestureDetector(
                      onTap: _onRotateTap,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.rotate_90_degrees_ccw,
                            color: darkGrey,
                            size: 32,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '旋转',
                            style: TextStyle(fontSize: 12, color: darkGrey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onImportTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('导入图片功能开发中...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _onFlashTap() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() => _isFlashOn = !_isFlashOn);
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  void _onPromoTap() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('限时特惠'),
        content: const Text('专属优惠活动即将开启！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _onCalculatorTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('计算器功能开发中...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgGrey = Color(0xFFF5F7FA);
    const Color wechatGreen = Color(0xFF07C160);
    const Color darkGrey = Color(0xFF1E293B);
    const Color lightGrey = Color(0xFF9E9E9E);
    const Color orange = Color(0xFFFF9800);

    final screenSize = MediaQuery.of(context).size;

    // CROP VIEW STATE
    if (_capturedImagePath != null) {
      return _buildCropView(context, screenSize);
    }

    // CAMERA VIEW STATE
    return Stack(
      children: [
        Scaffold(
          backgroundColor: _isCameraActive ? Colors.black : bgGrey,
          body: Stack(
            children: [
              // Camera Preview (underneath when active)
              if (_isCameraActive &&
                  _isCameraInitialized &&
                  _cameraController != null)
                Positioned.fill(child: CameraPreview(_cameraController!)),

              // Camera Error State
              if (_isCameraActive && _cameraError != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              size: 64,
                              color: Color(0xFF9E9E9E),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _cameraError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _retryCamera,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF07C160),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(Tr.get('home_retry_camera')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Background fade overlay
              AnimatedBuilder(
                animation: _breachAnimation,
                builder: (context, child) {
                  return Container(
                    color: bgGrey.withOpacity(1.0 - _breachAnimation.value),
                  );
                },
              ),

              // Animated Aperture/Brackets
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _breachAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: JadeAperturePainter(
                        animationValue: _breachAnimation.value,
                        screenSize: screenSize,
                      ),
                    );
                  },
                ),
              ),

              // Sniper Crosshair (active mode only)
              if (_isCameraActive)
                Positioned.fill(
                  child: CustomPaint(
                    painter: SniperCrosshairPainter(screenSize: screenSize),
                  ),
                ),

              // 🔥 相机激活时的控件
              if (_isCameraActive)
                SafeArea(
                  child: Column(
                    children: [
                      // 顶部返回按钮
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // 底部拍摄按钮
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 闪光灯
                            IconButton(
                              icon: Icon(
                                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: _onFlashTap,
                            ),
                            // 拍摄按钮
                            GestureDetector(
                              onTap: _onShutterTap,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 占位
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Layer A: Top Bar Icons (hide in active mode)
              if (!_isCameraActive)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _onPromoTap,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: orange,
                                size: 28,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                Tr.get('home_promo'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Calculator Icon (Language Switcher removed for clean UI)
                        GestureDetector(
                          onTap: _onCalculatorTap,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calculate_outlined,
                                color: darkGrey,
                                size: 28,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                Tr.get('home_calc'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: darkGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Layer B: Visual Anchor (closed mode only)
              if (!_isCameraActive)
                Positioned(
                  left: 0,
                  right: 0,
                  top: screenSize.height * 0.35,
                  child: Center(
                    child: ScaleTransition(
                      scale: _breathingAnimation,
                      child: const SizedBox(width: 120, height: 120),
                    ),
                  ),
                ),

              // Layer C: Control Cockpit
              Positioned(
                left: 0,
                right: 0,
                bottom: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subject Slider (hide in active mode)
                    if (!_isCameraActive)
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _subjects.length,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemBuilder: (context, index) {
                            final isSelected = index == _selectedSubjectIndex;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSubjectIndex = index),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _subjects[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? wechatGreen
                                            : lightGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (isSelected)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: wechatGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (!_isCameraActive) const SizedBox(height: 32),

                    // Action Buttons (hide when camera is active)
                    Visibility(
                      visible: !_isCameraActive,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Import
                            GestureDetector(
                              onTap: _onImportTap,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.image_outlined,
                                    color: darkGrey,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Tr.get('home_import'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Shutter
                            GestureDetector(
                              onTap: _onShutterTap,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: wechatGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x3307C160),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),

                            // Flash
                            GestureDetector(
                              onTap: _onFlashTap,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isFlashOn
                                        ? Icons.flashlight_on
                                        : Icons.flashlight_on_outlined,
                                    color: darkGrey,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Tr.get('home_flash'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _isCameraActive
                                          ? Colors.white
                                          : darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ❌ Onboarding overlay removed per user request
      ],
    );
  }
}

/// CustomClipper for inverted rectangle (frosted area OUTSIDE crop box)
class _InvertedRectClipper extends CustomClipper<Path> {
  final Rect cropRect;

  _InvertedRectClipper(this.cropRect);

  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant _InvertedRectClipper oldClipper) {
    return oldClipper.cropRect != cropRect;
  }
}
