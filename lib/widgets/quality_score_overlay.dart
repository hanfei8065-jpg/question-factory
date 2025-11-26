import 'package:flutter/material.dart';
import '../utils/image_quality_analyzer.dart';

class QualityScoreOverlay extends StatelessWidget {
  final ImageQualityScore score;
  final bool isExpanded;
  final VoidCallback onToggle;

  const QualityScoreOverlay({
    Key? key,
    required this.score,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 10,
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isExpanded ? 200 : 60,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(30),
          ),
          child: isExpanded ? _buildExpandedView() : _buildCollapsedView(),
        ),
      ),
    );
  }

  Widget _buildCollapsedView() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${score.totalScore}',
            style: TextStyle(
              color: _getScoreColor(score.totalScore),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.expand_more, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildExpandedView() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '拍摄质量',
                style: TextStyle(
                  color: _getScoreColor(score.totalScore),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${score.totalScore}分',
                style: TextStyle(
                  color: _getScoreColor(score.totalScore),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildScoreBar('亮度', score.brightnessScore),
          _buildScoreBar('清晰度', score.sharpnessScore),
          _buildScoreBar('边缘', score.edgeScore),
          _buildScoreBar('角度', score.angleScore),
          if (score.issues.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              score.issues.first,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
          const SizedBox(height: 4),
          const Center(
            child: Icon(Icons.expand_less, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: score / 100,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _getScoreColor(score),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$score',
              style: TextStyle(color: _getScoreColor(score), fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
