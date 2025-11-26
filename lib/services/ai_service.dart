import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  static const String _baseUrl = 'YOUR_AI_API_ENDPOINT';

  Future<List<String>> explainQuestion(Question question) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/explain'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': question.content,
          'subject': question.subject.toString().split('.').last,
          'difficulty': question.difficulty,
          'tags': question.tags,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return List<String>.from(data['steps'] as List);
      } else {
        throw Exception('AI服务响应错误: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('调用AI服务失败: $e');
    }
  }

  Future<String> chat(String message, String subject) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message, 'subject': subject}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['reply'] as String;
      } else {
        throw Exception('AI服务响应错误: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('调用AI服务失败: $e');
    }
  }
}
