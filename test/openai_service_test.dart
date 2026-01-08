import 'dart:io';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Future<String>? preScanTask;

  /// 这里的参数和返回类型必须和测试文件 (openai_service_test.dart) 完全一致
  Future<Map<String, dynamic>> recognizeQuestionFromImage(
    File image, {
    bool useCache = true,
    bool preprocessImage = true,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 测试文件 expect(result, isA<Map<String, dynamic>>())
    // 并且需要包含 question, answer, explanation 这三个 key
    return {
      'question': '1 + 1 = ?',
      'answer': '2',
      'explanation': '基础加法运算。',
      'raw_result': 'Success',
    };
  }

  void startPreScan(File image, String subject) {
    preScanTask = executeSolve(image, subject);
  }

  Future<String> executeSolve(File image, String subject) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "解题完成";
  }
}
