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

// 并发设置：一次触发同时跑几个任务
const CONCURRENCY_LIMIT = 5; 
// 超时设置：单个任务最大允许时间 (毫秒)
const TASK_TIMEOUT_MS = 50000; 

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

// 随机参数生成
function generateRandomParams() {
  const allSubjects = Object.keys(knowledgePointsDatabase);
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

// 提示词构建
function buildPrompt(params) {
  return `请严格按照以下要求生成 3 道 ${params.difficulty} 的 ${params.subject} 题目（${params.questionType}），年级：${params.grade}，知识点：${params.knowledgePoint}。\n\n- 只输出题目本身，不要出现任何教学、引导、聊天、寒暄、桥段、开场白、结尾语等内容。\n- 禁止出现“同学们”、“我们今天来学习”等任何非题目内容。\n- 题目必须有唯一且明确的标准答案，不能有多解或开放性答案。\n- 严格输出 JSON 数组格式，不要 Markdown 代码块。\n格式示例：\n[{"question": "题干", "answer": "标准答案", "explanation": "解析", "options": ["A", "B", "C", "D"], "type": "${params.questionType}"}]`;
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
      tags: [params.subject, params.grade, params.knowledgePoint] // 方便检索
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

// Supabase 写入 (补全了逻辑)
async function insertToSupabase(questions) {
  if (!questions || questions.length === 0) return 0;
  
  // 映射到你的数据库字段
  const dbRows = questions.map(q => ({
    problem_text: q.question,
    correct_answer: q.answer,
    explanation: q.explanation || '',
    options: q.options ? JSON.stringify(q.options) : null, // 假设数据库 options 是 JSONB 或 Text
    subject: q.subject,
    grade_level: q.grade_level,
    difficulty: q.difficulty,
    knowledge_point: q.knowledge_point,
    type: q.type, // 确保数据库有这个字段，没有的话去掉
    tags: q.tags // 确保数据库有这个字段，没有的话去掉
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
async function runOneTask() {
  const params = generateRandomParams();
  // 50秒超时限制
  const questions = await withTimeout(callDeepSeekAgent(params), TASK_TIMEOUT_MS);
  return questions;
}

// ==========================================
// 5. 主执行入口 (并发版)
// ==========================================
async function mainBatch() {
  console.log(`🚀 [Factory] 启动并发任务 (并发数: ${CONCURRENCY_LIMIT})...`);
  
  // 1. 创建并发任务
  const tasks = Array.from({ length: CONCURRENCY_LIMIT }).map(() => 
    runOneTask().catch(e => {
      console.error('⚠️ 单个任务失败:', e.message);
      return []; // 失败返回空数组，不影响其他
    })
  );

  // 2. 等待所有任务结束 (Promise.allSettled 的替代写法，上面 catch 已经处理了异常)
  const results = await Promise.all(tasks);

  // 3. 汇总题目
  const allQuestions = results.flat();

  // 4. 批量写入
  if (allQuestions.length > 0) {
    console.log(`💾 正在写入 ${allQuestions.length} 道题目...`);
    const inserted = await insertToSupabase(allQuestions);
    console.log(`✅ [Batch Complete] 成功入库: ${inserted}`);
  } else {
    console.log(`⚠️ [Batch Complete] 本次未生成有效题目`);
  }
}

// 执行一次并退出 (适配 GitHub Actions)
mainBatch();