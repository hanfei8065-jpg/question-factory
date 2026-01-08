import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  bool _isScientific = true;

  // --- 计算器核心状态 ---
  String _expression = "";
  String _result = "0";

  // --- 换算器核心状态 ---
  double _inputValue = 0.0;
  String _fromUnit = "mm";
  String _toUnit = "cm";
  final Map<String, double> _units = {
    "mm": 0.001,
    "cm": 0.01,
    "m": 1.0,
    "km": 1000.0,
    "inch": 0.0254,
    "ft": 0.3048,
  };

  // 1:1 还原色值
  static const Color colorBg = Color(0xFFF9FAFB);
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorTextPrimary = Color(0xFF111827);
  static const Color colorTextSecondary = Color(0xFF6B7280);
  static const Color colorBtnGray = Color(0xFFE5E7EB);
  static const Color colorBtnPink = Color(0xFFFBCFE8);

  // --- 核心逻辑：强化版表达式解析 ---
  void _calculateResult() {
    if (_expression.isEmpty) return;
    try {
      // 1. 基础符号转换
      String finalExp = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', '3.1415926535')
          .replaceAll('e', '2.7182818284');

      // 2. 核心修复：处理根号逻辑 (√5 -> sqrt(5))
      // 这里的正则会自动寻找根号后的数字并用括号括起来
      finalExp = finalExp.replaceAllMapped(RegExp(r'√(\d+(\.\d+)?)'), (match) {
        return 'sqrt(${match.group(1)})';
      });

      // 3. 处理隐式乘法：数字后面直接跟 sqrt 或 (
      // 例如把 1sqrt(5) 变成 1*sqrt(5)
      finalExp = finalExp.replaceAllMapped(RegExp(r'(\d)(sqrt|\()'), (match) {
        return '${match.group(1)}*${match.group(2)}';
      });

      Parser p = Parser();
      Expression exp = p.parse(finalExp);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _result = eval.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), "");
      });
    } catch (e) {
      setState(() => _result = "Error");
    }
  }

  // --- 核心逻辑：单位换算 ---
  String _getConvertedValue() {
    double meters = _inputValue * _units[_fromUnit]!;
    double converted = meters / _units[_toUnit]!;
    return converted.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            // 解决溢出：使用 Flexible 配合最低高度限制，确保按键区有固定空间
            Flexible(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  // 防止输入过长导致溢出
                  reverse: true,
                  child: _isScientific
                      ? _buildSciDisplay()
                      : _buildConvDisplay(),
                ),
              ),
            ),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  // --- 1:1 UI 实现 ---
  Widget _buildHeader() {
    return Container(
      height: 64, // 略微压缩 Header 高度腾出空间给按键
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 22,
              color: colorTextPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              children: [
                _toggleBtn(
                  "Scientific",
                  _isScientific,
                  () => setState(() => _isScientific = true),
                ),
                _toggleBtn(
                  "Converter",
                  !_isScientific,
                  () => setState(() => _isScientific = false),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 40,
            child: Icon(Icons.grid_view_rounded, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String l, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: active ? colorTextPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          l,
          style: TextStyle(
            color: active ? colorWhite : colorTextPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSciDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _expression,
          style: const TextStyle(fontSize: 22, color: colorTextSecondary),
        ),
        Text(
          _result,
          style: const TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.w400,
            color: colorTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildConvDisplay() {
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() {
            final t = _fromUnit;
            _fromUnit = _toUnit;
            _toUnit = t;
          }),
          icon: const Icon(Icons.swap_vert, size: 32, color: colorTextPrimary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _unitRow(
                _inputValue.toString().replaceAll(RegExp(r'\.0$'), ""),
                _fromUnit,
                54,
                colorTextPrimary,
                true,
              ),
              const SizedBox(height: 12),
              _unitRow(
                _getConvertedValue(),
                _toUnit,
                44,
                colorTextSecondary,
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _unitRow(
    String val,
    String unit,
    double size,
    Color color,
    bool isFrom,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          val,
          style: TextStyle(fontSize: size, color: color),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: unit,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          items: _units.keys
              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
              .toList(),
          onChanged: (v) =>
              setState(() => isFrom ? _fromUnit = v! : _toUnit = v!),
        ),
      ],
    );
  }

  // --- 键盘逻辑逻辑完善 ---
  void _handlePress(String label) {
    setState(() {
      if (_isScientific) {
        if (label == "AC") {
          _expression = "";
          _result = "0";
        } else if (label == "=") {
          _calculateResult();
        } else if (label == "←") {
          if (_expression.isNotEmpty)
            _expression = _expression.substring(0, _expression.length - 1);
        } else if (["sin", "cos", "tan", "log", "√"].contains(label)) {
          _expression += "$label(";
        } // 自动补齐左括号
        else {
          _expression += label;
        }
      } else {
        if (label == "AC")
          _inputValue = 0;
        else if (RegExp(r'[0-9]').hasMatch(label)) {
          String current = _inputValue.toInt().toString();
          _inputValue = double.parse("${current == '0' ? '' : current}$label");
        }
      }
    });
  }

  Widget _buildKeypad() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: _isScientific ? _buildSciKeypad() : _buildConvKeypad(),
    );
  }

  Widget _buildSciKeypad() {
    final List<String> f = [
      "nCr",
      "nPr",
      "←",
      "→",
      "S⟷D",
      "Rad",
      "e",
      "ln",
      "log₁₀",
      "log",
      "(",
      ")",
      "sin",
      "cos",
      "tan",
      "π",
      "x!",
      "||",
      "°",
      "⊟",
      "x²",
      "√",
      "³√",
      "ⁿ√",
    ];
    final List<String> m = [
      "AC",
      "±",
      "%",
      "÷",
      "7",
      "8",
      "9",
      "×",
      "4",
      "5",
      "6",
      "-",
      "1",
      "2",
      "3",
      "+",
      "⏱",
      "0",
      ".",
      "=",
    ];
    return Column(
      children: [
        _grid(f, 6, 44, 13, 14, 6, colorBtnGray), // 略微压缩科学按键高度防止溢出
        const SizedBox(height: 6),
        _grid(m, 4, 60, 19, 14, 6, colorBtnGray),
      ],
    );
  }

  Widget _buildConvKeypad() {
    final List<String> m = [
      "AC",
      "±",
      "%",
      "÷",
      "7",
      "8",
      "9",
      "×",
      "4",
      "5",
      "6",
      "-",
      "1",
      "2",
      "3",
      "+",
      "⏱",
      "0",
      ".",
      "=",
    ];
    return _grid(m, 4, 76, 23, 22, 10, Color(0xFFD1D5DB));
  }

  Widget _grid(
    List<String> labels,
    int cols,
    double h,
    double fs,
    double r,
    double gap,
    Color bg,
  ) {
    return GridDelegate(labels, cols, h, fs, r, gap, bg);
  }

  Widget GridDelegate(
    List<String> labels,
    int cols,
    double h,
    double fs,
    double r,
    double gap,
    Color bg,
  ) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        mainAxisExtent: h,
      ),
      itemCount: labels.length,
      itemBuilder: (context, index) {
        String l = labels[index];
        bool isPink = ["÷", "×", "-", "+", "="].contains(l);
        return GestureDetector(
          onTap: () => _handlePress(l),
          child: Container(
            decoration: BoxDecoration(
              color: isPink ? colorBtnPink : bg,
              borderRadius: BorderRadius.circular(r),
            ),
            alignment: Alignment.center,
            child: Text(
              l,
              style: TextStyle(
                color: colorTextPrimary,
                fontSize: fs,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
