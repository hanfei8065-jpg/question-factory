import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageProcessingService {
  static final ImageProcessingService _instance =
      ImageProcessingService._internal();
  factory ImageProcessingService() => _instance;
  ImageProcessingService._internal();

  /// 图片预处理：裁剪、增强对比度和清晰度
  Future<File> preprocessImage(File imageFile) async {
    // 读取图片
    final bytes = await imageFile.readAsBytes();
    var image = img.decodeImage(bytes);

    if (image == null) throw Exception('无法解析图片');

    // 自动裁剪（去除边缘空白）
    image = img.trim(image);

    // 增强对比度
    image = img.adjustColor(
      image,
      contrast: 1.2, // 提高对比度
      brightness: 1.1, // 稍微提高亮度
      saturation: 0.9, // 降低饱和度以突出文字
    );

    // 图像锐化
    image = img.gaussianBlur(image, radius: 1);

    // 调整大小（确保不超过API限制，同时保持足够的清晰度）
    final maxDimension = 2048; // GPT-4 Vision API的建议最大尺寸
    if (image.width > maxDimension || image.height > maxDimension) {
      image = img.copyResize(
        image,
        width: image.width > image.height ? maxDimension : null,
        height: image.height > image.width ? maxDimension : null,
        interpolation: img.Interpolation.cubic,
      );
    }

    // 保存处理后的图片
    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final processedFile = File(tempPath);
    await processedFile.writeAsBytes(img.encodeJpg(image, quality: 95));

    return processedFile;
  }

  /// 批量预处理图片
  Future<List<File>> preprocessImages(List<File> imageFiles) async {
    final processedFiles = <File>[];
    for (final file in imageFiles) {
      try {
        final processed = await preprocessImage(file);
        processedFiles.add(processed);
      } catch (e) {
        print('处理图片失败: ${file.path}, 错误: $e');
        // 如果处理失败，使用原图
        processedFiles.add(file);
      }
    }
    return processedFiles;
  }

  /// 将图片转换为Base64编码
  Future<String> convertToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }
}
