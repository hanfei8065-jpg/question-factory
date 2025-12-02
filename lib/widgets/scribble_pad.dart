import 'package:flutter/material.dart';

/// Scribble Pad - A transparent drawing layer over the solution content
/// Allows users to sketch math notations on top of the text
class ScribblePad extends StatefulWidget {
  const ScribblePad({super.key});

  @override
  State<ScribblePad> createState() => _ScribblePadState();
}

class _ScribblePadState extends State<ScribblePad> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDrawing = true;
            _currentStroke = [details.localPosition];
          });
        },
        onPanUpdate: (details) {
          if (_isDrawing) {
            setState(() {
              _currentStroke.add(details.localPosition);
            });
          }
        },
        onPanEnd: (details) {
          if (_isDrawing && _currentStroke.isNotEmpty) {
            setState(() {
              _strokes.add(List.from(_currentStroke));
              _currentStroke = [];
              _isDrawing = false;
            });
          }
        },
        child: CustomPaint(
          painter: _ScribblePainter(
            strokes: _strokes,
            currentStroke: _currentStroke,
          ),
          child: Container(
            color: Colors.transparent, // Fully transparent background
          ),
        ),
      ),
    );
  }
}

class _ScribblePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _ScribblePainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF07C160).withOpacity(0.7)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw all completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> stroke, Paint paint) {
    if (stroke.isEmpty) return;

    if (stroke.length == 1) {
      // Draw a point
      canvas.drawCircle(stroke[0], 1.5, paint);
    } else {
      // Draw connected lines
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ScribblePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
}
