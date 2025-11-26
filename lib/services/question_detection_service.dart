import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:google_ml_kit/google_ml_kit.dart';

class QuestionDetectionService {
  static final QuestionDetectionService _instance =
      QuestionDetectionService._internal();
  factory QuestionDetectionService() => _instance;
  QuestionDetectionService._internal();

  final _textDetector = GoogleMlKit.vision.textRecognizer();
  final _documentScanner = GoogleMlKit.vision.documentScanner();

  /// 检测图片中的题目区域
  /// 返回题目区域的矩形坐标
  Future<Rect?> detectQuestionArea(File imageFile) async {
    try {
      // 1. 先获取图片中的所有文本区域
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textDetector.processImage(inputImage);

      if (recognizedText.blocks.isEmpty) {
        return null;
      }

      // 2. 通过文档扫描获取页面布局信息
      final document = await _documentScanner.processImage(inputImage);

      // 3. 使用启发式算法识别题目区域：
      // - 寻找数字编号开头的文本块（如"1.", "一、"等）
      // - 分析文本块的间距和对齐方式
      // - 识别题目的典型结构（题干+选项）
      var possibleQuestionBlocks = recognizedText.blocks.where((block) {
        // 检查是否以题号开头
        final text = block.text.trim();
        return _startsWithQuestionNumber(text);
      }).toList();

      if (possibleQuestionBlocks.isEmpty) {
        // 如果没有找到明显的题号，尝试其他方法
        return _findQuestionByLayout(recognizedText.blocks, document);
      }

      // 4. 获取最可能的题目区域
      final questionBlock = possibleQuestionBlocks.first;
      final surroundingBlocks = _findRelatedBlocks(
        questionBlock,
        recognizedText.blocks,
      );

      // 5. 合并相关块的边界获得完整题目区域
      return _mergeBoundingBoxes(surroundingBlocks);
    } catch (e) {
      print('题目区域检测失败: $e');
      return null;
    }
  }

  bool _startsWithQuestionNumber(String text) {
    // 匹配常见的题号格式：
    // - 数字加点：1. 2. 3.
    // - 中文数字：一、二、三、
    // - 括号数字：(1) （2）
    final patterns = [
      RegExp(r'^\d+[\.\、\)]'),
      RegExp(r'^[一二三四五六七八九十]+[\.\、\)]'),
      RegExp(r'^\([0-9]+\)'),
      RegExp(r'^（[0-9]+）'),
    ];

    return patterns.any((pattern) => pattern.hasMatch(text));
  }

  Rect? _findQuestionByLayout(List<TextBlock> blocks, Document document) {
    // 使用文档布局信息来识别题目区域
    // 比如寻找段落间距较大、对齐方式一致的文本块组合
    if (blocks.isEmpty) return null;

    // 按照垂直位置排序文本块
    final sortedBlocks = List<TextBlock>.from(blocks)
      ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    // 寻找可能的题目区域（通常是一个较大的文本块，后面跟着几个较小的选项块）
    for (var i = 0; i < sortedBlocks.length - 1; i++) {
      final currentBlock = sortedBlocks[i];
      final nextBlocks = sortedBlocks
          .sublist(i + 1)
          .takeWhile(
            (b) => b.boundingBox.top - currentBlock.boundingBox.bottom < 100,
          )
          .toList();

      if (nextBlocks.length >= 2) {
        // 至少要有题干和两个选项
        return _mergeBoundingBoxes([currentBlock, ...nextBlocks]);
      }
    }

    return null;
  }

  List<TextBlock> _findRelatedBlocks(
    TextBlock questionBlock,
    List<TextBlock> allBlocks,
  ) {
    final relatedBlocks = <TextBlock>[questionBlock];
    final questionBottom = questionBlock.boundingBox.bottom;
    final questionLeft = questionBlock.boundingBox.left;

    // 查找紧随其后的文本块（可能是选项）
    for (var block in allBlocks) {
      if (block == questionBlock) continue;

      // 检查是否是相关的选项
      if (block.boundingBox.top >= questionBlock.boundingBox.top &&
          block.boundingBox.top <= questionBottom + 100 && // 允许100像素的垂直间距
          (block.boundingBox.left - questionLeft).abs() < 50) {
        // 水平对齐度
        relatedBlocks.add(block);
      }
    }

    return relatedBlocks;
  }

  Rect _mergeBoundingBoxes(List<TextBlock> blocks) {
    if (blocks.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (var block in blocks) {
      final box = block.boundingBox;
      minX = math.min(minX, box.left);
      minY = math.min(minY, box.top);
      maxX = math.max(maxX, box.right);
      maxY = math.max(maxY, box.bottom);
    }

    // 添加一些边距
    const padding = 20.0;
    return Rect.fromLTRB(
      math.max(0, minX - padding),
      math.max(0, minY - padding),
      maxX + padding,
      maxY + padding,
    );
  }
}
