import 'dart:io';
import 'package:flutter/material.dart';

class WorkspacePage extends StatefulWidget {
  final String question;
  final Function(String) onSubmitAnswer;
  final File? capturedImage; // 单张图片（单题模式）
  final List<File>? capturedImages; // 多张图片（多题模式）

  const WorkspacePage({
    super.key,
    required this.question,
    required this.onSubmitAnswer,
    this.capturedImage, // 可选参数
    this.capturedImages, // 可选参数
  });

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  List<List<Offset>> _lines = [];
  List<List<Offset>> _undoneLines = [];
  Color _currentColor = Colors.black;
  double _currentWidth = 2.0;
  bool _showCalculator = false;
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('演算区'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calculate,
              color: _showCalculator ? Colors.blue : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _showCalculator = !_showCalculator;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _lines.isEmpty
                ? null
                : () {
                    setState(() {
                      if (_lines.isNotEmpty) {
                        _undoneLines.add(_lines.removeLast());
                      }
                    });
                  },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _undoneLines.isEmpty
                ? null
                : () {
                    setState(() {
                      if (_undoneLines.isNotEmpty) {
                        _lines.add(_undoneLines.removeLast());
                      }
                    });
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _lines.isEmpty
                ? null
                : () {
                    setState(() {
                      _lines.clear();
                      _undoneLines.clear();
                    });
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // 题目显示区域
          if (widget.capturedImage != null)
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(widget.capturedImage!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          else if (widget.question.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.1),
              child: Text(
                widget.question,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          if (_showCalculator)
            Container(
              height: 240,
              color: Colors.grey[200],
              child: const CalculatorWidget(),
            ),
          Expanded(
            child: Stack(
              children: [
                // 演算区背景,使用淡色网格
                CustomPaint(painter: GridPainter(), child: Container()),
                // 手写区
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _lines.add([details.localPosition]);
                      _undoneLines.clear();
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _lines.last.add(details.localPosition);
                    });
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(
                      _lines,
                      _currentColor,
                      _currentWidth,
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      hintText: '输入你的答案...',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onSubmitAnswer(_answerController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 48),
                  ),
                  child: const Text('提交答案'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // 绘制网格
    const spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final Color color;
  final double width;

  DrawingPainter(this.lines, this.color, this.width);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    for (final line in lines) {
      if (line.length < 2) continue;
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

class CalculatorWidget extends StatefulWidget {
  const CalculatorWidget({super.key});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _display = '0';
  String _expression = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
      } else if (value == '=') {
        try {
          // 简单计算逻辑,实际应用中需要更复杂的计算引擎
          _display = eval(_expression).toString();
          _expression = _display;
        } catch (e) {
          _display = 'Error';
          _expression = '';
        }
      } else {
        if (_display == '0' && !isOperator(value)) {
          _display = value;
          _expression = value;
        } else {
          _display += value;
          _expression += value;
        }
      }
    });
  }

  bool isOperator(String value) {
    return ['+', '-', '×', '÷'].contains(value);
  }

  // 简单的计算函数,实际应用中需要更完善的计算引擎
  double eval(String exp) {
    // 这里只是一个示例,需要实现完整的计算逻辑
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerRight,
          child: Text(_display, style: const TextStyle(fontSize: 24)),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 1.5,
            children:
                [
                  '7',
                  '8',
                  '9',
                  '÷',
                  '4',
                  '5',
                  '6',
                  '×',
                  '1',
                  '2',
                  '3',
                  '-',
                  'C',
                  '0',
                  '=',
                  '+',
                ].map((key) {
                  return TextButton(
                    child: Text(key, style: const TextStyle(fontSize: 24)),
                    onPressed: () => _onButtonPressed(key),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
