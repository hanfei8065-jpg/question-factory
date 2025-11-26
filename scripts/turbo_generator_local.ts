import dotenv from 'dotenv';
dotenv.config();
import { createClient } from '@supabase/supabase-js';
import pLimit from 'p-limit';
import axios from 'axios';
import ora from 'ora';
import chalk from 'chalk';
import { z } from 'zod';

// 环境变量
const SUPABASE_URL = process.env.SUPABASE_URL!;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!;
// 默认用 DeepSeek 或 OpenAI，根据你的 .env 决定
const LLM_API_URL = process.env.LLM_API_URL || 'https://api.openai.com/v1/chat/completions'; 
const LLM_API_KEY = process.env.LLM_API_KEY!;
// 增加模型变量，防止硬编码。如果是DeepSeek请在env设为 deepseek-chat
const LLM_MODEL = process.env.LLM_MODEL || 'gpt-4o-mini'; // 建议用 mini 省钱，或者 gpt-4o

// Supabase 客户端（Service Role）
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// 题目Schema
const QuestionSchema = z.object({
  problem_text: z.string(),
  options: z.array(z.string()),
  correct_answer: z.string(),
  subject: z.string(),
  grade_level: z.string(),
  difficulty: z.string(),
  knowledge_point: z.string(),
});

// Math Topics (你可以后续扩展这个列表)
const mathTopics = [
  'Algebra: Linear Equations',
  'Algebra: Quadratic Equations',
  'Geometry: Triangles',
  'Geometry: Circles',
  'Calculus: Derivatives',
  'Calculus: Integrals',
  'Statistics: Probability',
  'Trigonometry: Sine & Cosine',
  'Functions: Domain & Range',
  'Vectors: Dot Product',
];

const limit = pLimit(5); // 降低一点并发，防止 API Rate Limit
const QUESTIONS_PER_CALL = 5;
const TOPICS_COUNT = mathTopics.length; // 10
// 目标 10,000 题。 
// 每轮循环生成 10个主题 * 5题 = 50题。
// 需要循环 200 次。 (200 * 50 = 10,000)
const TOTAL_BATCHES = 200; 

const spinner = ora('正在批量生成题目...').start();
let generated = 0;
let totalErrors = 0;

// 暴力提取 JSON 数组的函数
function extractJsonArray(str: string): any[] {
  try {
    // 1. 尝试直接解析
    return JSON.parse(str);
  } catch (e) {
    // 2. 如果失败，使用正则表达式寻找最外层的 [ ... ]
    const match = str.match(/\[[\s\S]*\]/);
    if (match) {
      try {
        return JSON.parse(match[0]);
      } catch (e2) {
        // 如果还不行，可能是 Markdown 代码块干扰，尝试去掉 ```json
        const clean = match[0].replace(/```json/g, '').replace(/```/g, '');
        try {
           return JSON.parse(clean);
        } catch (e3) {
           console.log(chalk.red("无法解析的内容片段:", str.substring(0, 100) + "..."));
           return [];
        }
      }
    }
    return [];
  }
}

// 核心生成函数（带最大重试限制）

async function generateQuestions(topic: string, grade: string, difficulty: string, retryCount = 0) {
  if (retryCount > 3) {
    // 超过3次彻底放弃，打印个日志就行，别抛错中断整个脚本
    console.log(chalk.red(`❌ Batch Failed strictly: ${topic}`));
    return; 
  }

  // 优化后的 Prompt：极其强硬
  const prompt = `You are a strict JSON generator API. 
Task: Generate 5 multiple-choice math questions for Grade ${grade} students on the topic "${topic}". Difficulty: ${difficulty}.
Output Requirements:
1. ONLY output a valid JSON array.
2. NO preamble, NO markdown formatting (no \`\`\`), NO explanation text.
3. Structure: [{"problem_text": "...", "options": ["A", "B", "C", "D"], "correct_answer": "...", "subject": "Math", "grade_level": "${grade}", "difficulty": "${difficulty}", "knowledge_point": "${topic}"}]`;

  try {
    const res = await axios.post(LLM_API_URL, {
      model: 'deepseek-chat', // 确认这里是 deepseek-chat
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.5, // 降低温度，让它更理性，不胡乱发挥
      stream: false 
    }, {
      headers: {
        'Authorization': `Bearer ${LLM_API_KEY}`,
        'Content-Type': 'application/json',
      },
      timeout: 60000,
    });

    // 健壮性检查：DeepSeek 有时会返回空 choices
    const content = res.data.choices?.[0]?.message?.content;
    if (!content) {
        throw new Error("DeepSeek returned empty content");
    }

    // 使用上面的暴力提取函数
    const questions = extractJsonArray(content);

    if (!questions || questions.length === 0) {
       throw new Error("Parsed JSON is empty or invalid");
    }

    // Zod 校验 (保持不变)
    const validQuestions = questions.filter(q => QuestionSchema.safeParse(q).success);

    if (validQuestions.length === 0) {
      throw new Error("No questions passed Schema validation");
    }

    // 入库 (保持不变)
    const { error } = await supabase.from('questions').insert(validQuestions);
    if (error) throw error;

    generated += validQuestions.length;
    // 用 console.log 代替 spinner 以避免 logs 混乱
    console.log(chalk.green(`✅ [SUCCESS] ${topic} (+${validQuestions.length}) | Total: ${generated}`));

  } catch (err: any) {
    // 打印简短错误信息，继续重试
    console.log(chalk.yellow(`⚠️ Retry (${retryCount+1}/3) for ${topic}: ${err.message}`));
    await new Promise(r => setTimeout(r, 2000)); // 休息2秒再试
    return await generateQuestions(topic, grade, difficulty, retryCount + 1);
  }
}

// 在 main 函数前添加自动化检查和详细日志
console.log(chalk.yellow('Supabase URL:'), SUPABASE_URL);
console.log(chalk.yellow('Supabase Service Role Key:'), SUPABASE_SERVICE_ROLE_KEY.slice(0, 10) + '...');
console.log(chalk.yellow('LLM API URL:'), LLM_API_URL);
console.log(chalk.yellow('LLM Model:'), LLM_MODEL);
console.log(chalk.yellow('目标表名: questions'));

async function main() {
  console.log(chalk.blue(`🚀 开始生成任务... 目标: ${TOTAL_BATCHES * TOPICS_COUNT * QUESTIONS_PER_CALL} 题`));
  console.log(chalk.blue(`📡 模型: ${LLM_MODEL}`));
  
  for (let batch = 0; batch < TOTAL_BATCHES; batch++) {
    await Promise.all(
      mathTopics.map(topic =>
        limit(() => generateQuestions(topic, 'Grade 10', 'Medium'))
      )
    );
    // 每完成一轮大循环，打印一下进度
    if (batch % 5 === 0) {
      console.log(chalk.gray(`\nBatch ${batch}/${TOTAL_BATCHES} 完成...`));
    }
  }
  spinner.succeed(chalk.green(`\n🎉 任务结束！总生成: ${generated} | 总失败: ${totalErrors}`));
}

main();
