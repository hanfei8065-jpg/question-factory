import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question.dart';

/// QuestionService - 从 Supabase 获取真实题目数据
///
/// 单例模式，提供：
/// - fetchQuestions: 按学科/年级/难度查询题目
/// - 自动映射 timer_seconds 字段
/// - 完整错误处理
class QuestionService {
  // 单例模式
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// 从 Supabase 获取题目列表
  ///
  /// Parameters:
  /// - [subject]: 学科 (math, physics, chemistry, olympiad)
  /// - [grade]: 年级 (可选，例如 10)
  /// - [limit]: 返回题目数量 (默认 20)
  /// - [difficulty]: 难度 (可选，1-4)
  /// - [tags]: 标签过滤 (可选)
  ///
  /// Returns: Question 对象列表
  /// Throws: Exception 如果查询失败
  Future<List<Question>> fetchQuestions({
    required String subject,
    int? grade,
    int limit = 20,
    int? difficulty,
    List<String>? tags,
  }) async {
    try {
      print('🔍 QuestionService: Fetching questions from Supabase...');
      print('   Subject: $subject, Grade: $grade, Limit: $limit');

      // 1. 构建基础查询
      var query = _supabase
          .from('questions')
          .select('*')
          .eq('subject', subject);

      // 2. 添加可选过滤条件
      if (grade != null) {
        query = query.eq('grade', grade);
      }

      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }

      // 3. 限制返回数量并执行查询
      final response = await query.limit(limit);

      print(
        '✅ QuestionService: Received ${response.length} rows from Supabase',
      );

      // 4. 将 JSON 转换为 Question 对象
      final questions = (response as List)
          .map((json) {
            try {
              // ✅ CRITICAL: Question.fromJson 会自动解析 timer_seconds
              return Question.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              print('⚠️ QuestionService: Failed to parse question: $e');
              print('   Raw JSON: $json');
              return null;
            }
          })
          .whereType<Question>() // 过滤掉解析失败的题目
          .toList();

      // 5. Tags 过滤 (客户端过滤)
      if (tags != null && tags.isNotEmpty) {
        final filteredQuestions = questions.where((q) {
          return tags.any((tag) => q.tags.contains(tag));
        }).toList();

        print(
          '🏷️ QuestionService: Filtered by tags $tags: ${filteredQuestions.length} questions',
        );
        return filteredQuestions.take(limit).toList();
      }

      print(
        '✅ QuestionService: Successfully parsed ${questions.length} Question objects',
      );
      return questions;
    } catch (e, stackTrace) {
      print('❌ QuestionService ERROR: $e');
      print('   Stack trace: $stackTrace');
      rethrow; // 抛出异常让调用方处理
    }
  }

  /// 健康检查：测试 Supabase 连接
  Future<bool> healthCheck() async {
    try {
      final response = await _supabase.from('questions').select('id').limit(1);

      print('✅ Supabase Health Check: OK (${response.length} rows)');
      return true;
    } catch (e) {
      print('❌ Supabase Health Check: FAILED - $e');
      return false;
    }
  }

  /// 获取题目总数（用于统计）
  Future<int> getQuestionCount({String? subject, int? grade}) async {
    try {
      var query = _supabase.from('questions').select('*');

      if (subject != null) {
        query = query.eq('subject', subject);
      }

      if (grade != null) {
        query = query.eq('grade', grade);
      }

      final response = await query;
      return response.length;
    } catch (e) {
      print('❌ getQuestionCount ERROR: $e');
      return 0;
    }
  }
}
