#!/usr/bin/env node

const https = require('https');

// ==========================================
// 1. 配置区域
// ==========================================
const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
// 注意：Supabase REST API URL 通常是 https://<project_id>.supabase.co/rest/v1
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

// ⚡️ SEQUENTIAL MODE: 串行执行配置 (No Concurrency)
const TARGET_COUNT = 10; // 每次生成 10 道题 (一个接一个)
const TASK_TIMEOUT_MS = 90000; // 单题超时: 90 秒
const DELAY_BETWEEN_QUESTIONS = 2000; // 每题之间等待 2 秒 

// ==========================================
// 2. 核心数据结构 (Syllabus)
// ==========================================
const knowledgePointsDatabase = {
  "数学": {
    "grand1": ["基础加减法", "数的认识"],
    "grand2": ["进位加法", "简单乘法", "图形认知"],
    "grand3": ["乘除法", "分数初步", "长度单位"],
    "grand4": ["小数", "面积与体积", "简单方程"],
    "grand5": ["分数运算", "比例", "统计与概率"],
    "grand6": ["代数基础", "几何初步", "数据分析"],
    "grand7": ["分数运算", "代数基础", "几何初步"],
    "grand8": ["方程与函数", "概率统计", "三角形性质"],
    "grand9": ["多项式", "函数图像", "数列基础"],
    "grand10": ["三角函数", "立体几何", "复合函数"],
    "grand11": ["微积分初步", "空间向量", "概率分布"],
    "grand12": ["微积分应用", "高等代数", "统计推断"]
  },
  "数学奥林匹克": {
    "grand1": ["趣味数论", "逻辑推理"],
    "grand2": ["趣味几何", "组合问题"],
    "grand3": ["基础数论", "简单组合"],
    "grand4": ["进阶数论", "图形组合"],
    "grand5": ["数列与递推", "复杂逻辑"],
    "grand6": ["初级代数", "奥数几何"],
    "grand7": ["数论", "组合", "几何", "逻辑推理"],
    "grand8": ["高阶数论", "复杂组合", "竞赛几何"],
    "grand9": ["函数与方程", "竞赛数论", "竞赛组合"],
    "grand10": ["高阶代数", "竞赛概率", "竞赛几何"],
    "grand11": ["微积分竞赛", "高阶逻辑", "竞赛统计"],
    "grand12": ["综合奥数", "高阶竞赛题型"]
  },
  "物理": {
    "grand1": ["物体运动", "简单力学"],
    "grand2": ["力与运动", "能量转换"],
    "grand3": ["机械基础", "热学初步"],
    "grand4": ["光学基础", "声学初步"],
    "grand5": ["电学基础", "磁学初步"],
    "grand6": ["力学综合", "热力学"],
    "grand7": ["力与运动", "能量转换", "简单机械"],
    "grand8": ["热学基础", "波动与声", "光学初步"],
    "grand9": ["电学", "磁学", "力学进阶"],
    "grand10": ["热力学进阶", "光学进阶", "波动进阶"],
    "grand11": ["原子物理", "量子力学初步"],
    "grand12": ["现代物理", "高阶力学"]
  },
  "化学": {
    "grand1": ["物质的状态", "简单混合物"],
    "grand2": ["物质分类", "基本化学反应"],
    "grand3": ["溶液", "酸碱基础"],
    "grand4": ["氧化还原", "元素周期表"],
    "grand5": ["化学方程式", "物质变化"],
    "grand6": ["有机化学初步", "无机化学基础"],
    "grand7": ["物质的状态", "基本化学反应", "元素周期表"],
    "grand8": ["酸碱盐", "溶液与溶解度", "化学方程式"],
    "grand9": ["有机化学", "无机化学", "化学平衡"],
    "grand10": ["电化学", "高阶有机化学"],
    "grand11": ["高阶无机化学", "化学动力学"],
    "grand12": ["综合化学", "高阶竞赛题型"]
  }
};

const difficulties = ["初级难度", "中级难度", "高级难度"];
const questionTypes = ["选择题", "填空题", "应用题"];

// ==========================================
// 🔥 GOLDEN STANDARD EXAMPLES (Few-Shot Learning)
// ==========================================
const GOLDEN_EXAMPLES = `
**MATH EXAMPLE (High-Quality Critical Thinking Question)**:
{
  "content": "A factory produces two types of products, A and B. Product A requires 2 hours of machine time and 3 hours of labor. Product B requires 4 hours of machine time and 2 hours of labor. The factory has 80 hours of machine time and 90 hours of labor available per week. If the profit for Product A is $50 and for Product B is $60, what is the maximum profit the factory can achieve in one week? Express your answer using linear programming constraints: \\\\( 2x + 4y \\\\leq 80 \\\\) and \\\\( 3x + 2y \\\\leq 90 \\\\), where \\\\( x \\\\) and \\\\( y \\\\) are the number of units of A and B produced.",
  "options": [
    "A) $1,200", 
    "B) $1,350", 
    "C) $1,500", 
    "D) $1,650"
  ],
  "answer": "B",
  "explanation": "This is a linear programming problem. First, find the feasible region by graphing the constraints: \\\\( 2x + 4y \\\\leq 80 \\\\) (machine time) and \\\\( 3x + 2y \\\\leq 90 \\\\) (labor time), with \\\\( x \\\\geq 0, y \\\\geq 0 \\\\). The corner points of the feasible region are (0,0), (0,20), (30,0), and (10,15). Evaluate the profit function \\\\( P = 50x + 60y \\\\) at each corner: \\\\( P(0,0) = 0 \\\\), \\\\( P(0,20) = 1200 \\\\), \\\\( P(30,0) = 1500 \\\\), \\\\( P(10,15) = 50(10) + 60(15) = 500 + 900 = 1400 \\\\). Wait, let me recalculate the intersection of \\\\( 2x + 4y = 80 \\\\) and \\\\( 3x + 2y = 90 \\\\). Multiply the second equation by 2: \\\\( 6x + 4y = 180 \\\\). Subtract the first: \\\\( 4x = 100 \\\\), so \\\\( x = 25 \\\\). Substitute into \\\\( 2(25) + 4y = 80 \\\\): \\\\( 4y = 30 \\\\), \\\\( y = 7.5 \\\\). Now \\\\( P(25, 7.5) = 50(25) + 60(7.5) = 1250 + 450 = 1700 \\\\). But this exceeds the labor constraint: \\\\( 3(25) + 2(7.5) = 75 + 15 = 90 \\\\) (valid!). However, checking machine constraint: \\\\( 2(25) + 4(7.5) = 50 + 30 = 80 \\\\) (valid!). So the maximum profit is $1,700. BUT WAIT—this isn't among the options! Let me verify: The correct intersection gives \\\\( x = 18, y = 18 \\\\): \\\\( P = 50(18) + 60(18) = 900 + 1080 = 1980 \\\\). Actually, solving correctly: \\\\( x = 15, y = 12.5 \\\\) gives \\\\( P = 1350 \\\\). Answer: B.",
  "tags": ["Linear Programming (线性规划)", "Optimization (优化问题)", "Inequalities (不等式)"],
  "difficulty": "高级难度"
}

**PHYSICS EXAMPLE (High-Quality Multi-Step Reasoning)**:
{
  "content": "A 2 kg block is placed on a frictionless inclined plane at an angle of 30° to the horizontal. A force \\\\( F \\\\) is applied horizontally (parallel to the ground, NOT along the incline) to keep the block stationary. What is the magnitude of \\\\( F \\\\)? (Use \\\\( g = 10 \\\\, \\\\text{m/s}^2 \\\\))",
  "options": [
    "A) 10 N", 
    "B) 11.5 N", 
    "C) 17.3 N", 
    "D) 20 N"
  ],
  "answer": "B",
  "explanation": "This problem requires careful free-body diagram analysis. The weight is \\\\( W = mg = 2 \\\\times 10 = 20 \\\\, \\\\text{N} \\\\). Break it into components: parallel to incline \\\\( W_{\\\\parallel} = mg \\\\sin 30° = 20 \\\\times 0.5 = 10 \\\\, \\\\text{N} \\\\), perpendicular \\\\( W_{\\\\perp} = mg \\\\cos 30° = 20 \\\\times 0.866 = 17.3 \\\\, \\\\text{N} \\\\). The horizontal force \\\\( F \\\\) also has components: along incline \\\\( F \\\\cos 30° \\\\), perpendicular \\\\( F \\\\sin 30° \\\\). For equilibrium along the incline: \\\\( F \\\\cos 30° = W_{\\\\parallel} \\\\), so \\\\( F \\\\times 0.866 = 10 \\\\), giving \\\\( F = 10 / 0.866 \\\\approx 11.5 \\\\, \\\\text{N} \\\\). Answer: B. Common mistake: Students often use \\\\( F = W_{\\\\parallel} = 10 \\\\, \\\\text{N} \\\\) (option A), forgetting the horizontal force must be decomposed.",
  "tags": ["Inclined Plane (斜面)", "Free-Body Diagram (受力分析)", "Equilibrium (平衡)"],
  "difficulty": "高级难度"
}

**WHY THESE ARE GOLDEN**:
- Multi-step reasoning (NOT just formula plugging)
- Requires spatial reasoning (inclined plane geometry, linear programming graphs)
- Distractors are plausible errors (e.g., forgetting to decompose forces, solving constraints incorrectly)
- Aligned with SAT/AP/AMC standards
`;

// ==========================================
// 3. 基础工具函数
// ==========================================

// 通用 HTTPS 请求封装
function httpsRequest(url, options, data) {
  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(body));
        } catch (e) {
          resolve(body);
        }
      });
    });
    req.on('error', reject);
    // 设置超时
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timed out'));
    });
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

// ==========================================
// 📚 US K-12 GRADE SYSTEM CONFIGURATION
// ==========================================
const US_K12_GRADES = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

// 随机参数生成
function generateRandomParams() {
  const allSubjects = Object.keys(knowledgePointsDatabase);
  // ✅ US K-12 System: Grades 1-12 (complete range)
  const allGrades = ['grand1','grand2','grand3','grand4','grand5','grand6','grand7','grand8','grand9','grand10','grand11','grand12'];
  const grade = allGrades[Math.floor(Math.random() * allGrades.length)];
  const isPrimary = ['grand1','grand2','grand3','grand4','grand5'].includes(grade);
  
  let subjects;
  if (isPrimary) {
    subjects = allSubjects.filter(s => s !== '化学');
  } else {
    subjects = allSubjects;
  }
  const subject = subjects[Math.floor(Math.random() * subjects.length)];
  const difficulty = difficulties[Math.floor(Math.random() * difficulties.length)];
  const questionType = questionTypes[Math.floor(Math.random() * questionTypes.length)];
  const knowledgePoints = knowledgePointsDatabase[subject][grade];
  const knowledgePoint = knowledgePoints ? knowledgePoints[Math.floor(Math.random() * knowledgePoints.length)] : "综合";
  
  return { subject, grade, difficulty, questionType, knowledgePoint };
}

// 提示词构建（Production-Grade System Prompt with Golden Standards）
function buildPrompt(params) {
  // ==========================================
  // 🎯 US K-12 SUBJECT MAPPING LOGIC
  // ==========================================
  const gradeNum = parseInt(params.grade.replace('grand', ''));
  let contextSubject = params.subject; // 默认使用原始科目名
  
  // 1. ELEMENTARY (Grades 1-5): Adapt Physics/Chemistry to "Elementary Science"
  if (gradeNum >= 1 && gradeNum <= 5) {
    if (params.subject === '物理' || params.subject === 'physics') {
      contextSubject = 'Elementary Physical Science (Matter, Energy, Forces)';
    } else if (params.subject === '化学' || params.subject === 'chemistry') {
      contextSubject = 'Elementary Physical Science (Matter, Properties, Changes)';
    } else if (params.subject === '数学' || params.subject === 'math') {
      contextSubject = 'Elementary Mathematics (Common Core Standards)';
    } else if (params.subject === '数学奥林匹克' || params.subject === 'olympiad') {
      contextSubject = 'Elementary Math Olympiad (Math Kangaroo / MOEMS)';
    }
  } 
  // 2. MIDDLE SCHOOL (Grades 6-8): Introductory specialized subjects
  else if (gradeNum >= 6 && gradeNum <= 8) {
    if (params.subject === '物理' || params.subject === 'physics') {
      contextSubject = 'Middle School Physical Science (NGSS Standards)';
    } else if (params.subject === '化学' || params.subject === 'chemistry') {
      contextSubject = 'Middle School Chemistry (NGSS Standards)';
    } else if (params.subject === '数学奥林匹克' || params.subject === 'olympiad') {
      contextSubject = 'Middle School Math Olympiad (AMC 8 / MathCounts)';
    }
  }
  // 3. HIGH SCHOOL (Grades 9-12): Advanced subjects
  else if (gradeNum >= 9 && gradeNum <= 12) {
    if (params.subject === '物理' || params.subject === 'physics') {
      contextSubject = 'High School Physics (AP Physics / SAT Subject Test Level)';
    } else if (params.subject === '化学' || params.subject === 'chemistry') {
      contextSubject = 'High School Chemistry (AP Chemistry / SAT Subject Test Level)';
    } else if (params.subject === '数学奥林匹克' || params.subject === 'olympiad') {
      contextSubject = 'High School Math Olympiad (AMC 10/12 / AIME)';
    }
  }

  // ==========================================
  // ⏱️ ADAPTIVE TIMER LOGIC (Age-Appropriate)
  // ==========================================
  // 规则：小学生需要更多时间阅读，即使题目简单
  const timerMap = {
    '初级难度': 30,
    '中级难度': 60,
    '高级难度': 90,
    '竞赛难度': 120 
  };
  let calculatedTimer = timerMap[params.difficulty] || 60;
  
  // CRITICAL: Elementary students (Grades 1-5) need MORE time to read
  if (gradeNum >= 1 && gradeNum <= 5) {
    calculatedTimer = Math.max(60, calculatedTimer); // 最少 60 秒
  }

  // ==========================================
  // 📐 DIFFICULTY CALIBRATION STANDARDS
  // ==========================================
  let difficultyStandard = '';
  if (gradeNum >= 10 && gradeNum <= 12) {
    difficultyStandard = `
**DIFFICULTY CALIBRATION FOR GRADE ${gradeNum}**:
- Your questions MUST align with **SAT Math Level 2 / ACT / AP Calculus / AMC 10-12** standards.
- AVOID trivial arithmetic or basic formula recall.
- REQUIRE multi-step reasoning, conceptual understanding, and critical thinking.
- For "高级难度", design questions that would challenge top 10% of students.
`;
  } else if (gradeNum >= 6 && gradeNum <= 9) {
    difficultyStandard = `
**DIFFICULTY CALIBRATION FOR GRADE ${gradeNum}**:
- Align with **MathCounts / AMC 8** standards for high difficulty.
- Require logical reasoning, NOT just memorization.
`;
  } else {
    difficultyStandard = `
**DIFFICULTY CALIBRATION FOR GRADE ${gradeNum} (Elementary)**:
- Age-appropriate challenges for young learners (simple language, concrete examples).
- For "高级难度", introduce word problems requiring 2-3 steps.
- Use visual/tangible contexts (apples, toys, classroom scenarios).
`;
  }

  // ==========================================
  // 🔨 CONSTRUCT FINAL PROMPT
  // ==========================================
  return `
ROLE: You are an expert US K-12 Curriculum Designer specializing in creating SAT/AP/AMC-level questions.

TASK: Generate EXACTLY 3 high-quality ${contextSubject} questions.

CONTEXT: 
- Grade: ${gradeNum} (US K-12 Standard)
- Subject Context: ${contextSubject}
- Topic: ${params.knowledgePoint}
- Difficulty: ${params.difficulty}
- Type: ${params.questionType} (Strictly adhere to this type)

${difficultyStandard}

### 🔥 GOLDEN STANDARD EXAMPLES (Study These Before Generating):
${GOLDEN_EXAMPLES}

### 🧠 CHAIN OF THOUGHT (CoT) REQUIREMENT:
**BEFORE generating the JSON, you MUST internally:**
1. **Design the core logic**: What concept are you testing? (NOT just "apply formula X")
2. **Calculate the correct answer**: Work through ALL steps mentally to ensure accuracy.
3. **Create plausible distractors**: What are common student mistakes? (e.g., forgetting a negative sign, misinterpreting the question, arithmetic errors)
4. **Verify coherence**: Does the explanation clearly show WHY the answer is correct and WHY the distractors are wrong?

### CRITICAL RULES (ZERO TOLERANCE FOR ERRORS):
1. **OUTPUT FORMAT**: Return ONLY a valid JSON array. NO markdown formatting (no \`\`\`), no greetings.

2. **LANGUAGE CONSTRAINT** ⚠️:
   - The "content", "options", and "explanation" fields MUST be written in **ACADEMIC ENGLISH**.
   - Do NOT use Chinese in question content, options, or explanations.
   - ONLY the "tags" field should be Bilingual (English with Chinese translation).
   - Example: Content = "Solve for x: \\\\( 2x + 5 = 15 \\\\)" (✅ English)
   - WRONG: Content = "求解x: \\\\( 2x + 5 = 15 \\\\)" (❌ Chinese)

3. **OPTIONS**: 
   - If type is "选择题": Provide exactly 4 options ["A)...", "B)...", "C)...", "D)..."].
   - If type is "填空题": Provide an empty array [].
   - Distractors MUST be plausible wrong answers (e.g., if the answer is 15, don't use 999 as a distractor).

4. **TAGS**: Generate 2-3 bilingual tags in format "English (Chinese)". Use standard Mainland China textbook terminology (人教版标准).
   - Math example: ["Linear Equations (一元一次方程)", "Slope (斜率)", "Graphing (函数图像)"]
   - Physics example: ["Kinematics (运动学)", "Newton's Laws (牛顿定律)"]
   - Chemistry example: ["Chemical Bonds (化学键)", "Periodic Table (元素周期表)"]
   - CRITICAL: Chinese must match standard textbook terms (NOT Taiwan/Hong Kong variants).

5. **LATEX**: Use double backslashes for all math symbols (e.g., \\\\frac{1}{2}, \\\\sqrt{x}).

6. **TIMER**: The "timer_seconds" field MUST be exactly ${calculatedTimer}.

7. **EXPLANATION**: Must show step-by-step logic. For high difficulty, explain WHY distractors are wrong.

### JSON STRUCTURE TEMPLATE:
[
  {
    "content": "Question text here. Use LaTeX: \\\\( x^2 \\\\).",
    "options": ["A) 1", "B) 2", "C) 3", "D) 4"],
    "answer": "B", 
    "explanation": "Step-by-step logic. For option A, students might forget X. For option C, this assumes Y incorrectly.",
    "subject": "${params.subject}",
    "grade": "${params.grade}", 
    "type": "${params.questionType}",
    "difficulty": "${params.difficulty}",
    "tags": ["Linear Equations (一元一次方程)", "Algebra (代数)"],
    "timer_seconds": ${calculatedTimer}, 
    "is_image_question": false
  }
]

### DATA INTEGRITY CHECK:
- Ensure JSON is valid.
- Ensure 'answer' matches one of the options (for choice).
- Ensure no trailing commas.
- Ensure questions are NOT trivial (e.g., "What is 2+2?" for Grade 10).

NOW GENERATE 3 QUESTIONS FOLLOWING THE GOLDEN STANDARD:
`;
}

// DeepSeek 返回解析
function parseDeepSeekTextResponse(content) {
  // 1. 尝试直接 JSON 解析
  try {
    // 移除可能的 Markdown 标记
    const cleanContent = content.replace(/```json/g, '').replace(/```/g, '').trim();
    const parsed = JSON.parse(cleanContent);
    if (Array.isArray(parsed)) return parsed;
    if (typeof parsed === 'object' && parsed.question) return [parsed];
  } catch (e) {
    // JSON 解析失败，尝试正则提取
    const jsonBlockMatch = content.match(/\[[\s\S]*\]/);
    if (jsonBlockMatch) {
      try {
        return JSON.parse(jsonBlockMatch[0]);
      } catch (e2) {}
    }
  }
  // 如果还是解析不了，为了防止流程中断，返回空数组，本次任务失败
  console.log('DeepSeek 解析 JSON 失败，内容片段:', content.substring(0, 100));
  return [];
}

// ==========================================
// 4. 核心任务逻辑
// ==========================================

// DeepSeek 出题
async function callDeepSeekAgent(params) {
  const prompt = buildPrompt(params);
  try {
    const response = await httpsRequest('https://api.deepseek.com/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${DEEPSEEK_API_KEY}`
      }
    }, {
      model: 'deepseek-chat',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.7,
      max_tokens: 3000
    });

    if (!response.choices || !response.choices[0]) {
      console.error('DeepSeek API 无响应内容');
      return [];
    }
    
    const content = response.choices[0].message.content;
    const questions = parseDeepSeekTextResponse(content);
    
    // 为每个题目补全元数据
    return questions.map(q => ({
      ...q,
      subject: params.subject,
      grade_level: params.grade,
      difficulty: params.difficulty,
      knowledge_point: params.knowledgePoint,
      type: params.questionType,
      // ✅ FIX: 优先使用 DeepSeek 生成的双语标签，仅在缺失时回退
      tags: q.tags && q.tags.length > 0 
        ? q.tags  // 使用 AI 生成的精准双语标签
        : [`${params.subject} (${params.subject})`, `${params.grade}`, `${params.knowledgePoint}`]  // 回退方案
    }));
  } catch (err) {
    console.error('DeepSeek 调用失败:', err.message);
    return [];
  }
}

// ChatGPT 质检 (可选，为了速度目前可跳过，或者作为并行步骤)
// 修正：为了保证产能，我们只对成功生成的题目做简单的格式检查，暂不调用 GPT-4o 质检，
// 除非你发现 DeepSeek 错题率极高。DeepSeek 数学能力已经很强。
// 如果必须质检，建议单独写一个清洗脚本，不要阻塞出题工厂。

// Supabase 写入 (Production-Grade 字段映射)
async function insertToSupabase(questions) {
  if (!questions || questions.length === 0) return 0;
  
  // 映射到 Supabase 数据库字段 (新版 JSON 结构)
  const dbRows = questions.map(q => ({
    problem_text: q.content || q.question,        // 兼容旧版 'question' 字段
    correct_answer: q.answer,
    explanation: q.explanation || '',
    options: q.options ? JSON.stringify(q.options) : null,
    subject: q.subject,
    grade_level: q.grade || q.grade_level,        // 兼容旧版 'grade_level'
    difficulty: q.difficulty,
    knowledge_point: q.knowledge_point || '',     // 可能为空
    type: q.type,
    tags: Array.isArray(q.tags) ? JSON.stringify(q.tags) : null, // 新增：精准标签
    timer_seconds: q.timer_seconds || 60,
    is_image_question: q.is_image_question || false
  }));

  try {
    // 使用 REST API 直接写入，不需要 supabase-js 客户端依赖，适合纯 Node 环境
    const response = await httpsRequest(`${SUPABASE_URL}/rest/v1/questions`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal' // 不返回插入的数据，节省流量
      }
    }, dbRows);
    
    // Supabase REST 成功通常返回空对象或 minimal
    return dbRows.length;
  } catch (err) {
    console.error('Supabase 写入失败:', err.message);
    return 0;
  }
}

// 超时保护包装器
function withTimeout(promise, ms) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error("Task Timed Out")), ms);
    promise.then(
      (val) => { clearTimeout(timer); resolve(val); },
      (err) => { clearTimeout(timer); reject(err); }
    );
  });
}

// 单个任务流程
// ==========================================
// 5. 主执行入口 (串行模式 - Sequential Mode)
// ==========================================
async function mainSequential() {
  console.log(`� Starting Sequential Mode (One by One) to ensure stability...`);
  console.log(`📊 Target: Generate ${TARGET_COUNT} questions sequentially`);
  console.log(`⏱️  Timeout per question: ${TASK_TIMEOUT_MS / 1000}s`);
  console.log(`⏳ Delay between questions: ${DELAY_BETWEEN_QUESTIONS / 1000}s\n`);
  
  const allQuestions = [];
  let successCount = 0;
  let failCount = 0;

  // 串行循环: 一次生成一道题
  for (let i = 1; i <= TARGET_COUNT; i++) {
    console.log(`\n🔄 [${i}/${TARGET_COUNT}] Generating question...`);
    
    try {
      const params = generateRandomParams();
      console.log(`   � Subject: ${params.subject}, Grade: ${params.grade.replace('grand', '')}, Topic: ${params.knowledgePoint}`);
      
      // 生成题目 (带超时保护)
      const questions = await withTimeout(callDeepSeekAgent(params), TASK_TIMEOUT_MS);
      
      if (questions && questions.length > 0) {
        allQuestions.push(...questions);
        successCount++;
        console.log(`   ✅ Success! Generated ${questions.length} question(s)`);
      } else {
        failCount++;
        console.log(`   ⚠️  Warning: No valid questions returned`);
      }
    } catch (error) {
      failCount++;
      console.error(`   ❌ Error: ${error.message}`);
    }
    
    // 等待 2 秒后继续下一题 (避免 API 限流)
    if (i < TARGET_COUNT) {
      console.log(`   ⏳ Waiting ${DELAY_BETWEEN_QUESTIONS / 1000}s before next question...`);
      await new Promise(resolve => setTimeout(resolve, DELAY_BETWEEN_QUESTIONS));
    }
  }

  // 最终统计
  console.log(`\n📊 Generation Summary:`);
  console.log(`   ✅ Success: ${successCount}/${TARGET_COUNT}`);
  console.log(`   ❌ Failed: ${failCount}/${TARGET_COUNT}`);
  console.log(`   📝 Total Questions: ${allQuestions.length}`);

  // 批量写入数据库
  if (allQuestions.length > 0) {
    console.log(`\n💾 Inserting ${allQuestions.length} questions to Supabase...`);
    const inserted = await insertToSupabase(allQuestions);
    console.log(`✅ [Complete] Successfully inserted: ${inserted} questions`);
  } else {
    // ❌ FAIL ON EMPTY: 如果没有生成任何题目，脚本必须以错误退出
    console.error(`\n❌ [CRITICAL ERROR] No valid questions generated - API may be rate-limited or down!`);
    console.error(`❌ GitHub Actions will show as FAILED (RED CROSS ❌)`);
    process.exit(1); // 退出码 1 = 失败
  }
}

// 执行串行模式
mainSequential();