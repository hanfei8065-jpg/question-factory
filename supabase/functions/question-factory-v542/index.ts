import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // 1. 定义“顶级理科思维”提示词
  const SYSTEM_PROMPT = `你是一位硅谷顶级 STEM 教育专家，擅长用“第一性原理”和“多邻国式”低痛点逻辑设计题目。
  任务：生成 30 道【${req.headers.get('subject')}】选择题。
  要求：
  - 核心逻辑：仿照公文式（KUMON），题干极简，每道题只考察一个微小逻辑点，严禁出现复杂计算。
  - 启发解析：解析第一步必须是一个引导性问题，激发用户的 Bingo Moment，让他们自己发现答案的逻辑。
  - 格式规范：所有公式必须用 LaTeX ($...$)。只输出 JSON 数组，严禁废话。`

  try {
    // 2. 调用 DeepSeek (此处模拟 30 题循环处理)
    const questionsBatch = []; // 这里假设你已经对接了 DeepSeek API 返回的 30 道题数组

    for (const q of questionsBatch) {
      let finalImageUrl = null;

      // 3. 处理图片逻辑：如果 AI 建议有图，存入 Storage
      if (q.is_image_question && q.svg_code) {
        const fileName = `logic_${Date.now()}_${Math.random()}.svg`;
        const { data } = await supabase.storage
          .from('question-images')
          .upload(fileName, new Blob([q.svg_code], { type: 'image/svg+xml' }));
        
        if (data) {
          const { data: { publicUrl } } = supabase.storage.from('question-images').getPublicUrl(fileName);
          finalImageUrl = publicUrl;
        }
      }

      // 4. 写入数据库
      await supabase.from('questions').insert({
        content: q.content,
        options: q.options,
        answer: q.answer,
        explanation: q.explanation,
        svg_diagram: finalImageUrl, // 仅存链接，不占数据库空间
        is_image_question: !!finalImageUrl,
        grade: q.grade,
        subject: q.subject,
        difficulty: q.difficulty,
        timer_seconds: 60
      });
    }

    return new Response(JSON.stringify({ status: '30 questions processed' }), { headers: { "Content-Type": "application/json" } });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
})