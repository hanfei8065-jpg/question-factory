-- ============================================
-- 题库工厂 V11.0 字段迁移脚本 (基于真实列名修正版)
-- ============================================

-- 1. 确保标准字段存在
ALTER TABLE questions ADD COLUMN IF NOT EXISTS subject_id text;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS grade_id text;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS type text;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS lang text;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS explanation text;

-- 2. 数据迁移：将旧的 grade 迁移到 grade_id (修正自实测列名: grade)
UPDATE questions 
SET grade_id = CASE 
  WHEN grade ~ '^\d+$' THEN 'grade' || grade  -- "10" -> "grade10"
  WHEN grade ~ 'Grade \d+' THEN 'grade' || (regexp_match(grade, '\d+'))[1]
  WHEN grade ~ 'grade\d+' THEN grade
  ELSE 'grade10'
END
WHERE grade IS NOT NULL AND (grade_id IS NULL OR grade_id = '');

-- 3. 数据迁移：将旧的 subject 迁移到 subject_id (修正自实测列名: subject)
UPDATE questions 
SET subject_id = LOWER(subject)
WHERE subject IS NOT NULL AND (subject_id IS NULL OR subject_id = '');

-- 4. 补齐题型和语言 (V11.0 定稿标准)
UPDATE questions SET type = 'choice' WHERE type IS NULL OR type = '';
UPDATE questions SET lang = 'zh' WHERE lang IS NULL OR lang = '';

-- 5. 补齐解析 (利用你的 answer 字段)
UPDATE questions 
SET explanation = '正确答案是 ' || answer || '。'
WHERE (explanation IS NULL OR explanation = '') AND answer IS NOT NULL;

-- 6. 验证迁移结果
SELECT 
  COUNT(*) as total_count,
  COUNT(subject_id) as aligned_subject,
  COUNT(grade_id) as aligned_grade
FROM questions;