import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/handwriting_canvas.dart'; // ✅ 手写画板

/// 计算器风格
enum CalculatorVariant {
  classic, // 经典风格
  dark, // 深色风格
  blue, // 蓝色风格
  gold, // 金色风格
}

/// 全屏计算器页面
/// Layout: HandwritingCanvas (Top 1/3) + Calculator Keypad (Bottom 2/3)
class CalculatorPage extends StatefulWidget {
  final CalculatorVariant variant;

  const CalculatorPage({super.key, required this.variant});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _displayValue = "0";
  String _history = "";

  @override
  Widget build(BuildContext context) {
    // 根据变体选择背景色 (适配 Braun 风格)
    Color bgColor;
    switch (widget.variant) {
      case CalculatorVariant.classic:
        bgColor = const Color(0xFFF5F5F5); // 经典白
        break;
      case CalculatorVariant.dark:
        bgColor = const Color(0xFF1E1E1E); // 深空灰
        break;
      case CalculatorVariant.blue:
        bgColor = const Color(0xFFE3F2FD); // 银河蓝
        break;
      case CalculatorVariant.gold:
        bgColor = const Color(0xFFFFF8E1); // 晨曦金
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
    }

    final isDark = widget.variant == CalculatorVariant.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getVariantName(),
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 手写画板 (Top 1/3)
          Expanded(flex: 1, child: const HandwritingCanvas()),

          // 2. 计算器键盘区域 (Bottom 2/3)
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: _buildCalculatorKeypad(textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 简单的计算器键盘 (MVP版本)
  Widget _buildCalculatorKeypad(Color textColor) {
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        // Row 1
        _buildKey('C', textColor, isOperator: true),
        _buildKey('÷', textColor, isOperator: true),
        _buildKey('×', textColor, isOperator: true),
        _buildKey('⌫', textColor, isOperator: true),
        // Row 2
        _buildKey('7', textColor),
        _buildKey('8', textColor),
        _buildKey('9', textColor),
        _buildKey('-', textColor, isOperator: true),
        // Row 3
        _buildKey('4', textColor),
        _buildKey('5', textColor),
        _buildKey('6', textColor),
        _buildKey('+', textColor, isOperator: true),
        // Row 4
        _buildKey('1', textColor),
        _buildKey('2', textColor),
        _buildKey('3', textColor),
        _buildKey('=', textColor, isOperator: true, isEqual: true),
        // Row 5 (last row)
        _buildKey('0', textColor),
        _buildKey('.', textColor),
        _buildKey('()', textColor),
        _buildKey('', textColor), // 空按钮占位
      ],
    );
  }

  Widget _buildKey(
    String label,
    Color textColor, {
    bool isOperator = false,
    bool isEqual = false,
  }) {
    if (label.isEmpty) return const SizedBox.shrink();

    return Material(
      color: isEqual
          ? const Color(0xFF07C160) // WeChat Green
          : isOperator
          ? Colors.grey.shade300
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _onKeyTap(label),
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: isOperator ? FontWeight.w600 : FontWeight.normal,
              color: isEqual ? Colors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }

  void _onKeyTap(String key) {
    // MVP: 简单的显示逻辑
    setState(() {
      if (key == 'C') {
        _displayValue = '0';
        _history = '';
      } else if (key == '⌫') {
        if (_displayValue.length > 1) {
          _displayValue = _displayValue.substring(0, _displayValue.length - 1);
        } else {
          _displayValue = '0';
        }
      } else if (key == '=') {
        // TODO: 实际计算逻辑
        _history = _displayValue;
      } else {
        if (_displayValue == '0') {
          _displayValue = key;
        } else {
          _displayValue += key;
        }
      }
    });
  }

  String _getVariantName() {
    switch (widget.variant) {
      case CalculatorVariant.classic:
        return '基础计算器';
      case CalculatorVariant.dark:
        return '科学计算器'; // 对应选择页的逻辑
      case CalculatorVariant.blue:
        return '高级函数';
      case CalculatorVariant.gold:
        return '图形计算器';
      default:
        return 'Calculator';
    }
  }
}
