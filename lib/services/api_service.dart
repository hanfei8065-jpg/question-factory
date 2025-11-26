import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learnest_fresh/core/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _baseUrl = 'https://api.learnest.ai'; // 示例URL

  Future<Map<String, dynamic>> recognizeQuestion(
    String imageBase64,
    Subject subject,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/recognize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': imageBase64, 'subject': subject.toString()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Recognition failed: ${response.statusCode}';
      }
    } catch (e) {
      print('Error recognizing question: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAnswer(
    String questionId,
    String answer,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/check-answer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'questionId': questionId, 'answer': answer}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Answer check failed: ${response.statusCode}';
      }
    } catch (e) {
      print('Error checking answer: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getExplanation(String questionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/explanation/$questionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to get explanation: ${response.statusCode}';
      }
    } catch (e) {
      print('Error getting explanation: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSimilarQuestions(
    String questionId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/similar-questions/$questionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw 'Failed to get similar questions: ${response.statusCode}';
      }
    } catch (e) {
      print('Error getting similar questions: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAIResponse(
    String message,
    Subject subject,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ai-teacher'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message, 'subject': subject.toString()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'AI response failed: ${response.statusCode}';
      }
    } catch (e) {
      print('Error getting AI response: $e');
      rethrow;
    }
  }
}
