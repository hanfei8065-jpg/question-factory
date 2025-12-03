-- ==========================================
-- Visual Question Bank: Add SVG Diagram Support
-- ==========================================
-- Run this in Supabase SQL Editor
-- Project: learnest-production

-- Add svg_diagram column to questions table
ALTER TABLE questions 
ADD COLUMN svg_diagram TEXT;

-- Add comment for documentation
COMMENT ON COLUMN questions.svg_diagram IS 'SVG XML code for visual diagrams (geometry, mechanics, etc). Used by flutter_svg to render images.';

-- Verify column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'questions' 
  AND column_name = 'svg_diagram';
