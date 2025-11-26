import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ImageProcessor {
  static Future<File> preprocessImage(File imageFile) async {
    // 在后台线程处理图片
    final processedImageBytes = await compute(
      _processImageIsolate,
      await imageFile.readAsBytes(),
    );

    // 保存处理后的图片
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(processedImageBytes);

    return tempFile;
  }

  static Future<List<int>> _processImageIsolate(List<int> imageBytes) async {
    // 解码图片
    final image = img.decodeImage(Uint8List.fromList(imageBytes));
    if (image == null) throw Exception('Failed to decode image');

    // 调整大小（如果图片太大）
    img.Image processedImage = image;
    if (image.width > 1920 || image.height > 1920) {
      processedImage = img.copyResize(
        image,
        width: image.width > image.height ? 1920 : null,
        height: image.height >= image.width ? 1920 : null,
      );
    }

    // 增强对比度
    processedImage = img.adjustColor(
      processedImage,
      contrast: 1.1,
      brightness: 1.05,
    );

    // 锐化
    processedImage = img.sobel(processedImage);

    // 确保图片是灰度的
    if (!_isBlackAndWhite(processedImage)) {
      processedImage = img.grayscale(processedImage);
    }

    // 二值化处理（适用于文字识别）
    processedImage = _adaptiveThreshold(processedImage);

    // 编码为JPEG，控制质量以减小文件大小
    return img.encodeJpg(processedImage, quality: 85);
  }

  static bool _isBlackAndWhite(img.Image image) {
    // 采样检查是否是黑白图片
    const sampleSize = 100;
    final pixels = <img.Pixel>[];

    for (int i = 0; i < sampleSize; i++) {
      final x = (image.width * (i / sampleSize)).floor();
      final y = (image.height * (i / sampleSize)).floor();
      pixels.add(image.getPixel(x, y));
    }

    // 检查RGB通道是否相等（灰度图像的特征）
    return pixels.every((p) => p.r == p.g && p.g == p.b);
  }

  static img.Image _adaptiveThreshold(img.Image image) {
    final output = img.Image(width: image.width, height: image.height);
    const windowSize = 15;
    const t = 15; // 阈值偏移

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        // 计算局部区域的平均值
        var sum = 0;
        var count = 0;

        for (var wy = -windowSize ~/ 2; wy <= windowSize ~/ 2; wy++) {
          for (var wx = -windowSize ~/ 2; wx <= windowSize ~/ 2; wx++) {
            final ny = y + wy;
            final nx = x + wx;

            if (ny >= 0 && ny < image.height && nx >= 0 && nx < image.width) {
              sum += img.getLuminance(image.getPixel(nx, ny)).toInt();
              count++;
            }
          }
        }

        final threshold = (sum / count - t).floor();
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);

        output.setPixel(
          x,
          y,
          luminance > threshold
              ? img.ColorRgb8(255, 255, 255)
              : img.ColorRgb8(0, 0, 0),
        );
      }
    }

    return output;
  }

  // 获取图片的质量评分
  static double getImageQuality(img.Image image) {
    // 计算Laplace算子以评估清晰度
    var score = 0.0;
    for (var y = 1; y < image.height - 1; y++) {
      for (var x = 1; x < image.width - 1; x++) {
        final center = img.getLuminance(image.getPixel(x, y));
        final left = img.getLuminance(image.getPixel(x - 1, y));
        final right = img.getLuminance(image.getPixel(x + 1, y));
        final top = img.getLuminance(image.getPixel(x, y - 1));
        final bottom = img.getLuminance(image.getPixel(x, y + 1));

        final laplace = center * 4 - left - right - top - bottom;
        score += laplace * laplace;
      }
    }

    return score / (image.width * image.height);
  }
}
