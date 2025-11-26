import 'package:flutter/material.dart';
import '../models/camera_config.dart';
import '../pages/camera_page.dart';
import 'edge_detection_overlay.dart';

class CameraOverlay extends StatelessWidget {
  final CameraMode mode;
  final VoidCallback onCapture;
  final VoidCallback onModeToggle;
  final bool isProcessing;
  final List<Offset> detectedCorners;
  final Size previewSize;

  const CameraOverlay({
    super.key,
    required this.mode,
    required this.onCapture,
    required this.onModeToggle,
    required this.isProcessing,
    this.detectedCorners = const [],
    required this.previewSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (detectedCorners.isNotEmpty)
          EdgeDetectionOverlay(
            corners: detectedCorners,
            previewSize: previewSize,
            screenSize: MediaQuery.of(context).size,
          ),
        // 顶部栏
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mode == CameraMode.single ? '单题模式' : '批量模式',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                IconButton(
                  icon: Icon(
                    mode == CameraMode.single
                        ? Icons.photo_library
                        : Icons.photo_camera,
                    color: Colors.white,
                  ),
                  onPressed: onModeToggle,
                ),
              ],
            ),
          ),
        ),

        // 取景框和边框检测
        Center(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: detectedCorners.length == 4
                        ? Colors.green
                        : Colors.white,
                    width: 2,
                  ),
                ),
              ),
              if (detectedCorners.isNotEmpty)
                EdgeDetectionOverlay(
                  corners: detectedCorners,
                  previewSize: previewSize,
                  screenSize: MediaQuery.of(context).size,
                ),
            ],
          ),
        ),

        // 底部按钮
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: EdgeInsets.only(
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: isProcessing ? null : onCapture,
                  backgroundColor: Colors.white,
                  child: isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera, color: Colors.black, size: 32),
                ),
              ],
            ),
          ),
        ),

        // 拍照提示文字
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).padding.bottom + 100,
          child: Text(
            mode == CameraMode.single ? '将题目放在取景框内，点击拍照' : '批量模式：连续拍摄多个题目',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
