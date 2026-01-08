// [LEARNEST_TESLA_ACCORDION_V4.0_COMPLETE] - 完整逻辑与接口对齐版
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'app_focus_mode_page.dart'; // 确保引用正确

// --- 1. 物理引擎：Tesla 缩放反馈 ---
class TeslaScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableFeedback;

  const TeslaScaleWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.enableFeedback = true,
  });

  @override
  State<TeslaScaleWrapper> createState() => _TeslaScaleWrapperState();
}

class _TeslaScaleWrapperState extends State<TeslaScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.enableFeedback) HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

// --- 2. 视觉组件：全息矩阵磁贴 ---
class TeslaMatrixTile extends StatelessWidget {
  final String label;
  final int weight;

  const TeslaMatrixTile({
    super.key,
    required this.label,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (weight) {
      case 3:
        bgColor = const Color(0xFFE82127);
        textColor = Colors.white;
        break;
      case 2:
        bgColor = const Color(0xFF005BC5);
        textColor = Colors.white;
        break;
      case 1:
        bgColor = const Color(0xFF424242);
        textColor = Colors.white;
        break;
      case 0:
      default:
        bgColor = const Color(0xFFF2F2F7);
        textColor = Colors.black45;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: weight > 0
            ? [
                BoxShadow(
                    color: bgColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3))
              ]
            : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: weight > 0 ? FontWeight.bold : FontWeight.w500,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

// --- 3. 视觉组件：概览胶囊 ---
class TeslaSummaryChip extends StatelessWidget {
  final String label;
  final int weight;

  const TeslaSummaryChip(
      {super.key, required this.label, required this.weight});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (weight) {
      case 3:
        color = const Color(0xFFE82127);
        break;
      case 2:
        color = const Color(0xFF005BC5);
        break;
      default:
        color = const Color(0xFF424242);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// --- 4. 主页面：垂直指挥官 ---
class AppQuestionArenaPage extends StatefulWidget {
  // ✅ 核心修复：还原参数，彻底解决 main.dart 和 navigation_service.dart 的 4 处报错
  final String subjectId;
  final String grade;
  final int questionLimit;

  const AppQuestionArenaPage({
    super.key,
    this.subjectId = 'math',
    this.grade = 'All',
    this.questionLimit = 10,
  });

  @override
  State<AppQuestionArenaPage> createState() => _AppQuestionArenaPageState();
}

class _AppQuestionArenaPageState extends State<AppQuestionArenaPage> {
  // ✅ 修改1：初始值设为 -1，保证全折叠态，整整齐齐
  int _expandedSectionIndex = -1;

  final Map<String, Map<String, int>> _configurationWeights = {
    '学科': {},
    '年级': {},
    '难度': {},
    '知识点': {},
    '语言': {},
    '题量': {}
  };

  final List<String> _subjects = ['数学', '数学奥林匹克', '物理', '化学'];
  final List<String> _grades = List.generate(12, (index) => '${index + 1}年级');
  final List<String> _difficulties = ['初级难度', '中级难度', '高级难度'];
  final List<String> _languages = ['中文', 'English', 'Español', '日本語'];
  final List<String> _limits = [
    '5',
    '15',
    '25',
    '35',
    '45',
    '55',
    '75',
    '90',
    '100'
  ];

  // 互锁逻辑（此处根据全量项目逻辑保留）
  List<String> _getDynamicKnowledgePoints() {
    String activeSubject = '数学';
    if (_configurationWeights['学科']!.isNotEmpty)
      activeSubject = _configurationWeights['学科']!.keys.first;
    String activeGrade = '3年级';
    if (_configurationWeights['年级']!.isNotEmpty)
      activeGrade = _configurationWeights['年级']!.keys.first;

    if (activeSubject == '数学') {
      if (activeGrade.contains('1') || activeGrade.contains('2'))
        return [
          'Counting (数数)',
          'Addition (加法)',
          'Subtraction (减法)',
          'Shapes (图形)'
        ];
      if (activeGrade == '3年级')
        return [
          'Addition (万以内加法)',
          'Geometry (四边形)',
          'Fractions (分数初步)',
          'Time (时分秒)',
          'Length (长度单位)'
        ];
      return [
        'Linear Equations (线性方程)',
        'Functions (函数)',
        'Geometry (几何)',
        'Probability (概率)',
        'Calculus (微积分基础)'
      ];
    }
    if (activeSubject == '数学奥林匹克')
      return [
        'Number Theory (数论)',
        'Combinatorics (组合数学)',
        'Logic (逻辑推理)',
        'Optimization (最优化)'
      ];
    if (activeSubject == '物理')
      return [
        'Mechanics (力学)',
        'Optics (光学)',
        'Thermodynamics (热学)',
        'Electromagnetism (电磁学)'
      ];
    if (activeSubject == '化学')
      return [
        'Periodic Table (周期表)',
        'Reactions (化学反应)',
        'Organic (有机化学)',
        'Acids & Bases (酸碱)'
      ];
    return ['General Knowledge (综合知识)'];
  }

  void _handleTileTap(String category, String item) {
    setState(() {
      int currentWeight = _configurationWeights[category]?[item] ?? 0;
      if (category == '题量' || category == '语言') {
        _configurationWeights[category]!.clear();
        if (currentWeight == 0) _configurationWeights[category]![item] = 1;
        return;
      }
      int nextWeight = (currentWeight + 1) % 4;
      if (nextWeight == 0)
        _configurationWeights[category]!.remove(item);
      else
        _configurationWeights[category]![item] = nextWeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFAFAFA),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  _buildAccordionSection(
                      0, '学科', Icons.category_outlined, _subjects),
                  const SizedBox(height: 12),
                  _buildAccordionSection(
                      1, '年级', Icons.school_outlined, _grades),
                  const SizedBox(height: 12),
                  _buildAccordionSection(
                      2, '难度', Icons.signal_cellular_alt, _difficulties),
                  const SizedBox(height: 12),
                  _buildAccordionSection(
                      3,
                      '知识点',
                      Icons.auto_awesome_mosaic_outlined,
                      _getDynamicKnowledgePoints()),
                  const SizedBox(height: 12),
                  _buildAccordionSection(4, '语言', Icons.language, _languages),
                  const SizedBox(height: 12),
                  _buildAccordionSection(
                      5, '题量', Icons.format_list_numbered, _limits),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      color: Colors.white,
      child: Row(
        children: [
          const Text('试卷配置',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          TeslaScaleWrapper(
            onTap: () => _showHelpDialog(context),
            child:
                const Icon(Icons.help_outline, size: 20, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionSection(
      int index, String title, IconData icon, List<String> items) {
    bool isExpanded = _expandedSectionIndex == index;
    Map<String, int> selectedItems = _configurationWeights[title] ?? {};

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isExpanded ? 0.08 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => _expandedSectionIndex = isExpanded ? -1 : index),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, size: 20, color: Colors.black87)),
                  const SizedBox(width: 12),
                  // ✅ 修改2：统一字体粗细，按照学科的标准设定
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                          children: selectedItems.entries
                              .map((e) => TeslaSummaryChip(
                                  label: e.key, weight: e.value))
                              .toList()),
                    ),
                  ),
                  Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black26),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: items.length,
                itemBuilder: (context, idx) {
                  String item = items[idx];
                  int weight = _configurationWeights[title]?[item] ?? 0;
                  return TeslaScaleWrapper(
                    onTap: () => _handleTileTap(title, item),
                    child: TeslaMatrixTile(label: item, weight: weight),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    bool isReady = _configurationWeights.values.any((map) => map.isNotEmpty);
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: TeslaScaleWrapper(
        onTap: () {
          if (isReady) {
            String subject = _configurationWeights['学科']?.keys.first ?? 'math';
            String rawGrade = _configurationWeights['年级']?.keys.first ?? '10';
            String grade = rawGrade.replaceAll(RegExp(r'[^0-9]'), '');
            int limit =
                int.tryParse(_configurationWeights['题量']?.keys.first ?? '10') ??
                    10;
            String topic =
                _configurationWeights['知识点']?.keys.join(', ') ?? 'General';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppFocusModePage(
                  subjectId: subject,
                  grade: grade,
                  questionLimit: limit,
                  topic: topic,
                ),
              ),
            );
          }
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              color: isReady ? Colors.black : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(14)),
          child: Center(
              child: Text(isReady ? '生成专属试卷' : '请先选择配置',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("权重计算方式",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildHelpRow(const Color(0xFF424242), "深灰：普通比重"),
                _buildHelpRow(const Color(0xFF005BC5), "蓝色：较高比重"),
                _buildHelpRow(const Color(0xFFE82127), "红色：核心考点"),
                const SizedBox(height: 20),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("知道了",
                        style: TextStyle(color: Colors.black))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
