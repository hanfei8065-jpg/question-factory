import 'package:flutter/material.dart';

class SessionSummaryPage extends StatelessWidget {
  final int correctCount;
  final int totalCount;
  final int timeSpent; // in seconds

  const SessionSummaryPage({
    super.key,
    required this.correctCount,
    required this.totalCount,
    this.timeSpent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = totalCount > 0
        ? (correctCount / totalCount * 100).toStringAsFixed(1)
        : '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFF07C160),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 60,
                  ),
                ),

                const SizedBox(height: 24),

                // Great Job!
                const Text(
                  'Great Job!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 16),

                // Session Complete
                const Text(
                  'Session Complete',
                  style: TextStyle(fontSize: 18, color: Color(0xFF64748B)),
                ),

                const SizedBox(height: 40),

                // Stats Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Score',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '$correctCount / $totalCount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF07C160),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Accuracy
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Accuracy',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '$accuracy%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF07C160),
                            ),
                          ),
                        ],
                      ),

                      if (timeSpent > 0) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Time Spent',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '${(timeSpent ~/ 60)}m ${timeSpent % 60}s',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07C160),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
