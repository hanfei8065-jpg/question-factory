import 'package:flutter/material.dart';
import '../services/camera_service.dart';
import '../models/camera_config.dart';
import 'camera_overlay.dart';
import '../models/recognition_mode.dart';
import 'smart_camera_preview.dart';

class CameraPreviewWidget extends StatefulWidget {
  final RecognitionMode mode;
  final VoidCallback onCapture;
  final VoidCallback onModeToggle;
  final bool isProcessing;
  final List<Offset> detectedCorners;
  final Size previewSize;
  final String? errorMessage;

  const CameraPreviewWidget({
    Key? key,
    required this.mode,
    required this.onCapture,
    required this.onModeToggle,
    required this.isProcessing,
    required this.detectedCorners,
    required this.previewSize,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  List<String> _currentIssues = [];

  void _handleIssuesChanged(List<String> issues) {
    setState(() {
      _currentIssues = issues;
    });
  }

  void _handleReadyToCapture(bool isReady) {
    if (isReady && !widget.isProcessing) {
      widget.onCapture();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = CameraService().controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Stack(
      children: [
        // 智能相机预览
        SmartCameraPreview(
          controller: controller,
          onIssuesChanged: _handleIssuesChanged,
          onReadyToCapture: _handleReadyToCapture,
          onCapture: widget.onCapture,
          isProcessing: widget.isProcessing,
        ),

        // 相机控件覆盖层
        CameraOverlay(
          mode: widget.mode == RecognitionMode.single
              ? CameraMode.single
              : CameraMode.batch,
          onCapture: widget.onCapture,
          onModeToggle: widget.onModeToggle,
          isProcessing: widget.isProcessing,
          detectedCorners: widget.detectedCorners,
          previewSize: widget.previewSize,
        ),

        // 问题提示列表
        if (_currentIssues.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final issue in _currentIssues)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              issue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

        // 错误消息
        if (widget.errorMessage != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
