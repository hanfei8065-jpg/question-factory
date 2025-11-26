import 'package:camera/camera.dart';
import '../utils/image_quality_analyzer.dart';

class BatchAnalysisResult {
  final List<String> duplicateWarnings;
  final List<String> similarityWarnings;
  final List<String> qualityWarnings;
  final bool isAcceptable;

  const BatchAnalysisResult({
    required this.duplicateWarnings,
    required this.similarityWarnings,
    required this.qualityWarnings,
    required this.isAcceptable,
  });
}

class BatchPhotoAnalyzer {
  static final BatchPhotoAnalyzer _instance = BatchPhotoAnalyzer._internal();
  factory BatchPhotoAnalyzer() => _instance;
  BatchPhotoAnalyzer._internal();

  static const int _minQualityScore = 70;
  static const double _similarityThreshold = 0.85;

  Future<BatchAnalysisResult> analyzeBatchImage(
    CameraImage newImage,
    List<CameraImage> existingImages,
  ) async {
    final List<String> duplicateWarnings = [];
    final List<String> similarityWarnings = [];
    final List<String> qualityWarnings = [];
    bool isAcceptable = true;

    // 质量分析
    final qualityScore = await ImageQualityAnalyzer.analyzeImageQuality(
      newImage,
    );
    if (qualityScore.totalScore < _minQualityScore) {
      qualityWarnings.addAll(qualityScore.issues);
      isAcceptable = false;
    }

    // 重复检测
    for (int i = 0; i < existingImages.length; i++) {
      final similarity = await _calculateImageSimilarity(
        newImage,
        existingImages[i],
      );

      if (similarity > _similarityThreshold) {
        final warning = '新拍摄的题目与第 ${i + 1} 张图片相似度过高，可能是重复拍摄';
        similarityWarnings.add(warning);
        isAcceptable = false;
        break;
      }
    }

    return BatchAnalysisResult(
      duplicateWarnings: duplicateWarnings,
      similarityWarnings: similarityWarnings,
      qualityWarnings: qualityWarnings,
      isAcceptable: isAcceptable,
    );
  }

  Future<double> _calculateImageSimilarity(
    CameraImage image1,
    CameraImage image2,
  ) async {
    if (image1.planes.isEmpty || image2.planes.isEmpty) return 0.0;

    final plane1 = image1.planes[0];
    final plane2 = image2.planes[0];
    final bytes1 = plane1.bytes;
    final bytes2 = plane2.bytes;

    // 计算两幅图像的亮度直方图
    final hist1 = _calculateHistogram(bytes1);
    final hist2 = _calculateHistogram(bytes2);

    // 使用直方图相关性作为相似度度量
    return _calculateHistogramCorrelation(hist1, hist2);
  }

  List<int> _calculateHistogram(List<int> bytes) {
    final histogram = List<int>.filled(256, 0);
    for (final byte in bytes) {
      histogram[byte]++;
    }
    return histogram;
  }

  double _calculateHistogramCorrelation(List<int> hist1, List<int> hist2) {
    double numerator = 0;
    double denominator1 = 0;
    double denominator2 = 0;

    // 计算直方图的平均值
    final mean1 = hist1.reduce((a, b) => a + b) / hist1.length;
    final mean2 = hist2.reduce((a, b) => a + b) / hist2.length;

    // 计算相关系数
    for (int i = 0; i < 256; i++) {
      final diff1 = hist1[i] - mean1;
      final diff2 = hist2[i] - mean2;
      numerator += diff1 * diff2;
      denominator1 += diff1 * diff1;
      denominator2 += diff2 * diff2;
    }

    if (denominator1 == 0 || denominator2 == 0) return 0;
    return numerator / (sqrt(denominator1) * sqrt(denominator2));
  }

  double sqrt(double x) {
    if (x <= 0) return 0;
    double r = x;
    for (int i = 0; i < 10; i++) {
      r = (r + x / r) / 2;
    }
    return r;
  }
}
