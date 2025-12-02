import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera/camera_painters.dart';
import 'solving_page.dart';
import '../widgets/onboarding_overlay.dart';
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
  bool _isCameraActive = false;
  bool _isFlashOn = false;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _cameraError; // Camera error message
  bool _showOnboarding = false; // FRE overlay state

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
    _checkOnboarding(); // Check if first run
  }

  /// Check if user has seen onboarding (First Run Experience)
  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      // Show onboarding after a short delay (let UI settle)
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _showOnboarding = true;
        });
      }
    }
  }

  /// Complete onboarding and save flag
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      setState(() {
        _showOnboarding = false;
      });
    }
  }

  /// Reset onboarding flag (for testing)
  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Onboarding reset! Restart app to see it again.'),
          backgroundColor: Color(0xFF07C160),
        ),
      );
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _cameraError = 'No camera found on this device';
        });
        return;
      }

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
          _cameraError = Tr.g('home_camera_error');
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

        // Initialize crop rect (centered, 85% width, 16:9 aspect)
        final screenSize = MediaQuery.of(context).size;
        final cropWidth = screenSize.width * 0.85;
        final cropHeight = cropWidth * 9 / 16;

        setState(() {
          _capturedImagePath = image.path;
          _rotationCount = 0;
          _cropRect = Rect.fromCenter(
            center: Offset(screenSize.width / 2, screenSize.height / 2),
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

    // Navigate to SolvingPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolvingPage(
          imagePath: _capturedImagePath!,
          rotationCount: _rotationCount,
        ),
      ),
    );
  }

  _CropHandle? _detectHandle(Offset position, Rect cropRect) {
    const double touchRadius = 40; // Touch area for corners

    // Check corners first (priority over center)
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

    const double minSize = 100;
    final delta = details.delta;

    setState(() {
      switch (_activeHandle!) {
        case _CropHandle.center:
          // Move entire crop box
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
          // Resize from top-left
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
          // Resize from top-right
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
          // Resize from bottom-left
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
          // Resize from bottom-right
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
                              child: Text(Tr.g('home_retry_camera')),
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
                  child: CustomPaint(painter: SniperCrosshairPainter()),
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
                                Tr.g('home_promo'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Language Switcher
                        PopupMenuButton<String>(
                          onSelected: (locale) => Tr.setLocale(locale),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'zh',
                              child: Row(
                                children: [
                                  Text(
                                    Tr.getFlag('zh'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('中文'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'en',
                              child: Row(
                                children: [
                                  Text(
                                    Tr.getFlag('en'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('English'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'ja',
                              child: Row(
                                children: [
                                  Text(
                                    Tr.getFlag('ja'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('日本語'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'es',
                              child: Row(
                                children: [
                                  Text(
                                    Tr.getFlag('es'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Español'),
                                ],
                              ),
                            ),
                          ],
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Tr.getFlag(Tr.currentLocale.value),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 2),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: darkGrey,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
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
                                Tr.g('home_calc'),
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
                    child: GestureDetector(
                      onLongPress: () {
                        // Debug: Reset onboarding
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Reset Onboarding?'),
                            content: const Text(
                              'This will reset the First Run Experience. You\'ll need to restart the app to see it again.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _resetOnboarding();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF07C160),
                                ),
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: ScaleTransition(
                        scale: _breathingAnimation,
                        child: const SizedBox(width: 120, height: 120),
                      ),
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
                        height: 40,
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

                    // Action Buttons
                    Padding(
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
                                Icon(
                                  Icons.image_outlined,
                                  color: _isCameraActive
                                      ? Colors.white
                                      : darkGrey,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Tr.g('home_import'),
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

                          // Shutter
                          GestureDetector(
                            onTap: _onShutterTap,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _isCameraActive
                                    ? Colors.transparent
                                    : wechatGreen,
                                shape: BoxShape.circle,
                                border: _isCameraActive
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                                boxShadow: _isCameraActive
                                    ? null
                                    : const [
                                        BoxShadow(
                                          color: Color(0x3307C160),
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Icon(
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
                                  color: _isCameraActive
                                      ? Colors.white
                                      : darkGrey,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Tr.g('home_flash'),
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
                  ],
                ),
              ),
            ],
          ),
        ),

        // Onboarding Overlay (First Run Experience)
        if (_showOnboarding)
          Positioned.fill(
            child: OnboardingOverlay(
              onComplete: _completeOnboarding,
              screenSize: screenSize,
            ),
          ),
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
