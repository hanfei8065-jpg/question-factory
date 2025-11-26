import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? controller;
  bool isInitialized = false;
  Size? previewSize;

  Function(CameraImage)? _imageStreamCallback;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw 'No cameras available';
    }
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller!.initialize();
    isInitialized = true;

    previewSize = Size(
      controller!.value.previewSize?.width ?? 1280,
      controller!.value.previewSize?.height ?? 720,
    );
  }

  Future<void> setFlashMode(bool enabled) async {
    if (controller == null) return;
    await controller!.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
  }

  Future<XFile?> takePicture() async {
    if (!isInitialized || controller == null) return null;

    try {
      final image = await controller!.takePicture();
      return image;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  Future<void> startImageStream(Function(CameraImage) callback) async {
    if (!isInitialized || controller == null) return;
    _imageStreamCallback = callback;
    await controller!.startImageStream((image) {
      _imageStreamCallback?.call(image);
    });
  }

  Future<void> stopImageStream() async {
    if (!isInitialized || controller == null) return;
    await controller!.stopImageStream();
    _imageStreamCallback = null;
  }

  void dispose() {
    if (isInitialized && controller != null) {
      controller!.dispose();
      controller = null;
      isInitialized = false;
    }
  }
}
