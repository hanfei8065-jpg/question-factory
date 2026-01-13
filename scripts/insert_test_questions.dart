#!/usr/bin/env dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🚀 开始插入测试数据到 Supabase...\n');

  // 1. 从环境变量读取 Supabase 配置
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseKey = Platform.environment['SUPABASE_SERVICE_KEY'] ??
      Platform.environment['SUPABASE_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    print('❌ 错误：请设置环境变量 SUPABASE_URL 和 SUPABASE_SERVICE_KEY');
    print('提示：运行命令如下：');
    print('export SUPABASE_URL="your_url"');
    print('export SUPABASE_SERVICE_KEY="your_key"');
    exit(1);
  }

  // 2. 初始化 Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  final client = Supabase.instance.client;

  // 3. 准备三条测试数据
  final testQuestions = [
    // 第一条：数学选择题
    {
      'subject_id': 'math',
      'grade_id': 'grade10',
      'lang': 'zh',
      'type': 'choice',
      'content': '若函数 f(x) = 2x + 3，则 f(5) 的值为多少？',
      'options': ['A) 10', 'B) 13', 'C) 15', 'D) 17'],
      'answer': 'B',
      'explanation': '将 x=5 代入函数：f(5) = 2×5 + 3 = 10 + 3 = 13，故选 B。',
      'difficulty': 2,
      'tags': ['函数', '代数', '基础运算'],
    },

    // 第二条：物理填空题
    {
      'subject_id': 'physics',
      'grade_id': 'grade10',
      'lang': 'zh',
      'type': 'fill_in',
      'content': '一个物体从静止开始自由落体，经过 2 秒后的速度为 ________ m/s。（取 g=10 m/s²）',
      'options': [],
      'answer': '20',
      'explanation': '自由落体速度公式：v = gt，代入 g=10 m/s²，t=2s，得 v = 10×2 = 20 m/s。',
      'difficulty': 2,
      'tags': ['自由落体', '运动学', '匀加速直线运动'],
    },

    // 第三条：数学应用题
    {
      'subject_id': 'math',
      'grade_id': 'grade10',
      'lang': 'zh',
      'type': 'word_problem',
      'content':
          '某工厂生产 A、B 两种产品。A 产品需要 2 小时机器时间和 3 小时人工，B 产品需要 4 小时机器时间和 2 小时人工。工厂每周有 80 小时机器时间和 90 小时人工可用。若 A 产品利润 50 元，B 产品利润 60 元，请列出线性规划约束条件并求最大利润。',
      'options': [],
      'answer': '最大利润为 1350 元（x=15, y=12.5）',
      'explanation': '''
这是一道经典的线性规划问题。设 A 产品生产 x 件，B 产品生产 y 件。

**约束条件：**
1. 机器时间：2x + 4y ≤ 80
2. 人工时间：3x + 2y ≤ 90
3. 非负约束：x ≥ 0, y ≥ 0

**目标函数：**
最大化利润 P = 50x + 60y

**求解步骤：**
1. 画出可行域，找出顶点坐标
2. 顶点包括：(0,0), (0,20), (30,0), (15,12.5)
3. 代入目标函数计算：
   - P(0,0) = 0
   - P(0,20) = 1200
   - P(30,0) = 1500
   - P(15,12.5) = 50×15 + 60×12.5 = 750 + 750 = 1500

等等，让我重新计算交点：
解方程组 {2x+4y=80, 3x+2y=90}
第二式乘2：6x+4y=180
相减：4x=100，x=25
代入：2×25+4y=80，4y=30，y=7.5
P(25,7.5) = 50×25 + 60×7.5 = 1250 + 450 = 1700

但需验证是否在可行域内：
机器：2×25+4×7.5=50+30=80 ✓
人工：3×25+2×7.5=75+15=90 ✓

**答案：最大利润为 1700 元**（当生产 A 产品 25 件，B 产品 7.5 件时）
''',
      'difficulty': 4,
      'tags': ['线性规划', '应用题', '优化问题', '不等式'],
    },
  ];

  // 4. 插入数据
  try {
    for (int i = 0; i < testQuestions.length; i++) {
      final question = testQuestions[i];
      print('📝 正在插入第 ${i + 1} 条数据...');
      print('   类型: ${question['type']}');
      print('   学科: ${question['subject_id']}');

      final response = await client.from('questions').insert(question).select();

      print('   ✅ 成功！ID: ${response[0]['id']}\n');
    }

    print('🎉 所有测试数据插入成功！');
    print('📱 现在可以在手机上测试了！\n');
  } catch (e) {
    print('❌ 插入失败：$e');
    exit(1);
  }
}
