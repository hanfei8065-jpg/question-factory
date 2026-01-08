import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_service.dart';
import '../core/constants.dart';
import 'calculator_page.dart';

class AppSolvingPage extends StatefulWidget {
  final String imagePath;
  final Rect cropRect;
  final Subject subject;
  // ✅ 12月20日定稿逻辑：这里应该接收来自首页的分享键值
  final Map<String, dynamic>? shareSettings;

  const AppSolvingPage({
    super.key,
    required this.imagePath,
    required this.cropRect,
    required this.subject,
    this.shareSettings,
  });

  @override
  State<AppSolvingPage> createState() => _AppSolvingPageState();
}

class _AppSolvingPageState extends State<AppSolvingPage> {
  bool _isLoading = true;
  List<String> _steps = [];
  String _finalAnswer = "计算中...";
  String _userInput = "";

  @override
  void initState() {
    super.initState();
    _initAIResult();
  }

  Future<void> _initAIResult() async {
    // 这里调动的是 12月20日确定的 MathGPT 核心任务
    final task = AIService().preScanTask ??
        AIService().executeSolve(File(widget.imagePath), widget.subject);

    final result = await task;

    if (result.contains("[ANSWER]")) {
      final parts = result.split("[ANSWER]");
      _finalAnswer = parts[1].trim();
      _steps =
          parts[0].split("[STEP]").where((s) => s.trim().isNotEmpty).toList();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4), // 1220版：干净的浅灰底
      body: Column(
        children: [
          _buildTopPreview(), // ✅ 修复：无黑边、蒙版接近背景、线条清晰
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black26))
                : _buildSolvingFlow(),
          ),
          _buildBottomDock(), // ✅ 修复：答案键改为 Tesla 标准红色
        ],
      ),
    );
  }

  Widget _buildTopPreview() {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4), // 蒙版与背景接近
        border: Border(
            bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1)), // 清晰的线
      ),
      child: Center(
        child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildSolvingFlow() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _steps.length,
      itemBuilder: (c, i) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // 1220定稿：标准小圆角
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Text(_steps[i].trim(),
            style: const TextStyle(fontSize: 16, height: 1.5)),
      ),
    );
  }

  Widget _buildBottomDock() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => _userInput = v,
              decoration: InputDecoration(
                hintText: "输入答案进行比对",
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // ✅ 修复：答案键换回 Tesla 标准红 (#E82127)
          GestureDetector(
            onTap: () => /* 弹窗逻辑 */ {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFE82127),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text("答案",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
