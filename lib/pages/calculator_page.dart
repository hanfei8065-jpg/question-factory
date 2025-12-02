import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/braun_calculator.dart';

/// 全屏计算器页面
/// Layout: Display Screen (Top) + Braun Keypad (Bottom)
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
          // 1. 显示屏区域 (Display Screen)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 历史记录 (Equation)
                  Text(
                    _history,
                    style: TextStyle(
                      fontSize: 24,
                      color: textColor.withOpacity(0.6),
                      fontFamily: 'Courier', // 更有计算器感
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 当前结果 (Big Result)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _displayValue,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        color: textColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 键盘区域 (Keypad)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white54,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: BraunCalculator(
                  variant: widget.variant,
                  isFullScreen: true, // 告诉组件这是全屏模式，不需要缩放
                  onSubmitAnswer: (value) {
                    // 全屏模式下，按 '=' 只更新屏幕，不自动返回
                    // 这里接收组件传回来的计算结果更新 UI
                    setState(() {
                      _displayValue = value;
                    });
                  },
                  onHistoryChange: (history) {
                    setState(() {
                      _history = history;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
