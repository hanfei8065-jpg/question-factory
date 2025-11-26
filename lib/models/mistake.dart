import 'dart:convert';

class Mistake {
  final String id;
  final String question;
  final String answer;
  final String explanation;
  final String subject;
  final String difficulty;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  bool mastered;

  Mistake({
    required this.id,
    required this.question,
    required this.answer,
    required this.explanation,
    required this.subject,
    required this.difficulty,
    DateTime? createdAt,
    this.reviewedAt,
    this.mastered = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Mistake.fromJson(Map<String, dynamic> json) {
    return Mistake(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      explanation: json['explanation'] as String,
      subject: json['subject'] as String,
      difficulty: json['difficulty'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      mastered: json['mastered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'explanation': explanation,
    'subject': subject,
    'difficulty': difficulty,
    'createdAt': createdAt.toIso8601String(),
    'reviewedAt': reviewedAt?.toIso8601String(),
    'mastered': mastered,
  };

  Mistake copyWith({
    String? id,
    String? question,
    String? answer,
    String? explanation,
    String? subject,
    String? difficulty,
    DateTime? createdAt,
    DateTime? reviewedAt,
    bool? mastered,
  }) {
    return Mistake(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      mastered: mastered ?? this.mastered,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mistake && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
