import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Braun-Style Calculator Variants
/// Industrial Design with Solid Colors and Tactile Feel
enum CalculatorVariant {
  basic, // White Body, Orange Accent
  scientific, // Dark Grey Body, Emerald Accent
  graphing, // Navy Blue Body, Yellow Accent
  programmer, // Black Body, Red Accent
}

class BraunCalculator extends StatefulWidget {
  final CalculatorVariant variant;
  final Function(String)? onSubmitAnswer;

  const BraunCalculator({
    super.key,
    this.variant = CalculatorVariant.basic,
    this.onSubmitAnswer,
  });

  @override
  State<BraunCalculator> createState() => _BraunCalculatorState();
}

class _BraunCalculatorState extends State<BraunCalculator> {
  String _display = '0';
  String _expression = '';
  String? _activeButton;

  Color get _bodyColor {
    switch (widget.variant) {
      case CalculatorVariant.basic:
        return Colors.white;
      case CalculatorVariant.scientific:
        return const Color(0xFF374151); // Dark Grey
      case CalculatorVariant.graphing:
        return const Color(0xFF1E3A8A); // Navy Blue
      case CalculatorVariant.programmer:
        return const Color(0xFF0F0F0F); // Black
    }
  }

  Color get _accentColor {
    switch (widget.variant) {
      case CalculatorVariant.basic:
        return const Color(0xFFF97316); // Orange
      case CalculatorVariant.scientific:
        return const Color(0xFF10B981); // Emerald
      case CalculatorVariant.graphing:
        return const Color(0xFFFBBF24); // Yellow
      case CalculatorVariant.programmer:
        return const Color(0xFFEF4444); // Red
    }
  }

  Color get _textColor {
    return widget.variant == CalculatorVariant.basic
        ? const Color(0xFF1F2937)
        : Colors.white;
  }

  Color get _buttonColor {
    return widget.variant == CalculatorVariant.basic
        ? const Color(0xFFF3F4F6)
        : Colors.white.withOpacity(0.1);
  }

  List<List<String>> get _buttonLayout {
    switch (widget.variant) {
      case CalculatorVariant.scientific:
        return [
          ['sin', 'cos', 'tan', 'ln', 'C'],
          ['7', '8', '9', '÷', '√'],
          ['4', '5', '6', '×', 'x²'],
          ['1', '2', '3', '-', '('],
          ['0', '.', '=', '+', ')'],
        ];
      case CalculatorVariant.graphing:
        return [
          ['y=', 'graph', 'table', 'trace', 'C'],
          ['7', '8', '9', '÷', 'x'],
          ['4', '5', '6', '×', '^'],
          ['1', '2', '3', '-', '('],
          ['0', '.', '=', '+', ')'],
        ];
      case CalculatorVariant.programmer:
        return [
          ['HEX', 'DEC', 'BIN', 'OCT', 'C'],
          ['7', '8', '9', '÷', 'AND'],
          ['4', '5', '6', '×', 'OR'],
          ['1', '2', '3', '-', 'XOR'],
          ['0', '.', '=', '+', 'NOT'],
        ];
      default: // Basic
        return [
          ['C', '±', '%', '÷'],
          ['7', '8', '9', '×'],
          ['4', '5', '6', '-'],
          ['1', '2', '3', '+'],
          ['0', '.', '='],
        ];
    }
  }

  void _onButtonPressed(String value) {
    // Haptic feedback on every button press
    HapticFeedback.lightImpact();

    setState(() {
      _activeButton = value;
    });

    // Reset active state after animation
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _activeButton = null;
        });
      }
    });

    // Handle calculator logic
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
    try {
      _expression = _display;
      // If onSubmitAnswer callback is provided, use it (for answer verification)
      if (widget.onSubmitAnswer != null) {
        widget.onSubmitAnswer!(_display);
        // Show "Checking..." in display during verification
        setState(() {
          _display = 'Checking...';
        });
      } else {
        // TODO: Implement actual calculation
        _display = 'Result';
      }
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
    if (_display == '0' || _display == 'Error' || _display == 'Result') {
      _display = value;
    } else {
      _display += value;
    }
  }

  Widget _buildButton(String text) {
    final isOperator = ['÷', '×', '-', '+', '='].contains(text);
    final isActive = _activeButton == text;

    return AnimatedScale(
      scale: isActive ? 0.95 : 1.0, // Physical click feel
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Material(
        color: isOperator ? _accentColor : _buttonColor,
        borderRadius: BorderRadius.circular(12),
        elevation: isActive ? 0 : 2,
        child: InkWell(
          onTap: () => _onButtonPressed(text),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: text.length > 2 ? 14 : 20,
                fontWeight: FontWeight.w600,
                color: isOperator
                    ? (widget.variant == CalculatorVariant.graphing
                          ? const Color(0xFF1F2937)
                          : Colors.white)
                    : _textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = _buttonLayout;

    return Container(
      decoration: BoxDecoration(
        color: _bodyColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_expression.isNotEmpty)
                  Text(
                    _expression,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textColor.withOpacity(0.5),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _display,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Button grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: layout.map((row) {
                  return Expanded(
                    child: Row(
                      children: row.map((text) {
                        return Expanded(
                          flex:
                              (text == '0' &&
                                  widget.variant == CalculatorVariant.basic)
                              ? 2
                              : 1,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: _buildButton(text),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Variant indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.variant.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
