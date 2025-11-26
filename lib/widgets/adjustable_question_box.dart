import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class AdjustableQuestionBox extends StatefulWidget {
  final Rect initialRect;
  final ui.Image image;
  final Function(Rect) onRectChanged;

  const AdjustableQuestionBox({
    Key? key,
    required this.initialRect,
    required this.image,
    required this.onRectChanged,
  }) : super(key: key);

  @override
  State<AdjustableQuestionBox> createState() => _AdjustableQuestionBoxState();
}

class _AdjustableQuestionBoxState extends State<AdjustableQuestionBox> {
  late Rect _currentRect;
  _DragHandle? _activeDragHandle;
  Offset? _dragStart;
  Rect? _dragStartRect;

  @override
  void initState() {
    super.initState();
    _currentRect = widget.initialRect;
  }

  void _handleDragStart(Offset position, _DragHandle handle) {
    _activeDragHandle = handle;
    _dragStart = position;
    _dragStartRect = _currentRect;
  }

  void _handleDragUpdate(Offset position) {
    if (_dragStart == null || _dragStartRect == null) return;

    final delta = position - _dragStart!;
    var newRect = _dragStartRect!;

    // 根据拖动手柄更新矩形
    switch (_activeDragHandle) {
      case _DragHandle.topLeft:
        newRect = Rect.fromLTRB(
          newRect.left + delta.dx,
          newRect.top + delta.dy,
          newRect.right,
          newRect.bottom,
        );
        break;
      case _DragHandle.topRight:
        newRect = Rect.fromLTRB(
          newRect.left,
          newRect.top + delta.dy,
          newRect.right + delta.dx,
          newRect.bottom,
        );
        break;
      case _DragHandle.bottomLeft:
        newRect = Rect.fromLTRB(
          newRect.left + delta.dx,
          newRect.top,
          newRect.right,
          newRect.bottom + delta.dy,
        );
        break;
      case _DragHandle.bottomRight:
        newRect = Rect.fromLTRB(
          newRect.left,
          newRect.top,
          newRect.right + delta.dx,
          newRect.bottom + delta.dy,
        );
        break;
      case _DragHandle.whole:
        newRect = newRect.translate(delta.dx, delta.dy);
        break;
      default:
        break;
    }

    // 确保矩形在图片范围内
    newRect = _constrainRect(newRect);

    // 确保矩形大小合理
    if (newRect.width >= 20 && newRect.height >= 20) {
      setState(() {
        _currentRect = newRect;
      });
      widget.onRectChanged(newRect);
    }
  }

  void _handleDragEnd() {
    _activeDragHandle = null;
    _dragStart = null;
    _dragStartRect = null;
  }

  Rect _constrainRect(Rect rect) {
    final imageRect =
        Offset.zero &
        Size(widget.image.width.toDouble(), widget.image.height.toDouble());

    // 约束左上角
    var left = rect.left.clamp(imageRect.left, imageRect.right);
    var top = rect.top.clamp(imageRect.top, imageRect.bottom);

    // 约束右下角
    var right = rect.right.clamp(left + 20, imageRect.right);
    var bottom = rect.bottom.clamp(top + 20, imageRect.bottom);

    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景遮罩
        _buildMask(),

        // 选择框
        Positioned.fromRect(
          rect: _currentRect,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
            ),
          ),
        ),

        // 拖动手柄
        ..._buildHandles(),

        // 整体拖动区域
        Positioned.fromRect(
          rect: _currentRect,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) =>
                _handleDragStart(details.localPosition, _DragHandle.whole),
            onPanUpdate: (details) => _handleDragUpdate(details.localPosition),
            onPanEnd: (_) => _handleDragEnd(),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildMask() {
    return CustomPaint(
      painter: _MaskPainter(
        rect: _currentRect,
        imageSize: Size(
          widget.image.width.toDouble(),
          widget.image.height.toDouble(),
        ),
      ),
    );
  }

  List<Widget> _buildHandles() {
    const handleSize = 20.0;
    final handles = <Widget>[];

    // 四个角的手柄
    final corners = [
      (_DragHandle.topLeft, Alignment.topLeft),
      (_DragHandle.topRight, Alignment.topRight),
      (_DragHandle.bottomLeft, Alignment.bottomLeft),
      (_DragHandle.bottomRight, Alignment.bottomRight),
    ];

    for (var (handle, alignment) in corners) {
      final position = _getHandlePosition(alignment, handleSize);
      handles.add(
        Positioned(
          left: position.dx,
          top: position.dy,
          child: _DragHandleWidget(
            onDragStart: (position) => _handleDragStart(position, handle),
            onDragUpdate: _handleDragUpdate,
            onDragEnd: _handleDragEnd,
          ),
        ),
      );
    }

    return handles;
  }

  Offset _getHandlePosition(Alignment alignment, double handleSize) {
    late double x, y;

    if (alignment == Alignment.topLeft) {
      x = _currentRect.left - handleSize / 2;
      y = _currentRect.top - handleSize / 2;
    } else if (alignment == Alignment.topRight) {
      x = _currentRect.right - handleSize / 2;
      y = _currentRect.top - handleSize / 2;
    } else if (alignment == Alignment.bottomLeft) {
      x = _currentRect.left - handleSize / 2;
      y = _currentRect.bottom - handleSize / 2;
    } else {
      x = _currentRect.right - handleSize / 2;
      y = _currentRect.bottom - handleSize / 2;
    }

    return Offset(x, y);
  }
}

enum _DragHandle { topLeft, topRight, bottomLeft, bottomRight, whole }

class _DragHandleWidget extends StatelessWidget {
  final Function(Offset) onDragStart;
  final Function(Offset) onDragUpdate;
  final VoidCallback onDragEnd;

  const _DragHandleWidget({
    Key? key,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) => onDragStart(details.localPosition),
      onPanUpdate: (details) => onDragUpdate(details.localPosition),
      onPanEnd: (_) => onDragEnd(),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _MaskPainter extends CustomPainter {
  final Rect rect;
  final Size imageSize;

  _MaskPainter({required this.rect, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // 绘制整个遮罩
    canvas.drawRect(Offset.zero & imageSize, paint);

    // 清除选中区域的遮罩
    canvas.drawRect(rect, Paint()..blendMode = BlendMode.clear);
  }

  @override
  bool shouldRepaint(_MaskPainter oldDelegate) {
    return rect != oldDelegate.rect || imageSize != oldDelegate.imageSize;
  }
}
