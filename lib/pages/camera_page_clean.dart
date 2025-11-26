import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/question.dart';

import '../services/camera_service.dart';
import '../services/question_cache_service.dart';
import '../services/test_mode_service.dart';
import '../services/openai_service.dart';
import 'workspace_page.dart';
import '../widgets/resizable_selection_box.dart';

import '../models/camera_state.dart';
import '../models/recognition_mode.dart';
import '../widgets/camera_permission_guide.dart';
import '../widgets/camera_preview.dart';
import '../widgets/dynamic_camera_guide.dart';
import '../widgets/camera_best_practices.dart';
import '../widgets/photo_confirm_overlay.dart';
import '../widgets/adjustable_question_box.dart';
import 'question_result_page.dart';
import '../widgets/grid_painter.dart' as grid;
import '../services/model_manager.dart';
import '../services/multi_question_processor.dart';
import '../services/question_detection_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  // UI状态
  bool _hasCachedQuestions = false;
  bool _showGuide = false;
  bool _showBestPractices = false;
  bool _showDynamicGuide = false;
  bool _showGrid = true;
  bool _isFlashOn = false;
  bool _showExposureSlider = false;
  double _currentExposure = 0.0;
  double _maxExposure = 1.0;
  double _minExposure = -1.0;

  // 模型管理
  final _modelManager = ModelManager();

  // 多题目检测
  final _questionProcessor = MultiQuestionProcessor();

  // 手动调整
  bool _isAdjusting = false;
  Rect? _selectedRect;

  // 检测结果
  List<Rect> _detectedAreas = [];
  List<Question> _processedQuestions = [];
  int _currentQuestionIndex = 0;

  // 相机预览状态
  RecognitionMode _mode = RecognitionMode.single;
  bool _isProcessing = false;
  List<Offset> _detectedCorners = [];
  final _questionDetector = QuestionDetectionService();

  // 文件选择状态
  File? _selectedFile;
  bool _showSelectionBox = false;
  Rect _selectionRect = Rect.zero;

  // 相机状态
  CameraState _cameraState = CameraState.initializing;
  Size _previewSize = const Size(1280, 720);

  // 图片相关
  Image? _capturedImage;
  File? _imageFile;
  final List<File> _testImages = [];
  String? _errorMessage;

  // 动画控制
  late final AnimationController _frameAnimationController;
  late final Animation<double> _frameAnimation;

  final int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _frameAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _frameAnimation = CurvedAnimation(
      parent: _frameAnimationController,
      curve: Curves.easeInOut,
    );

    _init();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      await _modelManager.initialize();
    } catch (e) {
      print('模型初始化失败: $e');
    }
  }

  @override
  void dispose() {
    _frameAnimationController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (!TestModeService().isTestMode) {
      await _checkCameraPermission();
    }
    await _checkOfflineCache();
    await _checkShowGuide();

    if (TestModeService().isTestMode) {
      await _loadTestImages();
    }
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = '需要相机权限才能使用此功能';
      });
    }
  }

  Future<void> _checkOfflineCache() async {
    final hasCachedQuestions = await QuestionCacheService()
        .hasOfflineQuestions();
    setState(() {
      _hasCachedQuestions = hasCachedQuestions;
    });
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

  Future<void> _pickFile() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        setState(() {
          _selectedFile = File(file.path);
          _showSelectionBox = true;
          // 初始化选择框为长条形
          _selectionRect = Rect.fromLTWH(
            50, // 左边距
            _previewSize.height / 3, // 垂直居中
            _previewSize.width - 100, // 宽度减去左右边距
            100, // 初始高度
          );
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void _handleSelectionChanged(Rect rect) {
    setState(() {
      _selectionRect = rect;
    });
  }

  Future<void> _processSelectedArea() async {
    if (_selectedFile == null) return;

    // TODO: 根据选择框位置裁剪图片

    setState(() {
      _showSelectionBox = false;
      _cameraState = CameraState.confirm;
      _capturedImage = Image.file(_selectedFile!);
    });
    _frameAnimationController.forward();
  }

  Future<void> _takePicture() async {
    if (_cameraState != CameraState.preview) return;

    setState(() {
      _showBestPractices = false;
      _showDynamicGuide = false;
    });

    // 先对焦
    try {
      if (!TestModeService().isTestMode) {
        await CameraService().controller.setFocusMode(FocusMode.auto);
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      print('Focus error: $e');
    }

    // 防抖延时
    setState(() {
      _errorMessage = '请保持手机稳定...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _errorMessage = null;
    });

    final File? imageFile;
    if (TestModeService().isTestMode && _testImages.isNotEmpty) {
      imageFile = _testImages.first;
      _testImages.removeAt(0);
    } else {
      try {
        final image = await CameraService().takePicture();
        imageFile = image != null ? File(image.path) : null;
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
        return;
      }
    }

    if (imageFile != null) {
      final file = imageFile.absolute;
      setState(() {
        _imageFile = file;
        _isProcessing = true;
      });

      try {
        // 检测所有题目区域
        final questionAreas = await _modelManager.detectQuestions(file);

        if (questionAreas.isNotEmpty) {
          // 处理检测到的题目
          final questions = await _questionProcessor.processMultipleQuestions(
            file,
          );

          setState(() {
            _detectedAreas = questionAreas;
            _processedQuestions = questions;
            _selectedRect = questionAreas.first; // 默认选择第一个题目
            _capturedImage = Image.file(file);
            _cameraState = CameraState.confirm;
          });
        } else {
          // 如果没有检测到题目，显示完整图片并允许手动调整
          setState(() {
            _capturedImage = Image.file(file);
            _cameraState = CameraState.confirm;
            _isAdjusting = true; // 启用手动调整模式
          });
        }
      } catch (e) {
        print('题目检测失败: $e');
        setState(() {
          _capturedImage = Image.file(file);
          _cameraState = CameraState.confirm;
          _isAdjusting = true;
        });
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }

      _frameAnimationController.forward();
    }
  }

  void _handleConfirm() async {
    if (_capturedImage == null) return;

    if (_processedQuestions.isNotEmpty) {
      // 有检测到的题目，跳转到结果页
      final currentQuestion = _processedQuestions[_currentQuestionIndex];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionResultPage(
            question: currentQuestion,
            image: _capturedImage!,
            boundingBox: _selectedRect ?? _detectedAreas[_currentQuestionIndex],
          ),
        ),
      );
    } else {
      // 没有检测到题目，使用手动选择的区域
      final manualQuestion = await _questionProcessor.processManualSelection(
        _imageFile!,
        _selectedRect ?? Rect.zero,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionResultPage(
            question: manualQuestion,
            image: _capturedImage!,
            boundingBox: _selectedRect ?? Rect.zero,
          ),
        ),
      );
    }

    // 重置相机状态
    setState(() {
      _cameraState = CameraState.preview;
      _capturedImage = null;
      _imageFile = null;
      _selectedRect = null;
      _detectedAreas = [];
      _processedQuestions = [];
      _currentQuestionIndex = 0;
      _isAdjusting = false;
    });
    await _frameAnimationController.reverse();
  }

  void _handleRetake() {
    setState(() {
      _cameraState = CameraState.preview;
      _capturedImage = null;
      _imageFile = null;
      _selectedRect = null;
      _detectedAreas = [];
      _processedQuestions = [];
      _currentQuestionIndex = 0;
      _isAdjusting = false;
    });
    _frameAnimationController.reverse();
  }

  void _handleAdjust() {
    setState(() {
      _isAdjusting = true;
      if (_selectedRect == null && _detectedAreas.isNotEmpty) {
        _selectedRect = _detectedAreas[_currentQuestionIndex];
      }
    });
  }

  void _handleRectChange(Rect newRect) {
    setState(() {
      _selectedRect = newRect;
    });
  }

  void _handleNextQuestion() {
    if (_currentQuestionIndex < _detectedAreas.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedRect = _detectedAreas[_currentQuestionIndex];
      });
    }
  }

  void _handlePreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedRect = _detectedAreas[_currentQuestionIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 动态引导
          if (_showDynamicGuide)
            DynamicCameraGuide(
              show: true,
              onComplete: () {
                setState(() {
                  _showDynamicGuide = false;
                  _showBestPractices = true;
                });
              },
            ),

          // 最佳实践提示
          if (_showBestPractices)
            CameraBestPractices(
              onClose: () {
                setState(() {
                  _showBestPractices = false;
                  _showGuide = false;
                });
              },
            ),

          // 相机预览
          if (!_showDynamicGuide &&
              !_showBestPractices &&
              _cameraState == CameraState.preview)
            CameraPreviewWidget(
              mode: RecognitionMode.single,
              onCapture: _takePicture,
              onModeToggle: () {}, // 不需要切换模式
              isProcessing: _cameraState == CameraState.processing,
              detectedCorners: const [], // 暂时不处理边角检测
              previewSize: _previewSize,
              errorMessage: _errorMessage,
            ),

          // 照片确认
          if (_cameraState == CameraState.confirm && _capturedImage != null)
            PhotoConfirmOverlay(
              capturedImage: _capturedImage!,
              frameAnimation: _frameAnimation,
              onConfirm: _handleConfirm,
              onRetake: _handleRetake,
              onAdjust: _handleAdjust,
            ),

          // 可拖拽选择框
          if (_showSelectionBox && _selectedFile != null)
            ResizableSelectionBox(
              initialWidth: _previewSize.width - 100,
              initialHeight: 100,
              onSelectionChanged: _handleSelectionChanged,
            ),

          // 网格线
          if (_showGrid)
            CustomPaint(size: Size.infinite, painter: grid.GridPainter()),

          // 曝光滑块
          if (_showExposureSlider)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.brightness_6, color: Colors.white),
                    Expanded(
                      child: Slider(
                        value: _currentExposure,
                        min: _minExposure,
                        max: _maxExposure,
                        onChanged: (value) {
                          setState(() {
                            _currentExposure = value;
                          });
                          CameraService().controller.setExposureOffset(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 错误提示
          if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // 底部按钮栏
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 文件选择按钮
                IconButton(
                  icon: const Icon(Icons.folder, color: Colors.white, size: 32),
                  onPressed: _pickFile,
                ),

                // 拍照按钮
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                // 网格线按钮
                IconButton(
                  icon: Icon(
                    Icons.grid_on,
                    color: _showGrid ? Colors.yellow : Colors.white,
                    size: 32,
                  ),
                  onPressed: () => setState(() {
                    _showGrid = !_showGrid;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
