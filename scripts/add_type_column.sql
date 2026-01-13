-- 方案1：如果 questions 表没有 type 列，先添加这一列
-- 在 Supabase SQL Editor 中运行

-- 检查是否已有 type 列
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'questions' AND column_name = 'type';

-- 如果上面查询返回空，说明没有 type 列，运行下面的命令添加：
ALTER TABLE questions ADD COLUMN IF NOT EXISTS type text;

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_questions_type ON questions(type);

-- 更新之前插入的测试数据，从 tags 中提取 type
UPDATE questions 
SET type = 'choice'
WHERE tags::text LIKE '%choice%' AND type IS NULL;

UPDATE questions 
SET type = 'fill_in'
WHERE tags::text LIKE '%fill_in%' AND type IS NULL;

UPDATE questions 
SET type = 'word_problem'
WHERE tags::text LIKE '%word_problem%' AND type IS NULL;

-- 验证
SELECT id, subject_id, grade_id, type, tags 
FROM questions 
WHERE grade_id = 'grade10'
LIMIT 5;
