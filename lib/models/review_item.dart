class ReviewItem {
  final String id;
  final String questionId;
  final DateTime createdAt;
  final DateTime nextReviewDate;
  final int reviewCount;
  final double masteryLevel; // 0-1表示掌握程度
  final List<String> tags;
  final String? note;

  ReviewItem({
    required this.id,
    required this.questionId,
    required this.createdAt,
    required this.nextReviewDate,
    this.reviewCount = 0,
    this.masteryLevel = 0.0,
    this.tags = const [],
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'createdAt': createdAt.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'reviewCount': reviewCount,
      'masteryLevel': masteryLevel,
      'tags': tags,
      'note': note,
    };
  }

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'],
      questionId: json['questionId'],
      createdAt: DateTime.parse(json['createdAt']),
      nextReviewDate: DateTime.parse(json['nextReviewDate']),
      reviewCount: json['reviewCount'] ?? 0,
      masteryLevel: json['masteryLevel'] ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
      note: json['note'],
    );
  }

  ReviewItem copyWith({
    String? id,
    String? questionId,
    DateTime? createdAt,
    DateTime? nextReviewDate,
    int? reviewCount,
    double? masteryLevel,
    List<String>? tags,
    String? note,
  }) {
    return ReviewItem(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      createdAt: createdAt ?? this.createdAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      reviewCount: reviewCount ?? this.reviewCount,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      tags: tags ?? this.tags,
      note: note ?? this.note,
    );
  }

  // 计算下次复习时间
  static DateTime calculateNextReviewDate(int reviewCount) {
    // 使用间隔复习算法
    final intervals = [1, 3, 7, 14, 30, 60, 90]; // 复习间隔天数
    final index = reviewCount.clamp(0, intervals.length - 1);
    return DateTime.now().add(Duration(days: intervals[index]));
  }
}
