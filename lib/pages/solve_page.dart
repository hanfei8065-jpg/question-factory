import 'package:flutter/material.dart';

class SolvePage extends StatelessWidget {
  final ImageProvider? questionImage;
  const SolvePage({super.key, this.questionImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 顶部题目截图区
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: questionImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image(image: questionImage!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 48),
                      ),
              ),
            ),
            // 主内容区（解题过程展示、工具区预留）
            Positioned(
              top: 140,
              left: 0,
              right: 0,
              bottom: 80,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                children: [
                  // 解题过程展示（富文本/动画预留）
                  Text(
                    '解题过程展示区（AI生成内容、富文本、动画预留）',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 24),
                  // 工具区预留（计算器、手写板等）
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text('工具区预留（计算器/手写板）')),
                  ),
                ],
              ),
            ),
            // 底部答案输入区
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(Icons.mic, color: Colors.grey, size: 28),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '请输入你的答案...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.black, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            // 计算器/演算层弹窗预留
            // 可用Stack+Opacity+Positioned后续实现
          ],
        ),
      ),
    );
  }
}
