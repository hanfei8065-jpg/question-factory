import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/smart_camera_assistant.dart';
import '../utils/image_quality_analyzer.dart';
import '../services/batch_photo_analyzer.dart';

class SmartCameraPreview extends StatefulWidget {
  final CameraController controller;
  final Function(List<String>) onIssuesChanged;
  final Function(bool) onReadyToCapture;
  final bool isBatchMode;
  final List<CameraImage> batchImages;
  final bool isProcessing;
  final VoidCallback onCapture;

  const SmartCameraPreview({
    super.key,
    required this.controller,
    required this.onIssuesChanged,
    required this.onReadyToCapture,
    required this.onCapture,
    required this.isProcessing,
    this.isBatchMode = false,
    this.batchImages = const [],
  });

  @override
  State<SmartCameraPreview> createState() => _SmartCameraPreviewState();
}

class _SmartCameraPreviewState extends State<SmartCameraPreview> {
  final _assistant = SmartCameraAssistant();
  bool _isStable = false;
  List<String> _currentIssues = [];

  @override
  void initState() {
    super.initState();
    _startSmartAssistance();
  }

  @override
  void dispose() {
    _assistant.stop();
    super.dispose();
  }

  void _updateReadyState() {
    final isReady = _isStable && _currentIssues.isEmpty;
    widget.onReadyToCapture(isReady);
  }

  void _startSmartAssistance() {
    // 启动防抖检测
    _assistant.startStabilityCheck(
      widget.controller,
      (isStable) {
        setState(() {
          _isStable = isStable;
        });
        _updateReadyState();
      },
    );

    // 启动自动曝光
    _assistant.startAutoExposure(widget.controller);

    // 定期更新拍摄建议
    widget.controller.startImageStream((image) async {
      try {
        if (!mounted) return;
        
        final List<String> issues = [];
        
        // 分析图像质量
        final quality = await ImageQualityAnalyzer.analyzeImageQuality(image);
        issues.addAll(quality.issues);
        
        // 检查稳定性
        final stabilityMessage = _assistant.getStabilityMessage();
        if (stabilityMessage != null) {
          issues.add(stabilityMessage);
        }

        // 批量模式下的额外分析
        if (widget.isBatchMode && widget.batchImages.isNotEmpty) {
          final batchResult = await BatchPhotoAnalyzer().analyzeBatchImage(
            image,
            widget.batchImages,
          );
          
          issues.addAll(batchResult.duplicateWarnings);
          issues.addAll(batchResult.similarityWarnings);
          issues.addAll(batchResult.qualityWarnings);
        }

        if (!mounted) return;
        
        setState(() {
          _currentIssues = issues;
        });
        widget.onIssuesChanged(issues);
        _updateReadyState();
      } catch (e) {
        print('Error analyzing image: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return Container(color: Colors.black);
    }

    final scale = 1 / (widget.controller.value.aspectRatio * 
        MediaQuery.of(context).size.aspectRatio);
    
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: CameraPreview(widget.controller),
          ),
        ),
      ),
    );
  }
}