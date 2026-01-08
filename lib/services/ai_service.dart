import 'dart:io';
import '../core/constants.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Future<String>? preScanTask;

  /// 模拟图片识别过程
  Future<String> recognizeQuestionFromImage(File image, Subject subject) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "系统检测：正在对 ${subject.name} 题目进行视觉扫描...";
  }

  /// 启动预扫描
  void startPreScan(File image, Subject subject) {
    preScanTask = executeSolve(image, subject);
  }

  /// ✅ 核心：临时测试用解题逻辑
  Future<String> executeSolve(File image, Subject subject) async {
    // 模拟网络延迟 1.5 秒，让你能看到 Loading 转圈
    await Future.delayed(const Duration(milliseconds: 1500));

    // 返回一段硬编码的、符合你 UI 解析逻辑的测试内容
    return """
[STEP] 【测试模式】已接收到图片，学科识别为：${subject.name.toUpperCase()}。
[STEP] 正在调阅本地知识库，模拟 DeepSeek R1 的推理过程...
[STEP] 识别到题目包含数学公式或逻辑点，正在生成最优解法。
[STEP] 验证完成：项目路径从【相机页】到【裁剪页】再到【解题页】已全线打通。
[ANSWER] 测试通过 (Done)
""";
  }
}
