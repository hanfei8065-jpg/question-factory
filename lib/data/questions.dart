// 获取题库所有标签（去重）
List<String> getAllTags() {
  return allQuestions
      .map((q) => q.tags)
      .expand((tags) => tags)
      .toSet()
      .toList();
}
// 只检查 tags 为空，输出缺失题目ID并自动补全
void scanAndFixQuestionTags({bool autoFix = true}) {
  final List<String> missingTagsIds = [];
  for (final q in allQuestions) {
    if (q.tags.isEmpty) {
      missingTagsIds.add(q.id);
      if (autoFix) {
        q.tags.add('未分类');
      }
    }
  }
  if (missingTagsIds.isEmpty) {
    print('所有题目 tags 标签完整，无需修复。');
  } else {
    print('缺失 tags 的题目ID:');
    for (final id in missingTagsIds) {
      print(id);
    }
    if (autoFix) print('已自动补全 tags 标签为“未分类”。');
  }
}
import '../models/question.dart';
import 'question_generator.dart';

// 生成所有科目的题目
final List<Question> allQuestions = [
  ...QuestionGenerator.generateMathQuestions(), // 数学题
  ...QuestionGenerator.generatePhysicsQuestions(), // 物理题
  ...QuestionGenerator.generateChemistryQuestions(), // 化学题
];

// 按科目分类的题目
final Map<Subject, List<Question>> questionsBySubject = {
  Subject.math: allQuestions.where((q) => q.subject == Subject.math).toList(),
  Subject.physics: allQuestions
      .where((q) => q.subject == Subject.physics)
      .toList(),
  Subject.chemistry: allQuestions
      .where((q) => q.subject == Subject.chemistry)
      .toList(),
};

// 按题型分类的题目
final Map<QuestionType, List<Question>> questionsByType = {
  QuestionType.choice: allQuestions
      .where((q) => q.type == QuestionType.choice)
      .toList(),
  QuestionType.fill: allQuestions
      .where((q) => q.type == QuestionType.fill)
      .toList(),
  QuestionType.application: allQuestions
      .where((q) => q.type == QuestionType.application)
      .toList(),
};

// 按难度分类的题目 (1-5)
final Map<int, List<Question>> questionsByDifficulty = {
  1: allQuestions.where((q) => q.difficulty == 1).toList(),
  2: allQuestions.where((q) => q.difficulty == 2).toList(),
  3: allQuestions.where((q) => q.difficulty == 3).toList(),
  4: allQuestions.where((q) => q.difficulty == 4).toList(),
  5: allQuestions.where((q) => q.difficulty == 5).toList(),
};

// 获取指定数量、指定科目和难度的随机题目
List<Question> getRandomQuestions({
  required Subject subject,
  required int difficulty,
  required int count,
  QuestionType? type,
}) {
  final subjectQuestions = questionsBySubject[subject] ?? [];
  var filteredQuestions = subjectQuestions
      .where((q) => q.difficulty == difficulty)
      .toList();

  if (type != null) {
    filteredQuestions = filteredQuestions.where((q) => q.type == type).toList();
  }

  filteredQuestions.shuffle();
  return filteredQuestions.take(count).toList();
}

// 根据ID获取题目
Question? getQuestionById(String id) {
  try {
    return allQuestions.firstWhere((q) => q.id == id);
  } catch (e) {
    return null;
  }
}

// 获取某个科目的所有标签
List<String> getTagsBySubject(Subject subject) {
  return questionsBySubject[subject]
          ?.map((q) => q.tags)
          .expand((tags) => tags)
          .toSet()
          .toList() ??
      [];
}

// 根据标签获取题目
List<Question> getQuestionsByTag(String tag) {
  return allQuestions.where((q) => q.tags.contains(tag)).toList();
}

// 获取指定年级的题目
List<Question> getQuestionsByGrade(int grade) {
  return allQuestions.where((q) => q.grade == grade).toList();
}

// 获取特定科目和难度的题目数量
int getQuestionCount(Subject subject, int difficulty) {
  return questionsBySubject[subject]
          ?.where((q) => q.difficulty == difficulty)
          .length ??
      0;
}
