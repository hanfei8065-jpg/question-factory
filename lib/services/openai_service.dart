import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../services/image_processing_service.dart';
import '../services/question_cache_service.dart';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String _baseUrl =
      dotenv.env['OPENAI_API_BASE_URL'] ?? 'https://api.openai.com';

  final _imageProcessor = ImageProcessingService();
  final _cache = QuestionCacheService();

  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<dynamic> processImage(String imagePath) async {
    final file = File(imagePath);
    return await recognizeQuestionFromImage(file);
  }

  Future<Map<String, dynamic>> recognizeQuestionFromImage(
    File imageFile, {
    bool useCache = true,
    bool preprocessImage = true,
  }) async {
    try {
      // 检查缓存
      if (useCache) {
        final cachedResult = await _cache.getCachedResult(imageFile);
        if (cachedResult != null) {
          return cachedResult;
        }
      }

      // 预处理图片
      final processedImage = preprocessImage
          ? await _imageProcessor.preprocessImage(imageFile)
          : imageFile;

      // 带重试的API调用
      final result = await _callAPIWithRetry(processedImage);

      // 缓存结果
      if (useCache) {
        await _cache.cacheResult(imageFile, {
          ...result,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      return result;
    } catch (e) {
      throw _formatError(e);
    }
  }

  Future<List<Map<String, dynamic>>> recognizeQuestionsFromImages(
    List<File> imageFiles, {
    bool useCache = true,
    bool preprocessImages = true,
  }) async {
    // 预处理所有图片
    final processedImages = preprocessImages
        ? await _imageProcessor.preprocessImages(imageFiles)
        : imageFiles;

    // 并发识别所有图片（限制并发数为3）
    final results = <Map<String, dynamic>>[];
    final errors = <String>[];

    for (var i = 0; i < processedImages.length; i += 3) {
      final batch = processedImages.skip(i).take(3);
      final futures = batch.map(
        (image) =>
            recognizeQuestionFromImage(
              image,
              useCache: useCache,
              preprocessImage: false, // 已经预处理过了
            ).catchError((e) {
              errors.add('处理第${i + 1}张图片失败: ${_formatError(e)}');
              return <String, dynamic>{};
            }),
      );

      results.addAll(await Future.wait(futures));
    }

    if (errors.isNotEmpty) {
      throw Exception(errors.join('\n'));
    }

    return results.where((r) => r.isNotEmpty).toList();
  }

  Future<Map<String, dynamic>> _callAPIWithRetry(File imageFile) async {
    Exception? lastError;

    for (var i = 0; i < _maxRetries; i++) {
      try {
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        final url = '$_baseUrl/v1/chat/completions';
        print('发送请求到 OpenAI API: $url');
        print(
          '使用的API密钥: ${_apiKey.substring(0, 10)}...${_apiKey.substring(_apiKey.length - 5)}',
        );
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4o',
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text':
                        '这是一道K12学科题目，请识别题目内容、给出标准答案和详细解题步骤。'
                        '以JSON格式返回：{question, answer, explanation, subject, difficulty}',
                  },
                  {
                    'type': 'image_url',
                    'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                  },
                ],
              },
            ],
            'max_tokens': 1000,
          }),
        );

        print('API 响应状态码: ${response.statusCode}');
        print('API 响应内容: ${response.body}');

        if (response.statusCode != 200) {
          final errorBody = jsonDecode(response.body);
          throw Exception('API错误: ${errorBody['error']?['message'] ?? '未知错误'}');
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('API 响应内容: ${response.body}');

          if (!data.containsKey('choices') || data['choices'].isEmpty) {
            throw Exception('API响应格式错误：没有找到choices字段');
          }

          final content = data['choices'][0]['message']['content'];
          print('解析到的内容: $content');

          final startIndex = content.indexOf('{');
          final endIndex = content.lastIndexOf('}') + 1;
          final jsonStr = content.substring(startIndex, endIndex);
          final Map<String, dynamic> result = jsonDecode(jsonStr);

          // 确保answer是字符串类型
          if (result['answer'] != null) {
            result['answer'] = result['answer'].toString();
          }

          return result;
        } else if (response.statusCode == 429) {
          // Rate limit
          lastError = Exception('API调用频率超限');
          await Future.delayed(_retryDelay * (i + 1)); // 指数退避
          continue;
        } else {
          throw Exception('API返回错误: ${response.statusCode}\n${response.body}');
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (i < _maxRetries - 1) {
          await Future.delayed(_retryDelay);
          continue;
        }
      }
    }

    throw lastError ?? Exception('未知错误');
  }

  Exception _formatError(dynamic error) {
    if (error is SocketException) {
      return Exception('网络连接失败，请检查网络设置');
    } else if (error.toString().contains('API调用频率超限')) {
      return Exception('服务器繁忙，请稍后再试');
    } else if (error.toString().contains('API返回错误')) {
      return Exception('服务暂时不可用，请稍后重试');
    } else {
      return Exception('识别失败: ${error.toString()}');
    }
  }

  /// 获取题目的解题过程和答案（新方法，用于做题页）
  Future<Map<String, String>> getSolutionProcess(File imageFile) async {
    try {
      final base64Image = await _imageProcessor.convertToBase64(imageFile);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': '''请分析这道题目，提供详细的解题过程和最终答案。
                  
要求：
1. 解题过程要清晰、详细、循序渐进
2. 包含必要的公式和计算步骤
3. 用学生易懂的语言表达
4. 最后单独给出最终答案

请按以下JSON格式返回：
{
  "process": "详细的解题过程",
  "answer": "最终答案"
}'''
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  }
                }
              ]
            }
          ],
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        
        // 解析JSON响应
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final resultJson = jsonDecode(jsonMatch.group(0)!);
          return {
            'process': resultJson['process'] as String,
            'answer': resultJson['answer'] as String,
          };
        }
        
        // 如果无法解析JSON，返回原始内容
        return {
          'process': content,
          'answer': '请查看解题过程',
        };
      } else {
        throw Exception('API返回错误: ${response.statusCode}');
      }
    } catch (e) {
      throw _formatError(e);
    }
  }
}
