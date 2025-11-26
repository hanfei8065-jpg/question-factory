import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learnest_fresh/services/openai_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => Directory.current.path;

  @override
  Future<String?> getApplicationSupportPath() async => Directory.current.path;

  @override
  Future<String?> getLibraryPath() async => Directory.current.path;

  @override
  Future<String?> getApplicationCachePath() async => Directory.current.path;

  @override
  Future<String?> getDownloadsPath() async => Directory.current.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => Directory.current.path;

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => [Directory.current.path];

  @override
  Future<String?> getExternalStoragePath() async => Directory.current.path;
}

void main() {
  setUpAll(() async {
    // 设置Mock
    PathProviderPlatform.instance = FakePathProviderPlatform();
    // 加载环境变量
    await dotenv.load(fileName: '.env');
  });

  test('OpenAI Vision API Test', () async {
    final service = OpenAIService();

    // 创建测试图片路径（我们需要先创建一个测试图片）
    final testImage = File('test/test_assets/math_question.jpg');

    expect(await testImage.exists(), true, reason: '测试图片不存在');

    // 调用API
    final result = await service.recognizeQuestionFromImage(
      testImage,
      useCache: false, // 测试时禁用缓存
      preprocessImage: true,
    );

    // 验证结果
    expect(result, isA<Map<String, dynamic>>());
    expect(result['question'], isA<String>());
    expect(result['answer'], isA<String>());
    expect(result['explanation'], isA<String>());
  });
}
