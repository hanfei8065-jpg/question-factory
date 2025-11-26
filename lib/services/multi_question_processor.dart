import 'dart:io';
import 'package:flutter/material.dart';
import '../models/question.dart';

class MultiQuestionProcessor {
  static final MultiQuestionProcessor _instance =
      MultiQuestionProcessor._internal();
  factory MultiQuestionProcessor() => _instance;
  MultiQuestionProcessor._internal();

  final _advancedDetector = AdvancedDetectionService();

  /// 处理多个题目区域
  /// 返回识别出的所有题目
  Future<List<Question>> processMultipleQuestions(File imageFile) async {
    final questions = <Question>[];

    try {
      // 1. 获取所有题目区域
      final questionAreas = await _advancedDetector.detectQuestionAreas(
        imageFile,
      );

      // 2. 按照从上到下、从左到右的顺序排序
      final sortedAreas = _sortQuestionAreas(questionAreas);

      // 3. 逐个处理每个题目区域
      for (var area in sortedAreas) {
        try {
          // 裁剪并处理每个题目区域
          final questionImage = await _cropImageArea(imageFile, area);
          final question = await _processQuestionImage(questionImage);
          if (question != null) {
            questions.add(question);
          }
        } catch (e) {
          print('处理单个题目失败: $e');
          continue;
        }
      }
    } catch (e) {
      print('批量处理题目失败: $e');
    }

    return questions;
  }

  List<Rect> _sortQuestionAreas(List<Rect> areas) {
    // 定义排序规则：
    // 1. 首先按Y坐标排序（从上到下）
    // 2. 如果Y坐标相近（差距小于一定阈值），则按X坐标排序（从左到右）
    const yThreshold = 50.0; // Y坐标差距阈值

    return List<Rect>.from(areas)..sort((a, b) {
      if ((a.top - b.top).abs() > yThreshold) {
        return a.top.compareTo(b.top);
      }
      return a.left.compareTo(b.left);
    });
  }

  Future<File> _cropImageArea(File originalImage, Rect area) async {
    // 使用image包裁剪图片
    final image = await decodeImageFromFile(originalImage.path);
    if (image == null) throw Exception('无法解码图片');

    final croppedImage = copyCrop(
      image,
      x: area.left.toInt(),
      y: area.top.toInt(),
      width: area.width.toInt(),
      height: area.height.toInt(),
    );

    // 保存裁剪后的图片
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await tempFile.writeAsBytes(encodeJpg(croppedImage));
    return tempFile;
  }

  Future<Question?> _processQuestionImage(File questionImage) async {
    try {
      // 1. 文本识别
      final recognizedText = await _recognizeText(questionImage);
      if (recognizedText.isEmpty) return null;

      // 2. 题目结构分析
      final components = _analyzeQuestionStructure(recognizedText);
      if (!components.isValid) return null;

      // 3. 构建题目对象
      return Question(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: components.stem,
        options: components.options,
        subject: _detectSubject(components.stem),
        type: _detectQuestionType(components),
        difficulty: _estimateDifficulty(components),
        imageFile: questionImage,
      );
    } catch (e) {
      print('处理单个题目图片失败: $e');
      return null;
    }
  }

  Future<String> _recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  QuestionComponents _analyzeQuestionStructure(String text) {
    final lines = text.split('\n');
    final components = QuestionComponents();

    var currentSection = QuestionSection.stem;
    var currentText = StringBuffer();

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // 检测是否是选项开始
      if (RegExp(r'^[A-D][\.\、\)]').hasMatch(line)) {
        if (currentSection == QuestionSection.stem) {
          components.stem = currentText.toString().trim();
          currentText.clear();
          currentSection = QuestionSection.options;
        }
        components.options.add(line);
      } else {
        if (currentSection == QuestionSection.stem) {
          currentText.writeln(line);
        } else {
          // 如果已经在处理选项，且这行不是新选项，则附加到最后一个选项
          if (components.options.isNotEmpty) {
            components.options.last += '\n$line';
          }
        }
      }
    }

    // 如果没有遇到选项，所有内容都是题干
    if (components.stem.isEmpty) {
      components.stem = currentText.toString().trim();
    }

    return components;
  }

  String _detectSubject(String stem) {
    // 基于题干内容识别学科
    final subjectKeywords = {
      '数学': RegExp(r'计算|方程|函数|几何|证明'),
      '物理': RegExp(r'力|速度|质量|电|热|光|动能|势能'),
      '化学': RegExp(r'元素|反应|氧化|酸碱|离子|溶液'),
      '生物': RegExp(r'细胞|器官|光合作用|遗传|进化|生态'),
      // 可以添加更多学科的关键词
    };

    for (var entry in subjectKeywords.entries) {
      if (entry.value.hasMatch(stem)) {
        return entry.key;
      }
    }

    return '未知';
  }

  String _detectQuestionType(QuestionComponents components) {
    if (components.options.isNotEmpty) {
      return '选择题';
    }

    final stem = components.stem.toLowerCase();
    if (stem.contains('证明')) return '证明题';
    if (stem.contains('计算')) return '计算题';
    if (stem.contains('解答')) return '解答题';
    if (RegExp(r'_+|\.+').hasMatch(stem)) return '填空题';

    return '其他';
  }

  String _estimateDifficulty(QuestionComponents components) {
    var score = 0;

    // 1. 基于题干长度
    if (components.stem.length > 200)
      score += 2;
    else if (components.stem.length > 100)
      score += 1;

    // 2. 基于题目类型
    final type = _detectQuestionType(components);
    switch (type) {
      case '选择题':
        score += 1;
      case '填空题':
        score += 2;
      case '计算题':
        score += 3;
      case '证明题':
        score += 4;
      case '解答题':
        score += 3;
    }

    // 3. 基于关键词
    final complexityIndicators = [
      '证明',
      '推导',
      '分析',
      '论证',
      '综合',
      '比较',
      '评价',
      '设计',
    ];

    for (var indicator in complexityIndicators) {
      if (components.stem.contains(indicator)) score += 1;
    }

    // 转换分数为难度等级
    if (score <= 2) return '简单';
    if (score <= 4) return '中等';
    return '困难';
  }
}

class QuestionComponents {
  String stem = '';
  List<String> options = [];

  bool get isValid => stem.isNotEmpty;
}

enum QuestionSection { stem, options }
