class QuestionSolution {
  final List<String> steps;

  QuestionSolution({required this.steps});

  Map<String, dynamic> toJson() {
    return {'steps': steps};
  }

  factory QuestionSolution.fromJson(Map<String, dynamic> json) {
    return QuestionSolution(steps: List<String>.from(json['steps']));
  }
}
