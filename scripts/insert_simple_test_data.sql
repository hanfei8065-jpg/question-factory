-- 简单直接的测试数据插入脚本
-- 严格遵守字段标准：subject_id, grade_id, type, lang
-- 年级格式：grade10 (不是 Grade 10 或 Grade 9-10)
-- 学科名：小写 math, physics, chemistry

-- 删除旧的测试数据
DELETE FROM questions WHERE grade_id = 'grade10' AND created_at > NOW() - INTERVAL '2 hours';

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

-- 问题 2: 物理应用题
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
  'word_problem',
  'zh',
  '一个物体从静止开始做匀加速直线运动，加速度为2 m/s²，求5秒后的速度是多少？',
  '[]'::jsonb,
  '10 m/s',
  '根据速度公式 v = v₀ + at，其中 v₀ = 0，a = 2 m/s²，t = 5s，所以 v = 0 + 2×5 = 10 m/s',
  '1',
  '["运动学", "匀加速运动", "速度计算"]'::jsonb
);

-- 问题 3: 数学填空题
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
  'fill_in',
  'zh',
  '方程 x² - 5x + 6 = 0 的两个根是 x₁ = ___ 和 x₂ = ___',
  '[]'::jsonb,
  'x₁ = 2, x₂ = 3',
  '因式分解：x² - 5x + 6 = (x - 2)(x - 3) = 0，所以 x₁ = 2，x₂ = 3',
  '2',
  '["一元二次方程", "因式分解", "求根公式"]'::jsonb
);

-- 验证插入结果
SELECT 
  id,
  subject_id,
  grade_id,
  type,
  lang,
  substring(content, 1, 30) as content_preview,
  difficulty,
  created_at
FROM questions 
WHERE grade_id = 'grade10' AND subject_id IN ('math', 'physics')
ORDER BY created_at DESC
LIMIT 5;
