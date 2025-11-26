import 'package:camera/camera.dart';
import 'dart:math' as math;

class ImageQualityAnalyzer {
  static const int minimumBrightness = 60;
  static const int maximumBrightness = 200;
  static const double minimumSharpness = 0.4;
  static const double minimumEdgeScore = 0.6;

  /// 分析图像质量，返回 0-100 的评分
  static Future<ImageQualityScore> analyzeImageQuality(
    CameraImage image,
  ) async {
    final brightnessScore = await _analyzeBrightness(image);
    final sharpnessScore = await _analyzeSharpness(image);
    final edgeScore = await _analyzeEdges(image);
    final angleScore = await _analyzeAngle(image);

    final totalScore =
        (brightnessScore * 0.25 +
                sharpnessScore * 0.3 +
                edgeScore * 0.25 +
                angleScore * 0.2)
            .round();

    return ImageQualityScore(
      totalScore: totalScore,
      brightnessScore: brightnessScore,
      sharpnessScore: sharpnessScore,
      edgeScore: edgeScore,
      angleScore: angleScore,
      issues: _generateIssues(
        brightnessScore,
        sharpnessScore,
        edgeScore,
        angleScore,
      ),
    );
  }

  static Future<int> _analyzeBrightness(CameraImage image) async {
    final yPlane = image.planes[0].bytes;
    int totalBrightness = 0;

    for (int i = 0; i < yPlane.length; i++) {
      totalBrightness += yPlane[i];
    }

    final averageBrightness = totalBrightness / yPlane.length;

    if (averageBrightness < minimumBrightness) {
      return ((averageBrightness / minimumBrightness) * 100).round();
    } else if (averageBrightness > maximumBrightness) {
      return (((255 - averageBrightness) / (255 - maximumBrightness)) * 100)
          .round();
    }

    return 100;
  }

  static Future<int> _analyzeSharpness(CameraImage image) async {
    // 使用 Laplacian 算子检测清晰度
    final yPlane = image.planes[0].bytes;
    final width = image.width;
    final height = image.height;
    double totalVariance = 0;

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final int center = yPlane[y * width + x];
        final int top = yPlane[(y - 1) * width + x];
        final int bottom = yPlane[(y + 1) * width + x];
        final int left = yPlane[y * width + (x - 1)];
        final int right = yPlane[y * width + (x + 1)];

        final laplacian = (center * 4 - top - bottom - left - right).abs();
        totalVariance += laplacian;
      }
    }

    final averageVariance = totalVariance / (width * height);
    final normalizedSharpness = math.min(1.0, averageVariance / 100);

    if (normalizedSharpness < minimumSharpness) {
      return ((normalizedSharpness / minimumSharpness) * 100).round();
    }

    return 100;
  }

  static Future<int> _analyzeEdges(CameraImage image) async {
    // 检测边缘完整性和清晰度
    final yPlane = image.planes[0].bytes;
    final width = image.width;
    final height = image.height;
    double totalEdgeStrength = 0;

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final gx = yPlane[y * width + (x + 1)] - yPlane[y * width + (x - 1)];
        final gy = yPlane[(y + 1) * width + x] - yPlane[(y - 1) * width + x];
        final gradient = math.sqrt(gx * gx + gy * gy);
        totalEdgeStrength += gradient;
      }
    }

    final averageEdgeStrength = totalEdgeStrength / (width * height);
    final normalizedEdgeScore = math.min(1.0, averageEdgeStrength / 50);

    if (normalizedEdgeScore < minimumEdgeScore) {
      return ((normalizedEdgeScore / minimumEdgeScore) * 100).round();
    }

    return 100;
  }

  static Future<int> _analyzeAngle(CameraImage image) async {
    // 分析图像倾斜角度
    // TODO: 实现倾斜检测算法
    return 90; // 临时返回固定分数
  }

  static List<String> _generateIssues(
    int brightnessScore,
    int sharpnessScore,
    int edgeScore,
    int angleScore,
  ) {
    final issues = <String>[];

    if (brightnessScore < 60) {
      issues.add('光线不足，请尝试在更明亮的环境下拍摄');
    } else if (brightnessScore > 90) {
      issues.add('光线过强，请避免直接的强光');
    }

    if (sharpnessScore < 60) {
      issues.add('图像不够清晰，请保持手机稳定');
    }

    if (edgeScore < 60) {
      issues.add('未能完整捕捉题目边缘，请调整拍摄范围');
    }

    if (angleScore < 60) {
      issues.add('拍摄角度不够平直，请保持手机水平');
    }

    return issues;
  }
}

class ImageQualityScore {
  final int totalScore;
  final int brightnessScore;
  final int sharpnessScore;
  final int edgeScore;
  final int angleScore;
  final List<String> issues;

  ImageQualityScore({
    required this.totalScore,
    required this.brightnessScore,
    required this.sharpnessScore,
    required this.edgeScore,
    required this.angleScore,
    required this.issues,
  });
}
