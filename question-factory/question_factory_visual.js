#!/usr/bin/env node

const https = require('https');
const fs = require('fs');
const path = require('path');

// ==========================================
// 🎨 VISUAL QUESTION FACTORY v2.0
// Purpose: Generate questions with SVG diagrams
// Target: Geometry (Math) + Mechanics (Physics)
// NEW: 120s timeout, 3x retry, 5s rate limiting
// ==========================================

// Load .env file manually (no external dependencies)
const envPath = path.join(__dirname, '..', '.env');
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf8');
  envContent.split('\n').forEach(line => {
    const match = line.match(/^([^=:#]+)=(.*)$/);
    if (match) {
      const key = match[1].trim();
      const value = match[2].trim();
      if (!process.env[key]) process.env[key] = value;
    }
  });
}

const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY || process.env.LLM_API_KEY;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!DEEPSEEK_API_KEY || !SUPABASE_URL || !SUPABASE_KEY) {
  console.error('❌ Missing environment variables. Check .env file.');
  process.exit(1);
}

// ==========================================
// ⚙️ CONFIGURATION
// ==========================================
const CONFIG = {
  API_TIMEOUT: 300000,      // 300 seconds (5 minutes) for SVG generation
  MAX_RETRIES: 3,           // Retry up to 3 times per question
  RETRY_DELAY: 30000,       // Wait 30 seconds between retries
  RATE_LIMIT_DELAY: 5000,   // Wait 5 seconds between questions
};

// ==========================================
// 📐 VISUAL QUESTION DATABASE
// ==========================================
const VISUAL_TOPICS = {
  "数学": {
    "grand7": ["三角形性质", "平行四边形", "圆的性质"],
    "grand8": ["勾股定理", "相似三角形", "图形面积"],
    "grand9": ["三角函数图像", "函数图像", "解析几何"],
    "grand10": ["向量几何", "立体几何", "圆锥曲线"],
    "grand11": ["空间向量", "立体几何体积", "解析几何综合"],
    "grand12": ["参数方程", "极坐标", "空间解析几何"]
  },
  "物理": {
    "grand7": ["力的平衡", "杠杆原理", "滑轮组"],
    "grand8": ["斜面问题", "浮力示意图", "简单电路"],
    "grand9": ["力的分解", "运动轨迹", "电磁感应"],
    "grand10": ["抛体运动", "圆周运动", "光的反射折射"],
    "grand11": ["带电粒子运动", "波的干涉", "电场线"],
    "grand12": ["复杂力学系统", "电磁场叠加", "光学综合"]
  }
};

// ==========================================
// 🖼️ SVG EXAMPLES (Few-Shot Learning)
// ==========================================
const SVG_EXAMPLES = `
**EXAMPLE 1: Right Triangle (Geometry)**
SVG Code:
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300">
  <!-- Right triangle -->
  <polygon points="50,250 50,100 200,250" fill="none" stroke="black" stroke-width="2"/>
  
  <!-- Right angle marker -->
  <rect x="50" y="235" width="15" height="15" fill="none" stroke="black" stroke-width="1"/>
  
  <!-- Labels -->
  <text x="30" y="180" font-size="16" fill="black">3</text>
  <text x="120" y="270" font-size="16" fill="black">4</text>
  <text x="130" y="170" font-size="16" fill="black">?</text>
  
  <!-- Angle markers -->
  <circle cx="50" cy="100" r="3" fill="black"/>
  <circle cx="200" cy="250" r="3" fill="black"/>
</svg>

Question: "What is the length of the hypotenuse?"

**EXAMPLE 2: Inclined Plane (Physics)**
SVG Code:
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300">
  <!-- Ground -->
  <line x1="20" y1="250" x2="280" y2="250" stroke="black" stroke-width="3"/>
  
  <!-- Inclined plane -->
  <polygon points="50,250 250,250 250,100" fill="#e8f5e9" stroke="black" stroke-width="2"/>
  
  <!-- Block on incline -->
  <rect x="180" y="140" width="40" height="40" fill="#bbdefb" stroke="black" stroke-width="2"/>
  
  <!-- Force arrow (down) -->
  <line x1="200" y1="160" x2="200" y2="220" stroke="red" stroke-width="2" marker-end="url(#arrowred)"/>
  <text x="210" y="200" font-size="14" fill="red">mg</text>
  
  <!-- Angle marker -->
  <path d="M 250 250 L 250 230 A 20 20 0 0 0 230 250 Z" fill="none" stroke="black" stroke-width="1"/>
  <text x="235" y="245" font-size="12" fill="black">30°</text>
  
  <!-- Arrow marker definition -->
  <defs>
    <marker id="arrowred" markerWidth="10" markerHeight="10" refX="5" refY="3" orient="auto">
      <polygon points="0 0, 10 3, 0 6" fill="red"/>
    </marker>
  </defs>
</svg>

Question: "A 2kg block rests on a 30° incline. What is the normal force?"

**KEY SVG RULES**:
1. Always use viewBox="0 0 300 300" for consistent scaling
2. Keep stroke-width between 2-3 for clarity
3. Use simple geometric shapes (line, circle, rect, polygon, path)
4. Add text labels for dimensions and variables
5. Use colors sparingly: black lines, light fills (#e8f5e9, #bbdefb)
6. For arrows, define markers in <defs> section
7. Avoid gradients, shadows, or complex filters
`;

// ==========================================
// 🤖 AI PROMPT BUILDER
// ==========================================
function buildVisualPrompt(params) {
  const gradeNum = parseInt(params.grade.replace('grand', ''));
  
  // Timer logic
  const timerMap = {
    '初级难度': gradeNum <= 8 ? 90 : 60,
    '中级难度': 90,
    '高级难度': 120,
  };
  const calculatedTimer = timerMap[params.difficulty] || 90;

  return `
ROLE: You are a Visual Education Content Creator specializing in geometric and physics diagrams.

TASK: Generate EXACTLY 1 high-quality visual question with an SVG diagram.

CONTEXT:
- Subject: ${params.subject}
- Grade: ${gradeNum} (US K-12)
- Topic: ${params.topic}
- Difficulty: ${params.difficulty}

### 🎨 SVG DIAGRAM EXAMPLES:
${SVG_EXAMPLES}

### 📐 VISUAL QUESTION REQUIREMENTS:

1. **Question Design**:
   - The question MUST require analyzing a visual diagram to solve
   - Examples: "Find angle ABC", "Calculate the normal force on the block", "What is the area of the shaded region?"
   - AVOID: Questions that can be solved without looking at the diagram

2. **SVG Code Generation**:
   - You MUST generate valid SVG XML code
   - Follow the examples above EXACTLY
   - Use viewBox="0 0 300 300"
   - Keep it simple: basic shapes, black strokes, minimal colors
   - Add clear labels using <text> elements
   - For arrows, use <marker> definitions (see examples)

3. **JSON Structure**:
   Return ONLY valid JSON (no markdown, no greetings):
   [
     {
       "content": "Based on the diagram, what is the length of side AC?",
       "svg_diagram": "<svg xmlns=\\"http://www.w3.org/2000/svg\\" viewBox=\\"0 0 300 300\\">...</svg>",
       "options": ["A) 5", "B) 10", "C) 12", "D) 15"],
       "answer": "C",
       "explanation": "Using the Pythagorean theorem: AC² = AB² + BC² = 9 + 144 = 153, so AC ≈ 12.37 ≈ 12.",
       "subject": "${params.subject}",
       "grade": "${params.grade}",
       "type": "选择题",
       "difficulty": "${params.difficulty}",
       "tags": ["Pythagorean Theorem (勾股定理)", "Right Triangles (直角三角形)"],
       "timer_seconds": ${calculatedTimer},
       "is_image_question": false
     }
   ]

4. **CRITICAL VALIDATION**:
   - Ensure SVG is valid XML (properly closed tags, escaped quotes)
   - Test mentally: Does the diagram clearly show the problem setup?
   - Labels must be readable (font-size: 14-16)

NOW GENERATE 1 VISUAL QUESTION:
`;
}

// ==========================================
// 🌐 HTTP UTILITIES
// ==========================================
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
    req.setTimeout(CONFIG.API_TIMEOUT); // ✅ NEW: 120 seconds timeout
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timed out after ' + (CONFIG.API_TIMEOUT / 1000) + 's'));
    });
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

// ==========================================
// 🔁 RETRY UTILITIES
// ==========================================
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function retryWithBackoff(fn, maxRetries = CONFIG.MAX_RETRIES, retryDelay = CONFIG.RETRY_DELAY) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (attempt === maxRetries) {
        throw err; // Final attempt failed, throw error
      }
      
      console.log(`   ⚠️  Attempt ${attempt}/${maxRetries} failed: ${err.message}`);
      console.log(`   ⏳ Waiting ${retryDelay / 1000}s before retry...`);
      await sleep(retryDelay);
    }
  }
}

// ==========================================
// 🎯 CORE LOGIC
// ==========================================
function generateRandomParams() {
  // ✅ NEW: Support TARGET_SUBJECT environment variable for Matrix workflow
  const targetSubject = process.env.TARGET_SUBJECT;
  
  let subject;
  if (targetSubject) {
    // Map English subject names to Chinese
    const subjectMap = {
      'math': '数学',
      'physics': '物理',
      'chemistry': '化学',
      'olympiad': '奥数'
    };
    
    subject = subjectMap[targetSubject.toLowerCase()];
    
    if (!subject || !VISUAL_TOPICS[subject]) {
      console.error(`❌ Invalid TARGET_SUBJECT: ${targetSubject}. Using random selection.`);
      const subjects = Object.keys(VISUAL_TOPICS);
      subject = subjects[Math.floor(Math.random() * subjects.length)];
    } else {
      console.log(`🎯 Target Subject Mode: ${subject} (${targetSubject})`);
    }
  } else {
    // Original random behavior
    const subjects = Object.keys(VISUAL_TOPICS);
    subject = subjects[Math.floor(Math.random() * subjects.length)];
  }
  
  const grades = Object.keys(VISUAL_TOPICS[subject]);
  const grade = grades[Math.floor(Math.random() * grades.length)];
  
  const topics = VISUAL_TOPICS[subject][grade];
  const topic = topics[Math.floor(Math.random() * topics.length)];
  
  const difficulties = ['初级难度', '中级难度', '高级难度'];
  const difficulty = difficulties[Math.floor(Math.random() * difficulties.length)];
  
  return { subject, grade, topic, difficulty };
}

function parseDeepSeekResponse(content) {
  try {
    const cleanContent = content.replace(/```json/g, '').replace(/```/g, '').trim();
    const parsed = JSON.parse(cleanContent);
    if (Array.isArray(parsed)) return parsed;
    if (typeof parsed === 'object') return [parsed];
  } catch (e) {
    const jsonBlockMatch = content.match(/\[[\s\S]*\]/);
    if (jsonBlockMatch) {
      try {
        return JSON.parse(jsonBlockMatch[0]);
      } catch (e2) {
        console.error('   ❌ JSON parsing failed:', e2.message);
      }
    }
  }
  return [];
}

async function callDeepSeekVisual(params) {
  const prompt = buildVisualPrompt(params);
  
  // ✅ NEW: Wrap API call in retry logic
  const apiCall = async () => {
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
      max_tokens: 4000 // Increased for SVG code
    });

    if (!response.choices || !response.choices[0]) {
      throw new Error('DeepSeek API returned no response');
    }
    
    return response;
  };

  try {
    // ✅ NEW: Retry up to 3 times with 10s delay
    const response = await retryWithBackoff(apiCall);
    
    const content = response.choices[0].message.content;
    const questions = parseDeepSeekResponse(content);
    
    // Validate SVG exists
    return questions.filter(q => {
      if (!q.svg_diagram || q.svg_diagram.trim() === '') {
        console.warn('   ⚠️  Question missing SVG diagram, skipping');
        return false;
      }
      return true;
    });
  } catch (err) {
    console.error(`   ❌ DeepSeek API failed after ${CONFIG.MAX_RETRIES} attempts:`, err.message);
    return [];
  }
}

async function insertToSupabase(questions) {
  if (!questions || questions.length === 0) return 0;
  
  // ✅ Map to ACTUAL Supabase schema (confirmed via test_insert.js)
  const dbRows = questions.map(q => {
    // Extract grade number from "grand9" → 9
    const gradeNum = parseInt((q.grade || 'grand9').replace('grand', ''));
    
    // Extract ONLY the answer letter (A/B/C/D)
    const answerLetter = (q.answer || 'A').replace(/[^A-D]/g, '').charAt(0) || 'A';
    
    // Convert options array format: remove "A) " prefixes
    const optionsArray = Array.isArray(q.options) 
      ? q.options.map(opt => opt.replace(/^[A-D]\)\s*/, ''))
      : ['Option A', 'Option B', 'Option C', 'Option D'];
    
    // Map subject to enum (math/physics)
    const subjectEnum = (q.subject || '数学').toLowerCase() === '数学' ? 'math' : 
                        (q.subject || '').toLowerCase() === '物理' ? 'physics' : 'math';
    
    // Map difficulty to integer 1-5
    const difficultyMap = { '初级难度': 2, '中级难度': 3, '高级难度': 4 };
    const difficultyNum = difficultyMap[q.difficulty] || 3;
    
    return {
      content: q.content,  // ✅ Required: Question text
      options: optionsArray,  // ✅ Required: Array of strings
      answer: answerLetter,  // ✅ Required: Single letter
      explanation: q.explanation || '',  // ✅ Optional: Explanation
      subject: subjectEnum,  // ✅ Optional: math/physics/chemistry
      grade: gradeNum,  // ✅ Optional: Integer 7-12
      difficulty: difficultyNum,  // ✅ Optional: Integer 1-5
      tags: Array.isArray(q.tags) ? q.tags : [],  // ✅ Optional: Array of strings
      timer_seconds: q.timer_seconds || 90,  // ✅ Optional: Integer
      svg_diagram: q.svg_diagram || null,  // ✅ Optional: SVG XML string
      is_image_question: false  // ✅ Optional: Boolean
    };
  });

  try {
    const response = await httpsRequest(`${SUPABASE_URL}/rest/v1/questions`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      }
    }, dbRows);
    
    // Check for errors in response
    if (response && (response.error || response.code)) {
      console.error('\n❌ Supabase INSERT ERROR:');
      console.error('   Code:', response.code);
      console.error('   Message:', response.message);
      console.error('   Details:', response.details);
      console.error('   Hint:', response.hint);
      return 0;
    }
    
    if (typeof response === 'string' && response.includes('error')) {
      console.error('❌ Supabase returned error string:', response.substring(0, 500));
      return 0;
    }
    
    return dbRows.length;
  } catch (err) {
    console.error('❌ Supabase insert failed:', err.message);
    console.error('❌ Sample row that failed:', JSON.stringify(dbRows[0], null, 2));
    return 0;
  }
}

// ==========================================
// 🚀 MAIN EXECUTION
// ==========================================
async function main() {
  const count = parseInt(process.argv[2]) || 5;
  
  console.log(`🎨 Visual Question Factory v2.0 (SVG Diagrams)`);
  console.log(`📊 Target: ${count} questions`);
  console.log(`⚙️  Config: ${CONFIG.API_TIMEOUT / 1000}s timeout, ${CONFIG.MAX_RETRIES}x retries, ${CONFIG.RATE_LIMIT_DELAY / 1000}s rate limit\n`);

  const allQuestions = [];
  let successCount = 0;
  let failCount = 0;
  
  for (let i = 1; i <= count; i++) {
    console.log(`🔄 [${i}/${count}] Generating visual question...`);
    const params = generateRandomParams();
    console.log(`   📐 ${params.subject} - Grade ${params.grade.replace('grand', '')} - ${params.topic}`);
    
    const questions = await callDeepSeekVisual(params);
    
    if (questions.length > 0) {
      allQuestions.push(...questions);
      successCount++;
      console.log(`   ✅ Generated with SVG (${questions[0].svg_diagram.length} chars)`);
    } else {
      failCount++;
      console.log(`   ❌ Failed to generate after ${CONFIG.MAX_RETRIES} retries`);
    }
    
    // ✅ NEW: Rate limiting - wait 5 seconds between questions
    if (i < count) {
      console.log(`   ⏳ Rate limit: waiting ${CONFIG.RATE_LIMIT_DELAY / 1000}s before next question...\n`);
      await sleep(CONFIG.RATE_LIMIT_DELAY);
    } else {
      console.log(''); // Final newline
    }
  }

  console.log(`\n📊 Generation Summary:`);
  console.log(`   ✅ Success: ${successCount}/${count} questions`);
  console.log(`   ❌ Failed: ${failCount}/${count} questions`);

  if (allQuestions.length > 0) {
    console.log(`\n💾 Saving ${allQuestions.length} visual questions to Supabase...`);
    const inserted = await insertToSupabase(allQuestions);
    console.log(`✅ Success! Inserted ${inserted}/${allQuestions.length} visual questions with SVG diagrams.`);
  } else {
    console.error(`\n❌ No valid visual questions generated. All ${count} attempts failed.`);
    process.exit(1);
  }
}

main().catch(err => {
  console.error('\n💥 Fatal error:', err);
  process.exit(1);
});
