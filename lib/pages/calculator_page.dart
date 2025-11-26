import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  bool _isScientific = false;
  String _mode = 'standard'; // standard, scientific, fraction, complex

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '计算器',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.mode_edit, color: Colors.black),
            onSelected: (value) {
              setState(() {
                _mode = value;
                _clear();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'standard', child: Text('标准')),
              const PopupMenuItem(value: 'scientific', child: Text('科学')),
              const PopupMenuItem(value: 'fraction', child: Text('分数')),
              const PopupMenuItem(value: 'complex', child: Text('复数')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Display
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _expression,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _display,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Buttons
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _buildButtons(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildButtons() {
    final buttons = [
      ['C', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    List<Widget> widgets = [];

    for (var row = 0; row < buttons.length; row++) {
      for (var col = 0; col < buttons[row].length; col++) {
        final text = buttons[row][col];
        final isLast =
            row == buttons.length - 1 && col == buttons[row].length - 1;
        final isZero = row == buttons.length - 1 && col == 0;

        widgets.add(
          GridView.count(
            crossAxisCount: 1,
            children: [
              _buildButton(
                text: text,
                isOperator: '÷×-+='.contains(text),
                isZero: isZero,
                isEquals: isLast,
              ),
            ],
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildButton({
    required String text,
    bool isOperator = false,
    bool isZero = false,
    bool isEquals = false,
  }) {
    return Material(
      color: isEquals
          ? const Color(0xFF2563EB)
          : isOperator
          ? const Color(0xFFF3F4F6)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _onButtonPressed(text),
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isEquals
                  ? Colors.white
                  : isOperator
                  ? const Color(0xFF2563EB)
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _onButtonPressed(String value) {
    setState(() {
      switch (value) {
        case 'C':
          _clear();
          break;
        case '=':
          _calculate();
          break;
        case '±':
          _toggleSign();
          break;
        case '%':
          _percentage();
          break;
        default:
          _updateDisplay(value);
      }
    });
  }

  void _clear() {
    _display = '0';
    _expression = '';
  }

  void _calculate() {
    // TODO: Implement calculation based on mode
    try {
      _expression = _display;
      _display = '计算结果'; // 替换为实际计算结果
    } catch (e) {
      _display = 'Error';
    }
  }

  void _toggleSign() {
    if (_display != '0' && _display != 'Error') {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    }
  }

  void _percentage() {
    try {
      final value = double.parse(_display);
      _display = (value / 100).toString();
    } catch (e) {
      _display = 'Error';
    }
  }

  void _updateDisplay(String value) {
    if (_display == '0' || _display == 'Error') {
      _display = value;
    } else {
      _display += value;
    }
  }
}
