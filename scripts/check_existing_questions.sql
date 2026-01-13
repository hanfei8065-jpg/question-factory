-- 检查数据库中已有的题目分布情况
-- 在 Supabase SQL Editor 中运行

-- 1. 查看所有不同的 subject_id 值
SELECT DISTINCT subject_id, COUNT(*) as count
FROM questions
GROUP BY subject_id
ORDER BY count DESC;

-- 2. 查看所有不同的 grade_id 值
SELECT DISTINCT grade_id, COUNT(*) as count
FROM questions
GROUP BY grade_id
ORDER BY count DESC;

-- 3. 查看所有不同的 type 值
SELECT DISTINCT type, COUNT(*) as count
FROM questions
GROUP BY type
ORDER BY count DESC;

-- 4. 查看所有不同的 lang 值
SELECT DISTINCT lang, COUNT(*) as count
FROM questions
GROUP BY lang
ORDER BY count DESC;

-- 5. 查看前10条记录的完整信息
SELECT 
  id,
  subject_id,
  grade_id,
  type,
  lang,
  difficulty,
  substring(content, 1, 30) as content_preview,
  created_at
FROM questions
ORDER BY created_at DESC
LIMIT 10;
