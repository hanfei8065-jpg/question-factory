import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import '../utils/image_quality_analyzer.dart';

class SmartCameraAssistant {
  static final SmartCameraAssistant _instance =
      SmartCameraAssistant._internal();
  factory SmartCameraAssistant() => _instance;
  SmartCameraAssistant._internal();

  Timer? _stabilityCheckTimer;
  Timer? _exposureAdjustTimer;
  bool _isStable = false;
  double _lastExposure = 0.0;
  int _stableFrameCount = 0;
  List<double> _recentMotions = [];
  CameraImage? _lastFrame;

  static const int _requiredStableFrames = 10;
  static const double _motionThreshold = 0.02;
  static const double _exposureAdjustInterval = 0.2;

  void startStabilityCheck(
    CameraController controller,
    Function(bool) onStabilityChanged,
  ) {
    _stabilityCheckTimer?.cancel();
    controller.startImageStream((image) {
      _lastFrame = image;
    });
    _stabilityCheckTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _checkStability(controller, onStabilityChanged),
    );
  }

  void startAutoExposure(CameraController controller) {
    _exposureAdjustTimer?.cancel();
    if (_lastFrame == null) {
      controller.startImageStream((image) {
        _lastFrame = image;
      });
    }
    _exposureAdjustTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _adjustExposure(controller),
    );
  }

  void stop() {
    _stabilityCheckTimer?.cancel();
    _exposureAdjustTimer?.cancel();
    _isStable = false;
    _stableFrameCount = 0;
    _recentMotions.clear();
    _lastFrame = null;
  }

  Future<void> _checkStability(
    CameraController controller,
    Function(bool) onStabilityChanged,
  ) async {
    if (!controller.value.isInitialized) return;

    try {
      final image = _lastFrame;
      if (image == null) return;

      // 计算帧间运动
      final motion = await _calculateMotion(image);
      _recentMotions.add(motion);
      if (_recentMotions.length > 5) {
        _recentMotions.removeAt(0);
      }

      // 检查稳定性
      final averageMotion =
          _recentMotions.reduce((a, b) => a + b) / _recentMotions.length;
      final isCurrentlyStable = averageMotion < _motionThreshold;

      if (isCurrentlyStable) {
        _stableFrameCount++;
        if (_stableFrameCount >= _requiredStableFrames && !_isStable) {
          _isStable = true;
          onStabilityChanged(true);
        }
      } else {
        if (_isStable) {
          _isStable = false;
          onStabilityChanged(false);
        }
        _stableFrameCount = 0;
      }
    } catch (e) {
      print('Stability check error: $e');
    }
  }

  Future<double> _calculateMotion(CameraImage currentFrame) async {
    // TODO: 实现基于亮度变化的运动检测
    if (currentFrame.planes.isEmpty) return 0.0;

    final plane = currentFrame.planes[0];
    final data = plane.bytes;
    int sum = 0;
    for (int i = 0; i < data.length; i += plane.bytesPerRow) {
      sum += data[i];
    }
    return sum / (data.length / plane.bytesPerRow) / 255;
  }

  Future<void> _adjustExposure(CameraController controller) async {
    if (!controller.value.isInitialized) return;

    try {
      final image = _lastFrame;
      if (image == null) return;

      final double exposureRange = controller.value.exposurePointSupported
          ? 2.0
          : 1.0;
      final score = await ImageQualityAnalyzer.analyzeImageQuality(image);

      if (score.brightnessScore < 60) {
        // 增加曝光度
        final newExposure = _lastExposure + _exposureAdjustInterval;
        if (newExposure <= exposureRange) {
          await controller.setExposureOffset(newExposure);
          _lastExposure = newExposure;
        }
      } else if (score.brightnessScore > 90) {
        // 降低曝光度
        final newExposure = _lastExposure - _exposureAdjustInterval;
        if (newExposure >= -exposureRange) {
          await controller.setExposureOffset(newExposure);
          _lastExposure = newExposure;
        }
      }
    } catch (e) {
      print('Auto exposure error: $e');
    }
  }

  String? getStabilityMessage() {
    if (!_isStable) {
      if (_stableFrameCount < _requiredStableFrames ~/ 2) {
        return '手机晃动较大，请保持稳定';
      } else {
        return '即将完成稳定，请继续保持';
      }
    }
    return null;
  }
}
