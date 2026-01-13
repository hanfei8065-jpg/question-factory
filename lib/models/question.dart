import 'dart:convert';
import 'question_solution.dart';

enum Subject { math, physics, chemistry, biology, unspecified }

enum QuestionType { choice, fill, application }

class Question {
  final String id;
  final String content;
  final List<String> options;
  final String answer;
  final String explanation;
  final Subject subject;
  final int grade;
  final QuestionType type;
  final int difficulty;
  final List<String> tags;
  final QuestionSolution? solution;
  final String? imagePath;
  final bool isImageQuestion;
  // --- 新增正规军字段 ---
  final String? lang;
  final String? subjectId; // 存储原始字符串，如 'math'
  final String? gradeId; // 存储原始字符串，如 'grade10'

  Question({
    required this.id,
    required this.content,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.subject,
    required this.grade,
    required this.type,
    required this.difficulty,
    required this.tags,
    this.solution,
    this.imagePath,
    this.isImageQuestion = false,
    this.lang,
    this.subjectId,
    this.gradeId,
  });

  /// 🛠 核心：fromMap (适配 AppSupabaseService)
  factory Question.fromMap(Map<String, dynamic> map) {
    // 1. 将字符串 'math' 转为 Subject enum
    Subject parseSubject(String? s) {
      if (s == null) return Subject.unspecified;
      return Subject.values.firstWhere(
        (e) => e.toString().split('.').last == s.toLowerCase(),
        orElse: () => Subject.unspecified,
      );
    }

    // 2. 将 'grade10' 字符串提取数字转为 int
    int parseGrade(dynamic g) {
      if (g is int) return g;
      if (g is String) {
        final matches = RegExp(r'\d+').firstMatch(g);
        return matches != null ? int.parse(matches.group(0)!) : 0;
      }
      return 0;
    }

    return Question(
      id: map['id']?.toString() ?? '',
      content: map['content'] ?? map['problem_text'] ?? '', // ✅ 支持 problem_text
      options: map['options'] != null ? List<String>.from(map['options']) : [],
      answer:
          map['answer'] ?? map['correct_answer'] ?? '', // ✅ 支持 correct_answer
      explanation: map['explanation'] ?? '',
      subject: parseSubject(map['subject_id'] ?? map['subject']), // ✅ 支持两种字段
      grade: parseGrade(map['grade_id'] ??
          map['grade'] ??
          map['grade_level']), // ✅ 支持 grade_level
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['type'] ?? 'choice'),
        orElse: () => QuestionType.choice,
      ),
      difficulty: map['difficulty'] ?? 1,
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      imagePath: map['imagePath'] as String?,
      isImageQuestion: map['isImageQuestion'] as bool? ?? false,
      lang: map['lang'],
      subjectId: map['subject_id'] ?? map['subject'], // ✅ 兼容
      gradeId: map['grade_id'] ?? map['grade_level'], // ✅ 兼容
      solution: map['solution'] != null
          ? QuestionSolution.fromJson(map['solution'] as Map<String, dynamic>)
          : null,
    );
  }

  // 为了保持兼容，让 fromJson 直接调用 fromMap
  factory Question.fromJson(Map<String, dynamic> json) =>
      Question.fromMap(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'options': options,
      'answer': answer,
      'explanation': explanation,
      'subject': subject.toString().split('.').last,
      'grade': grade,
      'type': type.toString().split('.').last,
      'difficulty': difficulty,
      'tags': tags,
      'imagePath': imagePath,
      'isImageQuestion': isImageQuestion,
      'lang': lang,
      'subject_id': subjectId,
      'grade_id': gradeId,
      if (solution != null) 'solution': solution!.toJson(),
    };
  }

  // 保持 copyWith 逻辑完整
  Question copyWith({
    String? id,
    String? content,
    List<String>? options,
    String? answer,
    String? explanation,
    Subject? subject,
    int? grade,
    QuestionType? type,
    int? difficulty,
    List<String>? tags,
    QuestionSolution? solution,
    String? imagePath,
    bool? isImageQuestion,
    String? lang,
    String? subjectId,
    String? gradeId,
  }) {
    return Question(
      id: id ?? this.id,
      content: content ?? this.content,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      solution: solution ?? this.solution,
      imagePath: imagePath ?? this.imagePath,
      isImageQuestion: isImageQuestion ?? this.isImageQuestion,
      lang: lang ?? this.lang,
      subjectId: subjectId ?? this.subjectId,
      gradeId: gradeId ?? this.gradeId,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
