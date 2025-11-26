import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnest_fresh/widgets/smart_camera_preview.dart';

void main() {
  testWidgets('SmartCameraPreview 智能相机功能测试', (WidgetTester tester) async {
    late List<String> currentIssues;
    bool? isReadyToCapture;
    bool wasCaptureTriggered = false;

    final controller = CameraController(
      const CameraDescription(
        name: 'test',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      ),
      ResolutionPreset.high,
    );

    // 设置初始值以避免空值错误
    final description = const CameraDescription(
      name: 'test',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    );

    controller.value = CameraValue(
      isInitialized: false,
      previewSize: null,
      isRecordingVideo: false,
      isTakingPicture: false,
      isRecordingPaused: false,
      isStreamingImages: false,
      flashMode: FlashMode.off,
      exposureMode: ExposureMode.auto,
      focusMode: FocusMode.auto,
      exposurePointSupported: false,
      focusPointSupported: false,
      deviceOrientation: DeviceOrientation.portraitUp,
      description: description,
    );

    final smartPreview = SmartCameraPreview(
      controller: controller,
      onIssuesChanged: (issues) {
        currentIssues = issues;
      },
      onReadyToCapture: (isReady) {
        isReadyToCapture = isReady;
      },
      onCapture: () {
        wasCaptureTriggered = true;
      },
      isProcessing: false,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: smartPreview)));
    await tester.pump();

    // 验证初始状态
    expect(find.byType(SmartCameraPreview), findsOneWidget);

    // 模拟相机初始化
    controller.value = CameraValue(
      isInitialized: true,
      previewSize: const Size(1280, 720),
      isRecordingVideo: false,
      isTakingPicture: false,
      isRecordingPaused: false,
      isStreamingImages: false,
      flashMode: FlashMode.off,
      exposureMode: ExposureMode.auto,
      focusMode: FocusMode.auto,
      exposurePointSupported: true,
      focusPointSupported: true,
      deviceOrientation: DeviceOrientation.portraitUp,
      description: description,
    );
    await tester.pump();

    // 验证UI组件
    expect(find.byType(CameraPreview), findsOneWidget);
    expect(find.byType(CustomPaint), findsOneWidget);

    // 验证相机准备状态
    expect(controller.value.isInitialized, isTrue);
    expect(controller.value.exposurePointSupported, isTrue);

    // 验证相机准备和拍摄逻辑
    expect(currentIssues, isNull); // 初始状态下无问题
    expect(isReadyToCapture, isFalse); // 初始状态下未准备好
    expect(wasCaptureTriggered, isFalse); // 初始状态下未触发拍摄

    // 模拟稳定状态
    await tester.pump(const Duration(seconds: 2));
    expect(isReadyToCapture, isTrue); // 稳定后准备好拍摄
    expect(wasCaptureTriggered, isTrue); // 自动触发拍摄

    // 清理
    controller.dispose();
  });
}
