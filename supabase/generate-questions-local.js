#!/usr/bin/env node

/**
 * 本地题目生成脚本
 * 直接调用 DeepSeek + GPT-4o + Supabase，无需部署 Edge Function
 * 
 * 使用方法:
 *   node supabase/generate-questions-local.js
 */

const https = require('https');

// ============================================
// 配置区（从 .env 读取）
// ============================================
const DEEPSEEK_API_KEY = 'sk-c80e575eabed4d039b34d59fe62dd3fd';
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || '';
const SUPABASE_URL = 'https://wsoilhwdxncnumzttbaz.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indzb2lsaHdkeG5jbnVtenR0YmF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyMDk1NDksImV4cCI6MjA3Nzc4NTU0OX0.XXgTbuqXA0McFo17xakcRvGuX0ilkJfYIVpQ4JTxF_k';

// ============================================
// 随机参数生成（v5.22.1 智能升级）
// ============================================
const knowledgePointsDatabase = {
  "数学": {
    "6-8年级": ["分数运算", "方程的基础", "平面几何", "数据统计初步", "代数式化简"],
    "9-10年级": ["一元二次方程", "函数与图像", "三角函数基础", "圆的性质", "概率初步"],
    "11-12年级": ["导数与微分", "三角函数", "数列与极限", "空间向量", "概率分布"]
  },
  "物理": {
    "6-8年级": ["光的反射", "力与运动", "简单机械", "声音的传播", "温度与热量"],
    "9-10年级": ["牛顿定律", "电路与欧姆定律", "能量守恒", "波动与振动", "光的折射"],
    "11-12年级": ["动量守恒", "电磁感应", "原子物理", "相对论初步", "波粒二象性"]
  },
  "化学": {
    "6-8年级": ["物质的状态", "酸碱盐基础", "氧化还原初步", "化学反应类型", "元素周期表初识"],
    "9-10年级": ["化学方程式配平", "溶液与溶解度", "金属活动性", "有机化合物初步", "化学平衡初步"],
    "11-12年级": ["电化学", "化学平衡", "有机化学反应", "配位化合物", "化学动力学"]
  }
};

function generateRandomParams() {
  const subjects = ["数学", "物理", "化学"];
  const grades = ["6-8年级", "9-10年级", "11-12年级"];
  const difficulties = ["简单", "中等", "困难"];
  
  const randomSubject = subjects[Math.floor(Math.random() * subjects.length)];
  const randomGrade = grades[Math.floor(Math.random() * grades.length)];
  const randomDifficulty = difficulties[Math.floor(Math.random() * difficulties.length)];
  
  const knowledgePoints = knowledgePointsDatabase[randomSubject][randomGrade];
  const randomKnowledgePoint = knowledgePoints[Math.floor(Math.random() * knowledgePoints.length)];
  
  return {
    subject: randomSubject,
    grade: randomGrade,
    difficulty: randomDifficulty,
    knowledgePoint: randomKnowledgePoint
  };
}

// ============================================
// HTTP请求封装
// ============================================
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
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

// ============================================
// Agent 1: DeepSeek 出题官
// ============================================
async function callDeepSeekAgent(params) {
  console.log(`\n🤖 [Agent 1: DeepSeek 出题官] 开始生成题目...`);
  console.log(`   学科: ${params.subject}`);
  console.log(`   年级: ${params.grade}`);
  console.log(`   难度: ${params.difficulty}`);
  console.log(`   知识点: ${params.knowledgePoint}`);
  
  const prompt = `你是一个专业的${params.grade}的${params.subject}老师。请为"${params.knowledgePoint}"这个知识点，生成 5 道"${params.difficulty}"难度的选择题。

要求：
1. 每道题必须有 4 个选项（A/B/C/D）
2. 题目难度必须符合"${params.difficulty}"等级
3. 必须严格围绕"${params.knowledgePoint}"知识点
4. 题目表述清晰，选项无歧义

请严格按照以下 JSON 格式输出（不要有任何额外文字）：
[
  {
    "problem_text": "题目文本",
    "options": {"A": "选项A", "B": "选项B", "C": "选项C", "D": "选项D"},
    "correct_answer": "A",
    "subject": "${params.subject}",
    "grade_level": "${params.grade}",
    "difficulty": "${params.difficulty}",
    "knowledge_point": "${params.knowledgePoint}"
  }
]`;

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
    max_tokens: 2000
  });

  const content = response.choices[0].message.content;
  const jsonMatch = content.match(/\[[\s\S]*\]/);
  if (!jsonMatch) throw new Error('DeepSeek 返回格式错误');
  
  const questions = JSON.parse(jsonMatch[0]);
  console.log(`✅ [Agent 1] 生成完成，共 ${questions.length} 道题`);
  return questions;
}

// ============================================
// Agent 2: GPT-4o Mini 质检员
// ============================================
async function callGpt4oAgent(problem, expectedParams) {
  const prompt = `你是一个严格的质检员。这道题的预期标准是：
- 学科: ${expectedParams.subject}
- 年级: ${expectedParams.grade}
- 难度: ${expectedParams.difficulty}
- 知识点: ${expectedParams.knowledgePoint}

你的任务是：
1. 独立计算这道题，验证 'correct_answer' 是否 100% 正确
2. 检查选项是否清晰、无歧义
3. 检查题目是否符合"${expectedParams.grade}"的知识水平
4. 检查题目是否真的在考察"${expectedParams.knowledgePoint}"知识点
5. 检查难度是否与"${expectedParams.difficulty}"相符

请仅回复一个词：
- 如果完全合格，回复 "APPROVED"
- 如果不合格，回复 "REJECTED: 具体原因"

题目数据：
${JSON.stringify(problem, null, 2)}`;

  const response = await httpsRequest('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${OPENAI_API_KEY}`
    }
  }, {
    model: 'gpt-4o-mini',
    messages: [{ role: 'user', content: prompt }],
    temperature: 0.3,
    max_tokens: 200
  });

  return response.choices[0].message.content.trim();
}

// ============================================
// Agent 3: Supabase 装载机
// ============================================
async function insertToSupabase(approvedQuestions) {
  console.log(`\n📦 [Agent 3: Supabase 装载机] 开始批量插入...`);
  
  const response = await httpsRequest(`${SUPABASE_URL}/rest/v1/questions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'apikey': SUPABASE_ANON_KEY,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      'Prefer': 'return=minimal'
    }
  }, approvedQuestions);

  console.log(`✅ [Agent 3] 插入完成，共 ${approvedQuestions.length} 道题`);
  return approvedQuestions.length;
}

// ============================================
// 主流程
// ============================================
async function main() {
  console.log('🏭 Question Factory Local 启动...\n');
  
  try {
    // 生成随机参数
    const randomParams = generateRandomParams();
    
    // Agent 1: DeepSeek 生成题目
    const generatedQuestions = await callDeepSeekAgent(randomParams);
    
    // Agent 2: GPT-4o 并行质检
    console.log(`\n🔍 [Agent 2: GPT-4o Mini 质检员] 开始并行质检...`);
    const validationPromises = generatedQuestions.map(q => callGpt4oAgent(q, randomParams));
    const validationResults = await Promise.all(validationPromises);
    
    // 过滤 APPROVED 题目
    const approvedQuestions = [];
    const rejectedQuestions = [];
    
    generatedQuestions.forEach((q, i) => {
      const result = validationResults[i];
      if (result.startsWith('APPROVED')) {
        approvedQuestions.push(q);
        console.log(`   ✅ 题目 ${i + 1}: 通过`);
      } else {
        rejectedQuestions.push({ question: q, reason: result });
        console.log(`   ❌ 题目 ${i + 1}: ${result}`);
      }
    });
    
    console.log(`\n📊 质检结果:`);
    console.log(`   通过: ${approvedQuestions.length} 道`);
    console.log(`   拒绝: ${rejectedQuestions.length} 道`);
    
    // Agent 3: 插入 Supabase
    if (approvedQuestions.length > 0) {
      await insertToSupabase(approvedQuestions);
    } else {
      console.log('\n⚠️ 没有通过质检的题目，跳过插入');
    }
    
    // 汇总报告
    console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
    console.log(`🎉 Question Factory 执行完成！`);
    console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
    console.log(`📝 生成题目: ${generatedQuestions.length} 道`);
    console.log(`✅ 通过质检: ${approvedQuestions.length} 道`);
    console.log(`❌ 拒绝题目: ${rejectedQuestions.length} 道`);
    console.log(`💾 入库题目: ${approvedQuestions.length} 道`);
    console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`);
    
  } catch (error) {
    console.error('❌ 执行失败:', error.message);
    process.exit(1);
  }
}

// 执行
main();
