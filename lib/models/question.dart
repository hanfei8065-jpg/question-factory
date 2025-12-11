import 'dart:convert';
import 'question_solution.dart';

enum Subject { math, physics, chemistry }

enum QuestionType { choice, fill, application }

class Question {
  final String id;
  final String content; // 支持 LaTeX
  final List<String> options;
  final String answer;
  final String explanation;
  final Subject subject;
  final int grade;
  final QuestionType type;
  final int difficulty; // 1-5
  final List<String> tags;
  final QuestionSolution? solution;
  final String? imagePath; // 图片路径
  final bool isImageQuestion; // 是否为图片题

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
  });

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
      if (solution != null) 'solution': solution!.toJson(),
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      content: json['content'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
      explanation: json['explanation'],
      subject: Subject.values.firstWhere(
        (e) => e.toString().split('.').last == json['subject'],
      ),
      grade: json['grade'],
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      difficulty: json['difficulty'],
      tags: List<String>.from(json['tags']),
      imagePath: json['imagePath'] as String?,
      isImageQuestion: json['isImageQuestion'] as bool? ?? false,
      solution: json['solution'] != null
          ? QuestionSolution.fromJson(json['solution'] as Map<String, dynamic>)
          : null,
    );
  }

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
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
