import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class TestModeService {
  static final TestModeService _instance = TestModeService._internal();
  factory TestModeService() => _instance;
  TestModeService._internal();

  bool _isTestMode = false;
  bool get isTestMode => _isTestMode;

  void enableTestMode() {
    _isTestMode = true;
  }

  void disableTestMode() {
    _isTestMode = false;
  }

  Future<List<File>> getTestImages() async {
    final List<File> testImages = [];

    try {
      // 获取测试图片资源列表
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final testImagePaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/test_images/'))
          .toList();

      // 将资源文件复制到临时目录
      final tempDir = await getTemporaryDirectory();

      for (String path in testImagePaths) {
        final String filename = path.split('/').last;
        final File tempFile = File('${tempDir.path}/$filename');

        if (!await tempFile.exists()) {
          final ByteData data = await rootBundle.load(path);
          final buffer = data.buffer.asUint8List();
          await tempFile.writeAsBytes(buffer);
        }

        testImages.add(tempFile);
      }
    } catch (e) {
      print('Error loading test images: $e');
    }

    return testImages;
  }
}
