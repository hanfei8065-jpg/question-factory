// [LEARNEST_TESLA_SUMMARY_V3.0] - 结果展示页 (上线定稿版)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- 复用物理引擎 ---
class TeslaScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const TeslaScaleWrapper({super.key, required this.child, this.onTap});
  @override
  State<TeslaScaleWrapper> createState() => _TeslaScaleWrapperState();
}

class _TeslaScaleWrapperState extends State<TeslaScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

class SessionSummaryPage extends StatelessWidget {
  final int correctCount;
  final int totalCount;
  final int timeSpent;

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
      backgroundColor: Colors.white, // 改为纯白，更符合 Zen Mode
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            children: [
              const Spacer(),
              // 奖杯勋章区 (使用 Tesla Red 高亮)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFE82127).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_outlined,
                    color: Color(0xFFE82127), size: 70),
              ),
              const SizedBox(height: 32),
              const Text("本次练习达成",
                  style: TextStyle(
                      fontSize: 16, color: Colors.black38, letterSpacing: 2)),
              const SizedBox(height: 12),
              Text("$correctCount / $totalCount",
                  style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Monospace')),
              const SizedBox(height: 48),

              // 数据统计区
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("正确率", "$accuracy%", Icons.verified_outlined),
                  _buildStatItem(
                      "总耗时",
                      "${(timeSpent / 60).floor()}m ${timeSpent % 60}s",
                      Icons.timer_outlined),
                ],
              ),
              const Spacer(),

              // 底部按钮区 (Tesla 风格)
              Column(
                children: [
                  TeslaScaleWrapper(
                    onTap: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16)),
                      child: const Center(
                          child: Text("返回首页",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TeslaScaleWrapper(
                    onTap: () {/* 分享逻辑 */},
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(16)),
                      child: const Center(
                          child: Text("生成分享卡片",
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 16))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.black87, size: 28),
        const SizedBox(height: 12),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.black26, fontSize: 12)),
      ],
    );
  }
}
