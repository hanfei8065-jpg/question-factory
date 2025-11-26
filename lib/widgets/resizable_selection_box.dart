import 'package:flutter/material.dart';

class ResizableSelectionBox extends StatefulWidget {
  final double initialWidth;
  final double initialHeight;
  final Function(Rect) onSelectionChanged;

  const ResizableSelectionBox({
    super.key,
    required this.initialWidth,
    required this.initialHeight,
    required this.onSelectionChanged,
  });

  @override
  State<ResizableSelectionBox> createState() => _ResizableSelectionBoxState();
}

class _ResizableSelectionBoxState extends State<ResizableSelectionBox> {
  late double _width;
  late double _height;
  late double _left;
  late double _top;

  static const double _minSize = 100.0;
  static const double _handleSize = 20.0;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
    _height = widget.initialHeight;
    _left = 0;
    _top = 0;
  }

  void _updateSelection() {
    widget.onSelectionChanged(Rect.fromLTWH(_left, _top, _width, _height));
  }

  void _handleDrag(DragUpdateDetails details, _DragHandle handle) {
    setState(() {
      switch (handle) {
        case _DragHandle.topLeft:
          _left += details.delta.dx;
          _top += details.delta.dy;
          _width -= details.delta.dx;
          _height -= details.delta.dy;
          break;
        case _DragHandle.topRight:
          _top += details.delta.dy;
          _width += details.delta.dx;
          _height -= details.delta.dy;
          break;
        case _DragHandle.bottomLeft:
          _left += details.delta.dx;
          _width -= details.delta.dx;
          _height += details.delta.dy;
          break;
        case _DragHandle.bottomRight:
          _width += details.delta.dx;
          _height += details.delta.dy;
          break;
        case _DragHandle.body:
          _left += details.delta.dx;
          _top += details.delta.dy;
          break;
      }

      // 确保不小于最小尺寸
      _width = _width.clamp(_minSize, double.infinity);
      _height = _height.clamp(_minSize, double.infinity);

      _updateSelection();
    });
  }

  Widget _buildHandle(_DragHandle handle) {
    return GestureDetector(
      onPanUpdate: (details) => _handleDrag(details, handle),
      child: Container(
        width: _handleSize,
        height: _handleSize,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue, width: 2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 半透明背景
        Positioned.fill(child: Container(color: Colors.black54)),

        // 选择框
        Positioned(
          left: _left,
          top: _top,
          child: GestureDetector(
            onPanUpdate: (details) => _handleDrag(details, _DragHandle.body),
            child: Container(
              width: _width,
              height: _height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Stack(
                children: [
                  // 清除选择框内的半透明背景
                  Positioned.fill(child: Container(color: Colors.transparent)),

                  // 四角拖拽点
                  Positioned(
                    left: -_handleSize / 2,
                    top: -_handleSize / 2,
                    child: _buildHandle(_DragHandle.topLeft),
                  ),
                  Positioned(
                    right: -_handleSize / 2,
                    top: -_handleSize / 2,
                    child: _buildHandle(_DragHandle.topRight),
                  ),
                  Positioned(
                    left: -_handleSize / 2,
                    bottom: -_handleSize / 2,
                    child: _buildHandle(_DragHandle.bottomLeft),
                  ),
                  Positioned(
                    right: -_handleSize / 2,
                    bottom: -_handleSize / 2,
                    child: _buildHandle(_DragHandle.bottomRight),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _DragHandle { topLeft, topRight, bottomLeft, bottomRight, body }
