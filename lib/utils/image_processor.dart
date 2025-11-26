import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class _IsolateData {
  final String inputPath;
  final SendPort sendPort;

  _IsolateData({required this.inputPath, required this.sendPort});
}

class _Line {
  final int x1, y1, x2, y2;
  _Line(this.x1, this.y1, this.x2, this.y2);
}

class _BoundingBox {
  final int left;
  final int top;
  final int width;
  final int height;

  _BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class ImageProcessor {
  static const int maxImageSize = 1920; // 最大图片尺寸
  static const int jpegQuality = 85; // JPEG压缩质量
  static const double minConfidence = 0.6; // 最小边缘检测置信度

  // 在独立isolate中处理图片
  static Future<File> processImage(File inputFile) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _processImageIsolate,
      _IsolateData(inputPath: inputFile.path, sendPort: receivePort.sendPort),
    );

    final result = await receivePort.first as String;
    return File(result);
  }

  static Future<void> _processImageIsolate(_IsolateData data) async {
    try {
      // 读取图片
      final bytes = await File(data.inputPath).readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) throw Exception('Failed to decode image');

      // 自动亮度和对比度调整
      image = _autoAdjustBrightnessContrast(image);
      
      // 边缘检测和自动裁剪
      var boundingBox = _detectQuestionBoundingBox(image);
      if (boundingBox != null) {
        image = _cropToRect(image, boundingBox);
      }

      // 倾斜校正
      image = _correctSkew(image);

      // 大小调整（如果需要）
      if (image.width > maxImageSize || image.height > maxImageSize) {
        image = _resizeImage(image);
      }

      // 图像增强处理链
      image = _enhanceImage(image);

      // 保存处理后的图片
      final outputPath = data.inputPath.replaceAll(
        RegExp(r'\.[^\.]*$'),
        '_processed.jpg',
      );

      final processedBytes = img.encodeJpg(image, quality: jpegQuality);
      await File(outputPath).writeAsBytes(processedBytes);

      // 返回处理后的图片路径
      data.sendPort.send(outputPath);
    } catch (e) {
      print('Error processing image: $e');
      data.sendPort.send(data.inputPath); // 出错时返回原始图片路径
    }
  }

  // 自动调整亮度和对比度
  static img.Image _autoAdjustBrightnessContrast(img.Image image) {
    // 计算图像直方图
    final histogram = List<int>.filled(256, 0);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final brightness = ((pixel.r + pixel.g + pixel.b) / 3).round();
      histogram[brightness]++;
    }

    // 计算累积分布函数
    final cdf = List<int>.filled(256, 0);
    cdf[0] = histogram[0];
    for (var i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + histogram[i];
    }

    // 直方图均衡化
    final totalPixels = image.width * image.height;
    final lookupTable = List<int>.filled(256, 0);
    for (var i = 0; i < 256; i++) {
      lookupTable[i] = ((cdf[i] / totalPixels) * 255).round();
    }

    // 应用查找表
    return img.colorAdjust(image, 
      brightness: 0.1, 
      contrast: 0.2, 
      saturation: -0.1,
    );
  }

  // 检测问题边界框
  static Rectangle<int>? _detectQuestionBoundingBox(img.Image image) {
    // 转换为灰度图
    final grayImage = img.grayscale(image);
    
    // Sobel 边缘检测
    final edges = _sobelEdgeDetection(grayImage);
    
    // 霍夫变换检测直线
    final lines = _houghLines(edges);
    
    // 根据直线找到最可能的问题区域
    if (lines.isNotEmpty) {
      var minX = image.width;
      var minY = image.height;
      var maxX = 0;
      var maxY = 0;
      
      for (var line in lines) {
        minX = min(minX, min(line.x1, line.x2));
        minY = min(minY, min(line.y1, line.y2));
        maxX = max(maxX, max(line.x1, line.x2));
        maxY = max(maxY, max(line.y1, line.y2));
      }
      
      // 添加边距
      const padding = 20;
      minX = max(0, minX - padding);
      minY = max(0, minY - padding);
      maxX = min(image.width, maxX + padding);
      maxY = min(image.height, maxY + padding);
      
      return Rectangle<int>(minX, minY, maxX - minX, maxY - minY);
    }
    
    return null;
  }

  // Sobel边缘检测
  static img.Image _sobelEdgeDetection(img.Image grayscale) {
    final output = img.Image(grayscale.width, grayscale.height);
    const threshold = 30;

    for (var y = 1; y < grayscale.height - 1; y++) {
      for (var x = 1; x < grayscale.width - 1; x++) {
        // Sobel算子
        final gx = 
          -grayscale.getPixel(x-1, y-1).r + grayscale.getPixel(x+1, y-1).r +
          -2 * grayscale.getPixel(x-1, y).r + 2 * grayscale.getPixel(x+1, y).r +
          -grayscale.getPixel(x-1, y+1).r + grayscale.getPixel(x+1, y+1).r;
          
        final gy = 
          -grayscale.getPixel(x-1, y-1).r - 2 * grayscale.getPixel(x, y-1).r - grayscale.getPixel(x+1, y-1).r +
          grayscale.getPixel(x-1, y+1).r + 2 * grayscale.getPixel(x, y+1).r + grayscale.getPixel(x+1, y+1).r;

        final magnitude = sqrt(gx * gx + gy * gy);
        final normalized = magnitude > threshold ? 255 : 0;
        
        output.setPixelRgba(x, y, normalized, normalized, normalized, 255);
      }
    }

    return output;
  }

  // 霍夫变换检测直线
  static List<_Line> _houghLines(img.Image edges) {
    final rhoResolution = 1.0;
    final thetaResolution = pi / 180;
    final threshold = edges.width * 0.25; // 最小投票数阈值
    
    final maxRho = sqrt(edges.width * edges.width + edges.height * edges.height);
    final rhoSteps = (2 * maxRho / rhoResolution).ceil();
    final thetaSteps = (2 * pi / thetaResolution).ceil();
    
    // 初始化投票矩阵
    final accumulator = List.generate(
      rhoSteps,
      (_) => List.filled(thetaSteps, 0),
    );
    
    // 投票过程
    for (var y = 0; y < edges.height; y++) {
      for (var x = 0; x < edges.width; x++) {
        if (edges.getPixel(x, y).r > 0) {
          for (var t = 0; t < thetaSteps; t++) {
            final theta = t * thetaResolution - pi;
            final rho = x * cos(theta) + y * sin(theta);
            final r = ((rho + maxRho) / rhoResolution).round();
            if (r >= 0 && r < rhoSteps) {
              accumulator[r][t]++;
            }
          }
        }
      }
    }
    
    // 寻找局部最大值
    final lines = <_Line>[];
    for (var r = 0; r < rhoSteps; r++) {
      for (var t = 0; t < thetaSteps; t++) {
        if (accumulator[r][t] > threshold) {
          final rho = (r * rhoResolution) - maxRho;
          final theta = t * thetaResolution - pi;
          
          // 将极坐标转换为笛卡尔坐标
          final a = cos(theta);
          final b = sin(theta);
          final x0 = a * rho;
          final y0 = b * rho;
          
          final x1 = (x0 + 1000 * (-b)).round();
          final y1 = (y0 + 1000 * a).round();
          final x2 = (x0 - 1000 * (-b)).round();
          final y2 = (y0 - 1000 * a).round();
          
          lines.add(_Line(x1, y1, x2, y2));
        }
      }
    }
    
    return lines;
  }

  // 按边界框裁剪图像
  static img.Image _cropToRect(img.Image image, Rectangle<int> rect) {
    return img.copyCrop(
      image,
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }

  // 倾斜校正
  static img.Image _correctSkew(img.Image image) {
    // 转换为灰度图
    final grayImage = img.grayscale(image);
    
    // 检测文本行
    var angle = _detectSkewAngle(grayImage);
    
    // 如果角度太大，可能是误检测
    if (angle.abs() > 30) {
      return image;
    }
    
    // 旋转图像
    return img.copyRotate(image, angle: -angle);
  }

  // 检测倾斜角度
  static double _detectSkewAngle(img.Image grayImage) {
    // 使用投影剖面法检测文本行倾斜
    var bestAngle = 0.0;
    var maxVariance = 0.0;
    
    // 在一个合理的角度范围内搜索
    for (var angle = -30.0; angle <= 30.0; angle += 0.5) {
      final rotated = img.copyRotate(grayImage, angle: angle);
      final projection = _getHorizontalProjection(rotated);
      final variance = _calculateVariance(projection);
      
      if (variance > maxVariance) {
        maxVariance = variance;
        bestAngle = angle;
      }
    }
    
    return bestAngle;
  }

  // 计算水平投影
  static List<int> _getHorizontalProjection(img.Image image) {
    final projection = List<int>.filled(image.height, 0);
    
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (image.getPixel(x, y).r < 128) { // 假设深色像素代表文本
          projection[y]++;
        }
      }
    }
    
    return projection;
  }

  // 计算方差
  static double _calculateVariance(List<int> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  // 缩放图像
  static img.Image _resizeImage(img.Image image) {
    final ratio = maxImageSize / max(image.width, image.height);
    return img.copyResize(
      image,
      width: (image.width * ratio).round(),
      height: (image.height * ratio).round(),
    );
  }

  // 图像增强处理链
  static img.Image _enhanceImage(img.Image image) {
    // 降噪
    image = img.gaussianBlur(image, radius: 1);
    
    // 锐化
    image = img.sharpen(image, amount: 0.5);
    
    // 对比度增强
    image = img.adjustColor(
      image,
      contrast: 1.2,
      brightness: 1.0,
      saturation: 0.8,
      gamma: 1.1,
    );
    
    return image;
  }
}

class _IsolateData {
  final String inputPath;
  final SendPort sendPort;

  _IsolateData({required this.inputPath, required this.sendPort});
}

class _Line {
  final int x1, y1, x2, y2;

  _Line(this.x1, this.y1, this.x2, this.y2);
}

      // 返回处理后的图片路径
      data.sendPort.send(outputPath);
    } catch (e) {
      data.sendPort.send(data.inputPath); // 处理失败时返回原图
    }
  }

  static img.Image _resizeImage(img.Image image) {
    final ratio = image.width / image.height;

    int newWidth, newHeight;
    if (ratio > 1) {
      newWidth = maxImageSize;
      newHeight = (maxImageSize / ratio).round();
    } else {
      newHeight = maxImageSize;
      newWidth = (maxImageSize * ratio).round();
    }

    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
  }
}

class _IsolateData {
  final String inputPath;
  final SendPort sendPort;

  _IsolateData({required this.inputPath, required this.sendPort});
}
