import 'package:flutter/material.dart';
import '../constants/syllabus.dart';
import 'app_question_arena_page.dart';

class AppQuestionBankPage extends StatefulWidget {
  const AppQuestionBankPage({super.key});

  @override
  State<AppQuestionBankPage> createState() => _AppQuestionBankPageState();
}

class _AppQuestionBankPageState extends State<AppQuestionBankPage> {
  int? selectedSubjectIdx;
  String? selectedGrade;
  String? selectedTopic;

  @override
  Widget build(BuildContext context) {
    final subjects = LEARNIST_SYLLABUS;
    final subject = selectedSubjectIdx != null
        ? subjects[selectedSubjectIdx!]
        : null;
    final grades = subject != null ? subject.grades : [];
    final topics = (subject != null && selectedGrade != null)
        ? (subject.topics[selectedGrade] ?? [])
        : [];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "知识竞技场",
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "直击弱点",
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Daily Revenge Card
              GestureDetector(
                onTap: () {
                  // Navigate to Revenge Mode (Review Mistakes)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppQuestionArenaPage(
                        subjectId: 'review',
                        topic: 'mistakes',
                        questionLimit: 10,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF07C160),
                    borderRadius: BorderRadius.circular(20), // rounded-xl
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF07C160).withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sports_martial_arts,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "复仇模式",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Section A: Select Subject
              if (selectedSubjectIdx == null)
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: subjects.length,
                    itemBuilder: (context, idx) {
                      final s = subjects[idx];
                      final isActive = selectedSubjectIdx == idx;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSubjectIdx = idx),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: isActive
                                ? Border.all(
                                    color: const Color(0xFF07C160),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school,
                                color: const Color(0xFF07C160),
                                size: 36,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                s.name,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Section B: Select Grade
              if (selectedSubjectIdx != null && selectedGrade == null)
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: grades.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final g = grades[idx];
                      final isSelected = selectedGrade == g;
                      return GestureDetector(
                        onTap: () => setState(() => selectedGrade = g),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF07C160)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(
                              999,
                            ), // rounded-full
                            border: Border.all(
                              color: const Color(0xFF07C160),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            g,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF07C160),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Section C: Select Topic
              if (selectedSubjectIdx != null && selectedGrade != null)
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: topics.length,
                    itemBuilder: (context, idx) {
                      final t = topics[idx];
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedTopic = t);
                          // Navigate to QuestionArenaPage with full params
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppQuestionArenaPage(
                                subjectId: subject!.id,
                                grade: selectedGrade,
                                topic: t,
                                questionLimit: 5,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
