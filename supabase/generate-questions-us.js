#!/usr/bin/env node

/**
 * v5.36.3: Question Factory - 美国标准版本
 * 直接调用 DeepSeek + GPT-4o + Supabase，无需部署 Edge Function
 * 
 * 升级内容:
 * - 使用美国教育系统 (Grade 6-12, Common Core, AP, IB)
 * - 所有标签统一写入 curriculum text[] 数组
 * - 停止使用 grade_level 字段
 * 
 * 使用方法:
 *   node supabase/generate-questions-us.js
 */

const https = require('https');

// ============================================
// 配置区
// ============================================
const DEEPSEEK_API_KEY = 'sk-c80e575eabed4d039b34d59fe62dd3fd';
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || '';
const SUPABASE_URL = 'https://wsoilhwdxncnumzttbaz.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indzb2lsaHdkeG5jbnVtenR0YmF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyMDk1NDksImV4cCI6MjA3Nzc4NTU0OX0.XXgTbuqXA0McFo17xakcRvGuX0ilkJfYIVpQ4JTxF_k';

// ============================================
// v5.36.3: 美国标准知识点数据库
// ============================================
const knowledgePointsDatabase = {
  "Math": {
    "Grade 6-8": {
      "Common Core": ["Fractions & Decimals (6.NS.A)", "Ratios & Proportions (6.RP.A)", "Expressions & Equations (6.EE.A)", "Geometry Basics (6.G.A)", "Statistics & Probability (6.SP.A)"],
      "AP": [], // Middle School 没有 AP
      "IB": [] // Middle School 没有 IB
    },
    "Grade 9-10": {
      "Common Core": ["Linear Equations (HSA-REI.B)", "Quadratic Functions (HSF-IF.C)", "Exponents & Radicals (HSN-RN.A)", "Geometry Proofs (HSG-CO.C)", "Data Analysis (HSS-ID.A)"],
      "AP": ["Algebra I", "Geometry"],
      "IB": ["IB Math Studies"]
    },
    "Grade 11-12": {
      "Common Core": ["Polynomial Functions (HSF-IF.C)", "Trigonometry (HSF-TF.A)", "Statistics (HSS-IC.A)", "Calculus Concepts (Precalc)", "Vectors (HSN-VM.A)"],
      "AP": ["AP Calculus AB", "AP Calculus BC", "AP Statistics"],
      "IB": ["IB Math SL", "IB Math HL"]
    }
  },
  "Physics": {
    "Grade 6-8": {
      "Common Core": ["Force & Motion", "Energy Transfer", "Waves & Sound", "Light & Optics", "Magnetism Basics"],
      "AP": [],
      "IB": []
    },
    "Grade 9-10": {
      "Common Core": ["Newton's Laws", "Energy Conservation", "Electricity & Circuits", "Wave Properties", "Thermodynamics"],
      "AP": ["Physics 1"],
      "IB": ["IB Physics SL"]
    },
    "Grade 11-12": {
      "Common Core": ["Momentum & Collisions", "Electromagnetism", "Quantum Mechanics Intro", "Relativity Basics", "Nuclear Physics"],
      "AP": ["AP Physics 2", "AP Physics C: Mechanics", "AP Physics C: E&M"],
      "IB": ["IB Physics HL"]
    }
  },
  "Chemistry": {
    "Grade 6-8": {
      "Common Core": ["Matter States", "Chemical Reactions", "Periodic Table Intro", "Acids & Bases", "Mixtures & Solutions"],
      "AP": [],
      "IB": []
    },
    "Grade 9-10": {
      "Common Core": ["Atomic Structure", "Chemical Bonding", "Stoichiometry", "Gas Laws", "Redox Reactions"],
      "AP": ["Chemistry Honors"],
      "IB": ["IB Chemistry SL"]
    },
    "Grade 11-12": {
      "Common Core": ["Thermodynamics", "Chemical Equilibrium", "Electrochemistry", "Organic Chemistry", "Kinetics"],
      "AP": ["AP Chemistry"],
      "IB": ["IB Chemistry HL"]
    }
  }
};

// ============================================
// v5.36.3: 随机参数生成 (美国标准)
// ============================================
function generateRandomParams() {
  const subjects = ["Math", "Physics", "Chemistry"];
  const grades = ["Grade 6-8", "Grade 9-10", "Grade 11-12"];
  const curriculums = ["Common Core", "AP", "IB"];
  const difficulties = ["Easy", "Medium", "Hard"];
  
  const randomSubject = subjects[Math.floor(Math.random() * subjects.length)];
  const randomGrade = grades[Math.floor(Math.random() * grades.length)];
  const randomCurriculum = curriculums[Math.floor(Math.random() * curriculums.length)];
  const randomDifficulty = difficulties[Math.floor(Math.random() * difficulties.length)];
  
  const knowledgePoints = knowledgePointsDatabase[randomSubject][randomGrade][randomCurriculum];
  
  // 如果该年级+课程标准没有知识点（例如 Middle School + AP），重新选择
  if (!knowledgePoints || knowledgePoints.length === 0) {
    return generateRandomParams(); // 递归重试
  }
  
  const randomKnowledgePoint = knowledgePoints[Math.floor(Math.random() * knowledgePoints.length)];
  
  return {
    subject: randomSubject,
    grade: randomGrade,
    curriculum: randomCurriculum,
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
  console.log(`   Subject: ${params.subject}`);
  console.log(`   Grade: ${params.grade}`);
  console.log(`   Curriculum: ${params.curriculum}`);
  console.log(`   Difficulty: ${params.difficulty}`);
  console.log(`   Knowledge Point: ${params.knowledgePoint}`);
  
  const prompt = `You are a professional ${params.grade} ${params.subject} teacher following ${params.curriculum} curriculum. Generate 5 multiple-choice questions for the topic "${params.knowledgePoint}" at "${params.difficulty}" difficulty level.

Requirements:
1. Each question must have exactly 4 options (A/B/C/D)
2. Difficulty must match "${params.difficulty}" level
3. Must focus strictly on "${params.knowledgePoint}"
4. Clear wording, no ambiguous options
5. Questions should align with ${params.curriculum} standards

Output ONLY valid JSON (no extra text):
[
  {
    "problem_text": "Question text",
    "options": {"A": "Option A", "B": "Option B", "C": "Option C", "D": "Option D"},
    "correct_answer": "A",
    "subject": "${params.subject}",
    "grade_level": "${params.grade}",
    "difficulty": "${params.difficulty}",
    "knowledge_point": "${params.knowledgePoint}",
    "curriculum": ["${params.subject}", "${params.grade}", "${params.curriculum}"]
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
    max_tokens: 3000
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
  const prompt = `You are a strict quality checker. This question should meet these standards:
- Subject: ${expectedParams.subject}
- Grade: ${expectedParams.grade}
- Curriculum: ${expectedParams.curriculum}
- Difficulty: ${expectedParams.difficulty}
- Knowledge Point: ${expectedParams.knowledgePoint}

Your tasks:
1. Independently solve this problem to verify 'correct_answer' is 100% correct
2. Check if options are clear and unambiguous
3. Verify the question matches "${expectedParams.grade}" knowledge level
4. Confirm it tests "${expectedParams.knowledgePoint}"
5. Verify difficulty matches "${expectedParams.difficulty}"

Reply ONLY with one word:
- If fully qualified: "APPROVED"
- If not qualified: "REJECTED: specific reason"

Question data:
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
  console.log('🏭 Question Factory v5.36.3 (US Standard) 启动...\n');
  
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
    console.log(`🎉 Question Factory v5.36.3 执行完成！`);
    console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
    console.log(`📝 生成题目: ${generatedQuestions.length} 道`);
    console.log(`✅ 通过质检: ${approvedQuestions.length} 道`);
    console.log(`❌ 拒绝题目: ${rejectedQuestions.length} 道`);
    console.log(`💾 入库题目: ${approvedQuestions.length} 道`);
    console.log(`🌍 标签系统: ${randomParams.subject} | ${randomParams.grade} | ${randomParams.curriculum}`);
    console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`);
    
  } catch (error) {
    console.error('❌ 执行失败:', error.message);
    process.exit(1);
  }
}

// 执行
main();
