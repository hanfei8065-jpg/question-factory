import '../models/question.dart';

class QuestionGenerator {
  static List<Question> generateMathQuestions() {
    final questions = <Question>[];

    // 方程题
    questions.addAll([
      Question(
        id: 'math_eq_001',
        content: r'求解方程：$2x + 3 = 11$',
        options: ['x = 3', 'x = 4', 'x = 5', 'x = 6'],
        answer: 'x = 4',
        explanation: r'''解法步骤：
1) $2x + 3 = 11$
2) $2x = 11 - 3$
3) $2x = 8$
4) $x = 4$''',
        subject: Subject.math,
        grade: 7,
        type: QuestionType.choice,
        difficulty: 1,
        tags: ['一次方程', '解方程'],
      ),
      Question(
        id: 'math_eq_002',
        content: r'化简并求解：$(x + 2)(x - 3) = 0$',
        options: [
          r'$x = -2$ 或 $x = 3$',
          r'$x = 2$ 或 $x = 3$',
          r'$x = -2$ 或 $x = -3$',
          r'$x = 2$ 或 $x = -3$',
        ],
        answer: r'$x = -2$ 或 $x = 3$',
        explanation: r'''解法步骤：
1) 使用因式分解法
2) 当 $x + 2 = 0$ 时，$x = -2$
3) 当 $x - 3 = 0$ 时，$x = 3$
4) 所以，$x = -2$ 或 $x = 3$''',
        subject: Subject.math,
        grade: 8,
        type: QuestionType.choice,
        difficulty: 2,
        tags: ['二次方程', '因式分解', '零点'],
      ),
    ]);

    // 函数题
    questions.addAll([
      Question(
        id: 'math_func_001',
        content: r'函数 $f(x) = 2x + 1$ 的图像是：',
        options: [
          '向右上方倾斜的直线，过点(0,1)',
          '向右下方倾斜的直线，过点(0,1)',
          '向右上方倾斜的直线，过点(1,0)',
          '向右下方倾斜的直线，过点(1,0)',
        ],
        answer: '向右上方倾斜的直线，过点(0,1)',
        explanation: r'''分析：
1) 这是一次函数
2) 斜率为2（正数，所以向右上方倾斜）
3) 当x=0时，f(0)=1，所以过点(0,1)''',
        subject: Subject.math,
        grade: 8,
        type: QuestionType.choice,
        difficulty: 2,
        tags: ['一次函数', '函数图像', '斜率'],
      ),
    ]);

    // 几何题
    questions.addAll([
      Question(
        id: 'math_geo_001',
        content: r'在直角三角形ABC中，$\angle C = 90°$，$\sin A = 0.6$，则 $\cos A$ 等于：',
        options: ['0.6', '0.8', '0.4', '0.5'],
        answer: '0.8',
        explanation: r'''解法：
1) 在直角三角形中，$\sin^2 A + \cos^2 A = 1$
2) 已知 $\sin A = 0.6$
3) 代入得：$0.6^2 + \cos^2 A = 1$
4) $0.36 + \cos^2 A = 1$
5) $\cos^2 A = 0.64$
6) $\cos A = 0.8$（取正值，因为A为锐角）''',
        subject: Subject.math,
        grade: 9,
        type: QuestionType.choice,
        difficulty: 3,
        tags: ['三角函数', '勾股定理', '直角三角形'],
      ),
    ]);

    return questions;
  }

  static List<Question> generatePhysicsQuestions() {
    final questions = <Question>[];

    // 力学题
    questions.addAll([
      Question(
        id: 'phys_force_001',
        content: '一个物体在光滑水平面上被施加一个大小为10N的水平力，物体质量为2kg，则物体的加速度为：',
        options: ['2 m/s²', '5 m/s²', '10 m/s²', '20 m/s²'],
        answer: '5 m/s²',
        explanation: '''根据牛顿第二定律：
1) F = ma
2) 10 = 2 × a
3) a = 5 m/s²''',
        subject: Subject.physics,
        grade: 8,
        type: QuestionType.choice,
        difficulty: 2,
        tags: ['牛顿定律', '力', '加速度'],
      ),
    ]);

    // 电学题
    questions.addAll([
      Question(
        id: 'phys_elec_001',
        content: '并联电路中，总电阻R与各分支电阻R₁、R₂的关系是：',
        options: [
          '1/R = 1/R₁ + 1/R₂',
          'R = R₁ + R₂',
          'R = R₁R₂',
          '1/R = R₁ + R₂',
        ],
        answer: '1/R = 1/R₁ + 1/R₂',
        explanation: '''并联电路的特点：
1) 电压相等
2) 总电流等于分支电流之和
3) 推导得到：1/R = 1/R₁ + 1/R₂''',
        subject: Subject.physics,
        grade: 9,
        type: QuestionType.choice,
        difficulty: 3,
        tags: ['电路', '并联', '电阻'],
      ),
    ]);

    return questions;
  }

  static List<Question> generateChemistryQuestions() {
    final questions = <Question>[];

    // 元素题
    questions.addAll([
      Question(
        id: 'chem_elem_001',
        content: '在周期表中，原子序数为11的元素是：',
        options: ['钾(K)', '钠(Na)', '镁(Mg)', '铝(Al)'],
        answer: '钠(Na)',
        explanation: '''分析：
1) 原子序数11的元素在第3周期，第IA族
2) 这个位置是钠元素
3) 元素符号：Na''',
        subject: Subject.chemistry,
        grade: 9,
        type: QuestionType.choice,
        difficulty: 1,
        tags: ['元素', '周期表', '原子序数'],
      ),
    ]);

    // 化学反应题
    questions.addAll([
      Question(
        id: 'chem_reac_001',
        content: '下列反应中，属于置换反应的是：',
        options: [
          'Zn + 2HCl = ZnCl₂ + H₂↑',
          '2H₂ + O₂ = 2H₂O',
          'CaCO₃ = CaO + CO₂↑',
          'NaOH + HCl = NaCl + H₂O',
        ],
        answer: 'Zn + 2HCl = ZnCl₂ + H₂↑',
        explanation: '''分析：
1) 置换反应：单质置换化合物中的某一元素
2) Zn置换出H₂，符合置换反应特征
3) 其他选项分别是：燃烧反应、分解反应、复分解反应''',
        subject: Subject.chemistry,
        grade: 9,
        type: QuestionType.choice,
        difficulty: 2,
        tags: ['化学反应', '置换反应', '反应类型'],
      ),
    ]);

    return questions;
  }

  // 生成所有题目
  static List<Question> generateAllQuestions() {
    final allQuestions = <Question>[];
    allQuestions.addAll(generateMathQuestions());
    allQuestions.addAll(generatePhysicsQuestions());
    allQuestions.addAll(generateChemistryQuestions());
    return allQuestions;
  }
}
