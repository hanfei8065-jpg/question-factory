import 'package:flutter/material.dart';
import 'dart:math' as math;

class EncouragementService {
  static final EncouragementService _instance =
      EncouragementService._internal();

  factory EncouragementService() {
    return _instance;
  }

  EncouragementService._internal();

  // 不同场景的鼓励语
  final Map<String, List<String>> _encouragements = {
    'camera': ['拍摄很稳定,继续保持!', '角度很好,这样更容易识别哦!', '光线很合适,真棒!'],
    'solve': ['解题思路很清晰!', '计算非常准确!', '这道题你掌握得很好!', '继续加油,你做得到!'],
    'practice': ['坚持就是胜利!', '每一次练习都在进步!', '你的认真让人印象深刻!', '保持这个势头,你会越来越好!'],
    'correction': [
      '勇于改正错误很了不起!',
      '从错误中学习是最好的进步!',
      '这次记住了,下次一定能做对!',
      '现在发现问题总比考试时发现好!',
    ],
    'milestone': [
      '太棒了!又完成了一个小目标!',
      '看看你的进步,真是令人欣慰!',
      '继续保持,你已经很出色了!',
      '这个成绩值得骄傲!',
    ],
  };

  String getRandomEncouragement(String scene) {
    if (!_encouragements.containsKey(scene)) {
      return '继续加油!';
    }
    final list = _encouragements[scene]!;
    return list[math.Random().nextInt(list.length)];
  }

  // 展示鼓励反馈
  void showEncouragement(
    BuildContext context,
    String scene, {
    String? customMessage,
  }) {
    final message = customMessage ?? getRandomEncouragement(scene);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.yellow),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 带有动画效果的奖励展示
  void showRewardAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _RewardAnimation(
          onFinished: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

// 奖励动画组件
class _RewardAnimation extends StatefulWidget {
  final VoidCallback onFinished;

  const _RewardAnimation({required this.onFinished});

  @override
  State<_RewardAnimation> createState() => _RewardAnimationState();
}

class _RewardAnimationState extends State<_RewardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40.0,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20.0),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60.0),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20.0),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 80),
            ),
          ),
        );
      },
    );
  }
}
