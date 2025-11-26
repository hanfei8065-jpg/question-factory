import 'package:flutter/material.dart';

class SwipeGestureDetector extends StatefulWidget {
  final Widget child;
  final Function()? onSwipeLeft;
  final Function()? onSwipeRight;
  final Function()? onSwipeUp;
  final Function()? onSwipeDown;
  final double sensitivity;

  const SwipeGestureDetector({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.sensitivity = 10.0,
  });

  @override
  State<SwipeGestureDetector> createState() => _SwipeGestureDetectorState();
}

class _SwipeGestureDetectorState extends State<SwipeGestureDetector> {
  Offset? _startPosition;

  void _onPanStart(DragStartDetails details) {
    _startPosition = details.localPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_startPosition == null) return;

    final dx = _startPosition!.dx;
    final dy = _startPosition!.dy;
    _startPosition = null;

    // 计算滑动距离
    final horizontal = details.velocity.pixelsPerSecond.dx;
    final vertical = details.velocity.pixelsPerSecond.dy;

    // 判断滑动方向
    if (horizontal.abs() > vertical.abs()) {
      if (horizontal.abs() < widget.sensitivity) return;

      if (horizontal > 0) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
    } else {
      if (vertical.abs() < widget.sensitivity) return;

      if (vertical > 0) {
        widget.onSwipeDown?.call();
      } else {
        widget.onSwipeUp?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}
