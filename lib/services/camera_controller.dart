import 'package:camera/camera.dart' as camera;
import 'package:camera/camera.dart'
    show
        CameraDescription,
        CameraException,
        CameraLensDirection,
        ExposureMode,
        FlashMode,
        FocusMode,
        ImageFormatGroup,
        ResolutionPreset,
        availableCameras;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/permission_service.dart';
import '../models/camera_config.dart';

class CameraController {
  CameraController._();
  static final CameraController instance = CameraController._();

  camera.CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  camera.CameraController? get controller => _controller;

  CameraConfig _config = CameraConfig();

  CameraConfig get config => _config;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 请求相机权限
    final hasPermission = await PermissionService.requestCameraPermission();
    if (!hasPermission) {
      throw '没有相机权限，请在设置中开启';
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw '没有可用的相机';
      }

      // 默认使用后置相机
      final rearCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = camera.CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // 应用初始配置
      _controller!.setExposureMode(ExposureMode.auto);
      _controller!.setFocusMode(FocusMode.auto);

      await _controller!.initialize();
      _isInitialized = true;
    } on CameraException catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> setFlashMode(bool isOn) async {
    if (!_isInitialized || _controller == null) return;

    try {
      await _controller!.setFlashMode(isOn ? FlashMode.torch : FlashMode.off);
    } on CameraException catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> setFocusPoint(Offset point) async {
    if (!_isInitialized || _controller == null) return;

    try {
      // 设置对焦和曝光点
      await _controller!.setFocusPoint(point);
      await _controller!.setExposurePoint(point);

      // 设置自动对焦模式
      await _controller!.setFocusMode(FocusMode.auto);

      // 在对焦完成后锁定对焦以保持清晰度
      await Future.delayed(const Duration(milliseconds: 500));
      await _controller!.setFocusMode(FocusMode.locked);

      // 在1.5秒后恢复自动对焦模式
      await Future.delayed(const Duration(milliseconds: 1500));
      await _controller!.setFocusMode(FocusMode.auto);
    } on CameraException catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> enableContinuousAutoFocus() async {
    if (!_isInitialized || _controller == null) return;

    try {
      await _controller!.setFocusMode(FocusMode.auto);
    } on CameraException catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> optimizeFocusForBarcode() async {
    if (!_isInitialized || _controller == null) return;

    try {
      // 为扫描优化对焦设置
      await _controller!.setFocusMode(FocusMode.locked);
      await Future.delayed(const Duration(milliseconds: 300));
      await _controller!.setFocusMode(FocusMode.auto);
    } on CameraException catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> updateConfig(CameraConfig newConfig) async {
    if (!_isInitialized || _controller == null) return;

    try {
      _config = newConfig;

      // 更新曝光
      if (_config.autoExposure) {
        await _controller!.setExposureMode(ExposureMode.auto);
      } else {
        await _controller!.setExposureMode(ExposureMode.locked);
        await _controller!.setExposureOffset(_config.exposureOffset);
      }

      // 更新对焦
      await _controller!.setFocusMode(
        _config.autoFocus ? FocusMode.auto : FocusMode.locked,
      );

      // 更新缩放
      await _controller!.setZoomLevel(_config.zoomLevel);
    } on CameraException catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (!_isInitialized || _controller == null) return;

    try {
      final minOffset = await _controller!.getMinExposureOffset();
      final maxOffset = await _controller!.getMaxExposureOffset();
      final normalizedOffset = offset.clamp(minOffset, maxOffset);

      await _controller!.setExposureOffset(normalizedOffset);
      _config = _config.copyWith(exposureOffset: normalizedOffset);
    } on CameraException catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    if (!_isInitialized || _controller == null) return;

    try {
      final minZoom = await _controller!.getMinZoomLevel();
      final maxZoom = await _controller!.getMaxZoomLevel();
      final normalizedZoom = zoom.clamp(minZoom, maxZoom);

      await _controller!.setZoomLevel(normalizedZoom);
      _config = _config.copyWith(zoomLevel: normalizedZoom);
    } on CameraException catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> toggleExposureMode() async {
    if (!_isInitialized || _controller == null) return;

    try {
      final newMode = _config.autoExposure
          ? ExposureMode.locked
          : ExposureMode.auto;

      await _controller!.setExposureMode(newMode);
      _config = _config.copyWith(autoExposure: !_config.autoExposure);
    } on CameraException catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
  }

  void _handleCameraError(CameraException e) {
    String errorMessage;
    switch (e.code) {
      case 'CameraAccessDenied':
        errorMessage = '相机权限被拒绝';
        break;
      case 'CameraNotFound':
        errorMessage = '找不到可用的相机';
        break;
      default:
        errorMessage = '相机初始化失败: ${e.description}';
    }
    debugPrint(errorMessage);
    throw errorMessage;
  }
}
