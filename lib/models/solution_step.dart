class SolutionStep {
  final int order;
  final String description;
  final String formula;
  final List<String> knowledgePoints;
  final String? hint;
  final String? imageUrl;

  SolutionStep({
    required this.order,
    required this.description,
    required this.formula,
    this.knowledgePoints = const [],
    this.hint,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'description': description,
      'formula': formula,
      'knowledgePoints': knowledgePoints,
      'hint': hint,
      'imageUrl': imageUrl,
    };
  }

  factory SolutionStep.fromJson(Map<String, dynamic> json) {
    return SolutionStep(
      order: json['order'],
      description: json['description'],
      formula: json['formula'],
      knowledgePoints: List<String>.from(json['knowledgePoints'] ?? []),
      hint: json['hint'],
      imageUrl: json['imageUrl'],
    );
  }
}
