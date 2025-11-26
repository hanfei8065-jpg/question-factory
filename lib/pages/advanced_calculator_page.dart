import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class AdvancedCalculatorPage extends StatefulWidget {
  const AdvancedCalculatorPage({super.key});

  @override
  State<AdvancedCalculatorPage> createState() => _AdvancedCalculatorPageState();
}

class _AdvancedCalculatorPageState extends State<AdvancedCalculatorPage> {
  String _expression = '';
  String _result = '';
  bool _isFraction = false;
  String _errorMessage = '';

  final List<List<String>> _basicButtons = [
    ['7', '8', '9', '÷'],
    ['4', '5', '6', '×'],
    ['1', '2', '3', '-'],
    ['0', '.', '=', '+'],
  ];

  final List<List<String>> _fractionButtons = [
    ['7', '8', '9', '÷'],
    ['4', '5', '6', '×'],
    ['1', '2', '3', '-'],
    ['0', '/', '=', '+'],
  ];

  void _onButtonPressed(String value) {
    setState(() {
      _errorMessage = '';
      if (value == '=') {
        _calculateResult();
      } else if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else {
        _expression += value;
      }
    });
  }

  void _calculateResult() {
    try {
      if (_isFraction) {
        _calculateFraction();
      } else {
        _calculateDecimal();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '计算出错了,检查一下算式吧~';
        _result = '';
      });
    }
  }

  void _calculateFraction() {
    // 处理分数计算
    if (_expression.contains('/')) {
      final parts = _expression.split('/');
      if (parts.length == 2) {
        try {
          final numerator = int.parse(parts[0]);
          final denominator = int.parse(parts[1]);
          if (denominator != 0) {
            setState(() {
              _result = '\\frac{$numerator}{$denominator}';
            });
            return;
          }
        } catch (e) {
          // 继续尝试其他计算方式
        }
      }
    }
    _calculateDecimal();
  }

  void _calculateDecimal() {
    final expr = _expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');

    try {
      Parser p = Parser();
      Expression exp = p.parse(expr);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        if (eval == eval.truncate().toDouble()) {
          _result = eval.truncate().toString();
        } else {
          _result = eval.toStringAsFixed(2);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '计算出错了,检查一下算式吧~';
        _result = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('计算器'),
        actions: [
          IconButton(
            icon: Icon(
              _isFraction ? Icons.functions : Icons.numbers,
              color: _isFraction ? Colors.blue : null,
            ),
            onPressed: () {
              setState(() {
                _isFraction = !_isFraction;
                _expression = '';
                _result = '';
              });
            },
            tooltip: _isFraction ? '分数模式' : '小数模式',
          ),
        ],
      ),
      body: Column(
        children: [
          // 表达式和结果显示区域
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expression,
                  style: const TextStyle(fontSize: 24, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                if (_result.isNotEmpty)
                  _isFraction && _result.startsWith('\\frac')
                      ? Math.tex(
                          _result,
                          textStyle: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          _result,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),

          // 分隔线
          const Divider(height: 1),

          // 按键区域
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  // 功能按钮行
                  Row(
                    children: [
                      _buildButton('C', flex: 2, color: Colors.orange[100]!),
                      _buildButton('⌫', flex: 2, color: Colors.orange[100]!),
                    ],
                  ),
                  // 数字和运算符按钮
                  ...(_isFraction ? _fractionButtons : _basicButtons).map((
                    row,
                  ) {
                    return Expanded(
                      child: Row(
                        children: row.map((button) {
                          return _buildButton(
                            button,
                            color: _isOperator(button)
                                ? Colors.blue[100]!
                                : Colors.white,
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isOperator(String button) {
    return ['÷', '×', '-', '+', '='].contains(button);
  }

  Widget _buildButton(String text, {int flex = 1, Color? color}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Material(
          color: color ?? Colors.white,
          child: InkWell(
            onTap: () => _onButtonPressed(text),
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: _isOperator(text) ? FontWeight.bold : null,
                  color: _isOperator(text) ? Colors.blue : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
