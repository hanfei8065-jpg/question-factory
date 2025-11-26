import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';
import 'package:image/image.dart' as img;

class AdvancedDetectionService {
  static final AdvancedDetectionService _instance =
      AdvancedDetectionService._internal();
  factory AdvancedDetectionService() => _instance;
  AdvancedDetectionService._internal();

  late final Interpreter _interpreter;
  final _textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<void> initialize() async {
    // 加载经过自定义训练的TensorFlow Lite模型
    _interpreter = await Interpreter.fromAsset(
      'assets/models/question_detector.tflite',
    );
  }

  Future<List<Rect>> detectQuestionAreas(File imageFile) async {
    final detectedAreas = <Rect>[];

    try {
      // 1. 图像预处理
      final processedImage = await _preprocessImage(imageFile);

      // 2. 文本识别
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // 3. 使用自定义模型进行区域检测
      final modelOutput = await _runInference(processedImage);

      // 4. 结合文本识别和区域检测结果
      final questionBlocks = _analyzeStructure(recognizedText, modelOutput);

      // 5. 应用启发式规则优化结果
      final optimizedAreas = _optimizeDetection(questionBlocks);

      detectedAreas.addAll(optimizedAreas);
    } catch (e) {
      print('高级题目检测失败: $e');
    }

    return detectedAreas;
  }

  Future<img.Image> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) throw Exception('无法解析图片');

    // 1. 自适应阈值处理，提高文本对比度
    image = img.adaptiveThreshold(image);

    // 2. 透视校正
    final corners = await _detectDocumentCorners(image);
    if (corners != null) {
      image = img.perspective(image, corners);
    }

    // 3. 降噪处理
    image = img.gaussianBlur(image, radius: 1);

    // 4. 统一缩放到模型期望的输入大小
    image = img.copyResize(
      image,
      width: 640,
      height: 640,
      interpolation: img.Interpolation.cubic,
    );

    return image;
  }

  Future<List<Point<int>>?> _detectDocumentCorners(img.Image image) async {
    // 使用ML Kit的DocumentScanner检测文档边角
    try {
      final inputImage = InputImage.fromBytes(
        bytes: img.encodeJpg(image),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.width * 4,
        ),
      );

      final scanner = GoogleMlKit.vision.documentScanner();
      final corners = await scanner.processImage(inputImage);

      if (corners.isEmpty) return null;

      return corners
          .map((corner) => Point(corner.x.toInt(), corner.y.toInt()))
          .toList();
    } catch (e) {
      print('文档边角检测失败: $e');
      return null;
    }
  }

  Future<List<List<double>>> _runInference(img.Image image) async {
    // 准备模型输入数据
    final imageMatrix = _imageToMatrix(image);

    // 运行模型推理
    final outputBuffer = List<double>.filled(
      100 * 4,
      0,
    ); // 假设最多检测100个区域，每个区域4个坐标
    final outputs = {0: outputBuffer};

    await _interpreter.runForMultipleInputs([imageMatrix], outputs);

    // 解析输出结果
    final results = <List<double>>[];
    for (var i = 0; i < outputBuffer.length; i += 4) {
      if (outputBuffer[i] == 0 && outputBuffer[i + 1] == 0) break;
      results.add(outputBuffer.sublist(i, i + 4));
    }

    return results;
  }

  List<double> _imageToMatrix(img.Image image) {
    final buffer = List<double>.filled(640 * 640, 0);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        // 转换为灰度值并归一化到0-1范围
        buffer[y * image.width + x] = ((pixel >> 16) & 0xFF) / 255.0;
      }
    }
    return buffer;
  }

  List<TextBlock> _analyzeStructure(
    RecognizedText recognizedText,
    List<List<double>> modelOutput,
  ) {
    final blocks = <TextBlock>[];

    // 1. 分析文本布局
    for (var block in recognizedText.blocks) {
      // 检查文本特征
      final isLikelyQuestion = _isQuestionText(block.text);
      final hasQuestionStructure = _hasTypicalQuestionStructure(block);

      if (isLikelyQuestion || hasQuestionStructure) {
        blocks.add(block);
      }
    }

    // 2. 与模型输出结果对比验证
    _validateWithModelOutput(blocks, modelOutput);

    return blocks;
  }

  bool _isQuestionText(String text) {
    // 增强题目文本特征识别
    final patterns = [
      RegExp(r'^\d+[\.\、\)]'), // 数字编号
      RegExp(r'^[一二三四五六七八九十]+[\.\、\)]'), // 中文编号
      RegExp(r'^\([A-Z]\)'), // 选项标记
      RegExp(r'[?？]$'), // 问号结尾
      RegExp(r'(选择|判断|计算|证明|解答|填空|作答)[:：]'), // 题型标记
    ];

    return patterns.any((pattern) => pattern.hasMatch(text.trim()));
  }

  bool _hasTypicalQuestionStructure(TextBlock block) {
    // 检查是否具有典型的题目结构特征
    final lines = block.text.split('\n');
    if (lines.length < 2) return false;

    // 检查是否包含选项
    final hasOptions = lines.any(
      (line) => RegExp(r'^[A-D][\.\、\)]').hasMatch(line.trim()),
    );

    // 检查段落缩进
    final hasIndentation = lines.any(
      (line) => line.startsWith('    ') || line.startsWith('\t'),
    );

    // 检查是否包含题目关键词
    final hasKeywords = RegExp(
      r'(求|计算|证明|解|说明|比较|选择|判断)',
      multiLine: true,
    ).hasMatch(block.text);

    return hasOptions || (hasIndentation && hasKeywords);
  }

  void _validateWithModelOutput(
    List<TextBlock> blocks,
    List<List<double>> modelOutput,
  ) {
    // 使用模型输出结果验证和调整文本块
    for (var output in modelOutput) {
      final modelRect = Rect.fromLTRB(
        output[0],
        output[1],
        output[2],
        output[3],
      );

      // 查找与模型预测区域重叠的文本块
      for (var block in blocks) {
        final intersection = _calculateIntersection(
          block.boundingBox,
          modelRect,
        );
        if (intersection > 0.7) {
          // 如果重叠度超过70%
          // 调整文本块边界以更好地匹配模型预测
          block.boundingBox = _mergeRects(block.boundingBox, modelRect);
        }
      }
    }
  }

  double _calculateIntersection(Rect r1, Rect r2) {
    final intersection = r1.intersect(r2);
    final unionArea =
        r1.width * r1.height +
        r2.width * r2.height -
        intersection.width * intersection.height;
    return (intersection.width * intersection.height) / unionArea;
  }

  Rect _mergeRects(Rect r1, Rect r2) {
    return Rect.fromLTRB(
      math.min(r1.left, r2.left),
      math.min(r1.top, r2.top),
      math.max(r1.right, r2.right),
      math.max(r1.bottom, r2.bottom),
    );
  }

  List<Rect> _optimizeDetection(List<TextBlock> blocks) {
    final optimizedAreas = <Rect>[];

    // 1. 合并相邻的文本块
    var currentGroup = <TextBlock>[];

    for (var i = 0; i < blocks.length; i++) {
      currentGroup.add(blocks[i]);

      // 检查是否需要结束当前组
      if (i == blocks.length - 1 ||
          !_areBlocksRelated(blocks[i], blocks[i + 1])) {
        if (currentGroup.isNotEmpty) {
          // 计算组的边界框
          final groupRect = _calculateGroupBoundingBox(currentGroup);
          optimizedAreas.add(groupRect);
          currentGroup = [];
        }
      }
    }

    // 2. 调整边界以包含完整的文本行
    final adjustedAreas = optimizedAreas.map((area) {
      return _adjustToCompleteLines(area, blocks);
    }).toList();

    return adjustedAreas;
  }

  bool _areBlocksRelated(TextBlock b1, TextBlock b2) {
    // 检查两个文本块是否属于同一道题
    final verticalGap = (b2.boundingBox.top - b1.boundingBox.bottom).abs();
    final horizontalOverlap = math.max(
      0,
      math.min(b1.boundingBox.right, b2.boundingBox.right) -
          math.max(b1.boundingBox.left, b2.boundingBox.left),
    );

    return verticalGap < 50 && horizontalOverlap > 0;
  }

  Rect _calculateGroupBoundingBox(List<TextBlock> group) {
    if (group.isEmpty) return Rect.zero;

    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;

    for (var block in group) {
      left = math.min(left, block.boundingBox.left);
      top = math.min(top, block.boundingBox.top);
      right = math.max(right, block.boundingBox.right);
      bottom = math.max(bottom, block.boundingBox.bottom);
    }

    // 添加边距
    const padding = 10.0;
    return Rect.fromLTRB(
      left - padding,
      top - padding,
      right + padding,
      bottom + padding,
    );
  }

  Rect _adjustToCompleteLines(Rect area, List<TextBlock> allBlocks) {
    // 确保边界框包含完整的文本行
    var adjustedArea = area;

    for (var block in allBlocks) {
      if (_hasPartialOverlap(block.boundingBox, area)) {
        adjustedArea = _mergeRects(adjustedArea, block.boundingBox);
      }
    }

    return adjustedArea;
  }

  bool _hasPartialOverlap(Rect r1, Rect r2) {
    return !(r1.right < r2.left ||
        r1.left > r2.right ||
        r1.bottom < r2.top ||
        r1.top > r2.bottom);
  }
}
