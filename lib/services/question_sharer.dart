import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/question.dart';

class QuestionSharer {
  // 分享题目和答案
  static Future<void> shareQuestion(
    BuildContext context,
    Question question, {
    bool includeAnswer = false,
    File? questionImage,
  }) async {
    try {
      String shareText = _generateShareText(question, includeAnswer);

      if (questionImage != null) {
        // 获取临时目录用于存储图片
        final tempDir = await getTemporaryDirectory();
        final imagePath = '${tempDir.path}/shared_question.jpg';

        // 复制图片到临时目录
        await questionImage.copy(imagePath);

        // 分享文本和图片
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: shareText,
          subject: '分享一道题目',
        );
      } else {
        // 仅分享文本
        await Share.share(shareText, subject: '分享一道题目');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分享失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 生成分享文本
  static String _generateShareText(Question question, bool includeAnswer) {
    final buffer = StringBuffer();

    // 添加题目内容
    buffer.writeln('【题目】');
    buffer.writeln(question.content);
    buffer.writeln();

    // 如果包含答案，则添加答案部分
    if (includeAnswer && question.answer != null) {
      buffer.writeln('【答案】');
      buffer.writeln(question.answer);
      buffer.writeln();
    }

    // 添加分享来源
    buffer.writeln('来自 Learnest 智能学习助手');

    return buffer.toString();
  }
}
