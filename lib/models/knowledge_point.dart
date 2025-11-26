class KnowledgePoint {
  final String id;
  final String name;
  final String description;
  final String subject;
  final String chapter;
  final List<String> relatedPoints;
  final int difficulty; // 1-5表示难度级别
  final List<String> examples;

  KnowledgePoint({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.chapter,
    this.relatedPoints = const [],
    this.difficulty = 1,
    this.examples = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subject': subject,
      'chapter': chapter,
      'relatedPoints': relatedPoints,
      'difficulty': difficulty,
      'examples': examples,
    };
  }

  factory KnowledgePoint.fromJson(Map<String, dynamic> json) {
    return KnowledgePoint(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      subject: json['subject'],
      chapter: json['chapter'],
      relatedPoints: List<String>.from(json['relatedPoints'] ?? []),
      difficulty: json['difficulty'] ?? 1,
      examples: List<String>.from(json['examples'] ?? []),
    );
  }
}
