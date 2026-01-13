-- 在 Supabase Dashboard 的 SQL Editor 中运行此脚本
-- 插入 3 条测试数据到 questions 表
-- 注意：使用 subject_id 和 grade_id 字段名（App 代码要求）

-- 先删除之前插入的测试数据（如果存在）
DELETE FROM questions WHERE grade = 'grade10' AND created_at > NOW() - INTERVAL '1 hour';

-- 问题 1: 数学选择题
INSERT INTO questions (
  subject_id, 
  grade_id, 
  type,
  lang, 
  content, 
  options, 
  answer, 
  explanation, 
  difficulty, 
  tags
) VALUES (
  'math',
  'grade10',
  'choice',
  'zh',
  '下列哪个函数是二次函数？',
  '["y = 2x + 1", "y = x² + 3x + 2", "y = 1/x", "y = √x"]'::jsonb,
  'B',
  '二次函数的标准形式为 y = ax² + bx + c（a ≠ 0），选项B符合这个定义。',
  '2',
  '["函数", "二次函数", "基础概念"]'::jsonb
);

-- 问题 2: 物理填空题
INSERT INTO questions (
  subject_id, 
  grade_id, 
  type,
  lang, 
  content, 
  options, 
  answer, 
  explanation, 
  difficulty, 
  tags
) VALUES (
  'physics',
  'grade10',
  'fill_in',
  'zh',
  '一个物体做匀速直线运动，在5秒内运动了100米，它的速度是___米/秒。',
  '[]'::jsonb,
  '20',
  '速度 v = 路程 s / 时间 t = 100米 / 5秒 = 20米/秒',
  '1',
  '["运动学", "匀速直线运动", "速度计算"]'::jsonb
);

-- 问题 3: 数学应用题
INSERT INTO questions (
  subject_id, 
  grade_id, 
  type,
  lang, 
  content, 
  options, 
  answer, 
  explanation, 
  difficulty, 
  tags
) VALUES (
  'math',
  'grade10',
  'word_problem',
  'zh',
  '某工厂要生产两种产品A和B。每件产品A需要2小时加工，每件产品B需要3小时加工。工厂每天最多有18小时的加工时间。生产一件产品A可获利100元，生产一件产品B可获利150元。如果要使利润最大化，应该如何安排生产？',
  '[]'::jsonb,
  '生产6件产品A或者3件产品A和4件产品B',
  E'设生产x件产品A，y件产品B。\n约束条件：\n- 2x + 3y ≤ 18（时间约束）\n- x ≥ 0, y ≥ 0（数量非负）\n\n目标函数：利润 P = 100x + 150y\n\n这是一个线性规划问题。通过画出可行域并检查顶点：\n- (0, 0): P = 0\n- (9, 0): P = 900\n- (0, 6): P = 900\n- (3, 4): P = 300 + 600 = 900\n\n最优解：可以选择生产9件A，或者6件B，或者3件A和4件B，利润都是900元。',
  '4',
  '["线性规划", "应用题", "最优化"]'::jsonb
);

-- 验证插入结果
SELECT 
  id,
  subject_id,
  grade_id,
  type,
  lang,
  substring(content, 1, 50) as content_preview,
  difficulty,
  tags,
  created_at
FROM questions 
WHERE grade_id = 'grade10'
ORDER BY created_at DESC
LIMIT 3;
