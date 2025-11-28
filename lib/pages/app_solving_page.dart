import 'package:flutter/material.dart';
import 'package:learnest_fresh/widgets/aitutor_sheet.dart';

void _showAITutorSheet(BuildContext context) {
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

class AppSolvingPage extends StatefulWidget {
  final String? imagePath;
  const AppSolvingPage({Key? key, this.imagePath}) : super(key: key);

  @override
  State<AppSolvingPage> createState() => _AppSolvingPageState();
}

class _AppSolvingPageState extends State<AppSolvingPage> {
  final TextEditingController _controller = TextEditingController();
  bool _showCalculator = false;
  bool _showPeekWarning = false;
  bool _showBingo = false;

  // Demo数据
  final String question = "Solve for x: 2x + 4 = 12";
  final List<String> steps = [
    "Subtract 4 from both sides: 2x = 8",
    "Divide by 2: x = 4",
  ];
  final String correctAnswer = "4";

  void _submit() {
    if (_controller.text.trim() == correctAnswer) {
      setState(() => _showBingo = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showBingo = false);
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFB9E4D4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.emoji_events, color: Color(0xFF358373), size: 48),
              SizedBox(height: 12),
              Text(
                'BINGO! +50 XP',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF358373),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Try again!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showPeekDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Peek Warning',
          style: TextStyle(
            color: Color(0xFF358373),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('You must calculate to unlock the answer!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF358373))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Snap-to-Solve',
          style: TextStyle(
            color: Color(0xFF358373),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calculate,
              color: _showCalculator ? Colors.orange : const Color(0xFF358373),
            ),
            onPressed: () => setState(() => _showCalculator = !_showCalculator),
            tooltip: 'Calculator',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top: 图片
                  if (widget.imagePath != null)
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: AssetImage(widget.imagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  // 题目
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF358373),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // 步骤卡片
                  ...steps.asMap().entries.map((entry) {
                    final isLast = entry.key == steps.length - 1;
                    return Stack(
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 20,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Step ${entry.key + 1}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF358373),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 最后一步加遮罩
                        if (isLast)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _showPeekDialog,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFB9E4D4,
                                  ).withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.lock,
                                        color: Color(0xFF358373),
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Calculate to unlock',
                                        style: TextStyle(
                                          color: Color(0xFF358373),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 32),
                  // Ask Tutor 按钮
                  SizedBox(
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
                      onPressed: () => _showAITutorSheet(context),
                    ),
                  ),
                  // 输入区
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Enter your answer...',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF358373),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Calculator Overlay
          if (_showCalculator)
            Positioned(
              top: 80,
              right: 24,
              left: 24,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF358373), width: 2),
                ),
                child: const Center(
                  child: Text(
                    'Calculator (Demo)',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF358373),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
