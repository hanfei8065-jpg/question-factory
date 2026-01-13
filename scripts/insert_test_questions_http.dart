import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  // 从环境变量读取配置
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ??
      'https://kznfpmdqyzfpvnexlbsu.supabase.co';
  final supabaseServiceKey = Platform.environment['SUPABASE_SERVICE_KEY'];

  if (supabaseServiceKey == null) {
    print('❌ 错误：请设置 SUPABASE_SERVICE_KEY 环境变量');
    print('示例：');
    print('export SUPABASE_SERVICE_KEY=your-service-key');
    exit(1);
  }

  try {
    // 准备测试数据
    final testQuestions = [
      // 问题 1: 数学选择题
      {
        'subject_id': 'math',
        'grade_id': 'grade10',
        'type': 'choice',
        'lang': 'zh',
        'content': '下列哪个函数是二次函数？',
        'options': ['y = 2x + 1', 'y = x² + 3x + 2', 'y = 1/x', 'y = √x'],
        'answer': 'B',
        'explanation': '二次函数的标准形式为 y = ax² + bx + c（a ≠ 0），选项B符合这个定义。',
        'difficulty': 2,
        'tags': ['函数', '二次函数', '基础概念'],
      },

      // 问题 2: 物理填空题
      {
        'subject_id': 'physics',
        'grade_id': 'grade10',
        'type': 'fill_in',
        'lang': 'zh',
        'content': '一个物体做匀速直线运动，在5秒内运动了100米，它的速度是___米/秒。',
        'options': [],
        'answer': '20',
        'explanation': '速度 v = 路程 s / 时间 t = 100米 / 5秒 = 20米/秒',
        'difficulty': 1,
        'tags': ['运动学', '匀速直线运动', '速度计算'],
      },

      // 问题 3: 数学应用题
      {
        'subject_id': 'math',
        'grade_id': 'grade10',
        'type': 'word_problem',
        'lang': 'zh',
        'content':
            '某工厂要生产两种产品A和B。每件产品A需要2小时加工，每件产品B需要3小时加工。工厂每天最多有18小时的加工时间。生产一件产品A可获利100元，生产一件产品B可获利150元。如果要使利润最大化，应该如何安排生产？',
        'options': [],
        'answer': '生产6件产品A或者3件产品A和4件产品B',
        'explanation': '''
设生产x件产品A，y件产品B。
约束条件：
- 2x + 3y ≤ 18（时间约束）
- x ≥ 0, y ≥ 0（数量非负）

目标函数：利润 P = 100x + 150y

这是一个线性规划问题。通过画出可行域并检查顶点：
- (0, 0): P = 0
- (9, 0): P = 900
- (0, 6): P = 900
- (3, 4): P = 300 + 600 = 900

最优解：可以选择生产9件A，或者6件B，或者3件A和4件B，利润都是900元。
        ''',
        'difficulty': 4,
        'tags': ['线性规划', '应用题', '最优化'],
      },
    ];

    print('🚀 开始插入测试数据...\n');

    final client = HttpClient();
    final headers = {
      'apikey': supabaseServiceKey,
      'Authorization': 'Bearer $supabaseServiceKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    };

    for (var i = 0; i < testQuestions.length; i++) {
      final question = testQuestions[i];
      print('📝 插入问题 ${i + 1}/${testQuestions.length}...');
      print('   类型: ${question['type']}');
      print('   科目: ${question['subject_id']}');
      print('   年级: ${question['grade_id']}');

      try {
        final uri = Uri.parse('$supabaseUrl/rest/v1/questions');
        final request = await client.postUrl(uri);

        headers.forEach((key, value) {
          request.headers.add(key, value);
        });

        request.write(jsonEncode(question));

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print('   ✅ 成功插入\n');
        } else {
          print('   ❌ 插入失败: ${response.statusCode}');
          print('   响应: $responseBody\n');
        }
      } catch (e) {
        print('   ❌ 错误: $e\n');
      }
    }

    client.close();
    print('✅ 测试数据插入完成！');
    print('\n📱 现在可以在手机上测试了：');
    print('   1. 进入题库页面');
    print('   2. 选择高一、数学/物理、中文');
    print('   3. 选择不同题型（选择题/填空题/应用题）');
    print('   4. 查看问题显示是否正常');
  } catch (e) {
    print('❌ 发生错误: $e');
    exit(1);
  }
}
