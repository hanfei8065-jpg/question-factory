import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;

class ModelManager {
  static final ModelManager _instance = ModelManager._internal();
  factory ModelManager() => _instance;
  ModelManager._internal();

  Interpreter? _interpreter;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 加载模型文件
      final modelFile = await _getModel();
      _interpreter = await Interpreter.fromFile(modelFile);
      _isInitialized = true;
    } catch (e) {
      print('模型初始化失败: $e');
      rethrow;
    }
  }

  Future<File> _getModel() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelPath = '${appDir.path}/question_detector.tflite';
    final modelFile = File(modelPath);

    // 如果模型文件不存在，从assets复制
    if (!modelFile.existsSync()) {
      final modelBytes = await rootBundle.load(
        'assets/models/question_detector.tflite',
      );
      await modelFile.writeAsBytes(modelBytes.buffer.asUint8List());
    }

    return modelFile;
  }

  Future<List<Rect>> detectQuestions(File imageFile) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('模型未初始化');
    }

    try {
      // 1. 加载并预处理图像
      final processedImage = await _preprocessImage(imageFile);

      // 2. 运行模型推理
      final output = List<double>.filled(100 * 5, 0); // 最多检测100个区域，每个5个值
      final inputs = [processedImage];
      final outputs = {0: output};

      _interpreter!.runForMultipleInputs(inputs, outputs);

      // 3. 解析输出结果
      final boxes = <Rect>[];
      for (var i = 0; i < output.length; i += 5) {
        final confidence = output[i + 4];
        if (confidence < 0.5) continue; // 置信度过滤

        boxes.add(
          Rect.fromLTRB(
            output[i] * imageFile.lengthSync(),
            output[i + 1] * imageFile.lengthSync(),
            output[i + 2] * imageFile.lengthSync(),
            output[i + 3] * imageFile.lengthSync(),
          ),
        );
      }

      // 4. 应用非极大值抑制
      return _nonMaxSuppression(boxes, 0.5);
    } catch (e) {
      print('题目检测失败: $e');
      return [];
    }
  }

  Future<List<double>> _preprocessImage(File imageFile) async {
    // 读取图像
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('无法解码图像');

    // 调整大小
    final resized = img.copyResize(image, width: 640, height: 640);

    // 转换为浮点数组并归一化
    final buffer = List<double>.filled(640 * 640, 0);
    for (var y = 0; y < resized.height; y++) {
      for (var x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        buffer[y * resized.width + x] = (pixel >> 16 & 0xFF) / 255.0;
      }
    }

    return buffer;
  }

  List<Rect> _nonMaxSuppression(List<Rect> boxes, double threshold) {
    if (boxes.isEmpty) return [];

    // 按面积排序
    boxes.sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));

    final selected = <Rect>[];
    final suppressed = Set<int>();

    for (var i = 0; i < boxes.length; i++) {
      if (suppressed.contains(i)) continue;

      selected.add(boxes[i]);

      for (var j = i + 1; j < boxes.length; j++) {
        if (suppressed.contains(j)) continue;

        if (_calculateIoU(boxes[i], boxes[j]) > threshold) {
          suppressed.add(j);
        }
      }
    }

    return selected;
  }

  double _calculateIoU(Rect box1, Rect box2) {
    final intersection = box1.intersect(box2);
    final union =
        box1.width * box1.height +
        box2.width * box2.height -
        intersection.width * intersection.height;

    return (intersection.width * intersection.height) / union;
  }

  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}
