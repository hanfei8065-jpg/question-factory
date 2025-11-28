import 'package:flutter/material.dart';
import 'package:learnest_fresh/widgets/aitutor_sheet.dart';

void _showAITutorSheet(BuildContext context, String question) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AITutorSheet(
      question: question,
      onClose: () => Navigator.of(context).pop(),
    ),
  );
}

class AppQuestionArenaPage extends StatefulWidget {
  final String subject;
  final String topic;
  const AppQuestionArenaPage({
    Key? key,
    required this.subject,
    required this.topic,
  }) : super(key: key);

  @override
  State<AppQuestionArenaPage> createState() => _AppQuestionArenaPageState();
}

class _AppQuestionArenaPageState extends State<AppQuestionArenaPage> {
  int current = 0;
  int combo = 0;
  bool showExplanation = false;
  int? selectedIdx;
  bool isCorrect = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What is the solution to x + 2 = 5?',
      'options': ['A) 2', 'B) 3', 'C) 5', 'D) 7'],
      'answer': 1,
      'explanation': 'x = 3 because 3 + 2 = 5.',
    },
    {
      'question': 'Which is a quadratic function?',
      'options': ['A) y = x', 'B) y = x^2', 'C) y = 2x + 1', 'D) y = 1/x'],
      'answer': 1,
      'explanation': 'y = x^2 is quadratic.',
    },
    {
      'question': 'What is the probability of flipping heads on a fair coin?',
      'options': ['A) 0', 'B) 0.25', 'C) 0.5', 'D) 1'],
      'answer': 2,
      'explanation': 'Probability is 0.5.',
    },
    {
      'question': 'Which is NOT a polygon?',
      'options': ['A) Triangle', 'B) Square', 'C) Circle', 'D) Pentagon'],
      'answer': 2,
      'explanation': 'Circle is not a polygon.',
    },
    {
      'question': 'What is the value of log10(100)?',
      'options': ['A) 1', 'B) 2', 'C) 10', 'D) 100'],
      'answer': 1,
      'explanation': 'log10(100) = 2.',
    },
  ];

  void handleSelect(int idx) {
    if (selectedIdx != null) return;
    setState(() {
      selectedIdx = idx;
      isCorrect = idx == questions[current]['answer'];
      showExplanation = !isCorrect;
      combo = isCorrect ? combo + 1 : 0;
    });
    if (isCorrect) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          current = (current + 1) % questions.length;
          selectedIdx = null;
          showExplanation = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[current];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF1E293B),
                      size: 28,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: combo > 0
                          ? const Color(0xFF358373)
                          : const Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Combo x$combo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Question Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                q['question'],
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Option Buttons
            ...List.generate(4, (idx) {
              final opt = q['options'][idx];
              Color borderColor = Colors.grey.shade300;
              Color fillColor = Colors.white;
              Color textColor = const Color(0xFF1E293B);
              if (selectedIdx != null) {
                if (idx == selectedIdx) {
                  if (isCorrect) {
                    borderColor = const Color(0xFF358373);
                    fillColor = const Color(0xFF358373);
                    textColor = Colors.white;
                  } else {
                    borderColor = const Color(0xFFEF4444);
                    fillColor = const Color(0xFFEF4444);
                    textColor = Colors.white;
                  }
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: GestureDetector(
                  onTap: () => handleSelect(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Mini Explanation
            if (showExplanation)
              Container(
                margin: const EdgeInsets.only(top: 18, left: 20, right: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  q['explanation'],
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                  ),
                ),
              ),
            // Ask Tutor 按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF358373),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  icon: const Icon(Icons.psychology),
                  label: const Text('Ask Tutor'),
                  onPressed: () => _showAITutorSheet(context, q['question']),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
