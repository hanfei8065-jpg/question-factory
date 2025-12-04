#!/usr/bin/env node

const https = require('https');

// ==========================================
// 🔧 CONFIGURATION
// ==========================================
const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

// ⚡️ ATOMIC SAVE MODE: 一题一存 (Generate → Save → Next)
const TARGET_COUNT = 10; // 每次生成 10 道题
const TASK_TIMEOUT_MS = 300000; // 单题超时: 300 秒 (5 分钟)
const DELAY_BETWEEN_QUESTIONS = 3000; // 每题之间等待 3 秒
const MAX_CONSECUTIVE_FAILURES = 3; // 连续失败 3 次 → 任务失败

if (!DEEPSEEK_API_KEY || !SUPABASE_URL || !SUPABASE_KEY) {
  console.error('❌ Missing environment variables!');
  process.exit(1);
}

// ==========================================
// 📚 KNOWLEDGE DATABASE (US K-12)
// ==========================================
const knowledgePointsDatabase = {
  "数学": {
    "grand1": ["Addition & Subtraction", "Number Recognition"],
    "grand2": ["Multiplication Basics", "Shapes & Geometry"],
    "grand3": ["Division", "Fractions Introduction"],
    "grand4": ["Decimals", "Area & Volume"],
    "grand5": ["Fraction Operations", "Ratios", "Probability"],
    "grand6": ["Algebra Basics", "Geometry Fundamentals"],
    "grand7": ["Linear Equations", "Geometric Properties"],
    "grand8": ["Functions", "Statistics", "Triangle Properties"],
    "grand9": ["Polynomials", "Function Graphs", "Sequences"],
    "grand10": ["Trigonometry", "3D Geometry", "Composite Functions"],
    "grand11": ["Calculus Introduction", "Vectors", "Probability Distributions"],
    "grand12": ["Calculus Applications", "Advanced Algebra", "Statistical Inference"]
  },
  "物理": {
    "grand6": ["Forces & Motion", "Energy Basics"],
    "grand7": ["Simple Machines", "Levers & Pulleys"],
    "grand8": ["Newton's Laws", "Momentum"],
    "grand9": ["Work & Energy", "Projectile Motion"],
    "grand10": ["Circular Motion", "Optics", "Waves"],
    "grand11": ["Electromagnetism", "Modern Physics"],
    "grand12": ["Thermodynamics", "Quantum Physics Intro"]
  },
  "化学": {
    "grand7": ["Atoms & Molecules", "Chemical Reactions"],
    "grand8": ["Periodic Table", "Chemical Bonds"],
    "grand9": ["Stoichiometry", "Solutions & Concentrations"],
    "grand10": ["Acid-Base Chemistry", "Redox Reactions"],
    "grand11": ["Organic Chemistry Basics", "Equilibrium"],
    "grand12": ["Advanced Organic Chemistry", "Electrochemistry"]
  },
  "数学奥林匹克": {
    "grand4": ["Number Theory Basics", "Logic Puzzles"],
    "grand5": ["Sequences & Recursion", "Combinatorics"],
    "grand6": ["Algebraic Thinking", "Olympiad Geometry"],
    "grand7": ["Number Theory", "Combinatorics", "Geometry"],
    "grand8": ["Advanced Number Theory", "Complex Combinations"],
    "grand9": ["Functions & Equations", "Competition Geometry"],
    "grand10": ["Advanced Algebra", "Competition Probability"],
    "grand11": ["Calculus Competitions", "Advanced Logic"],
    "grand12": ["Comprehensive Olympiad Topics"]
  }
};

const difficulties = ['初级难度', '中级难度', '高级难度'];
const questionTypes = ['选择题', '填空题'];

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
    req.setTimeout(TASK_TIMEOUT_MS);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error(`Request timed out after ${TASK_TIMEOUT_MS / 1000}s`));
    });
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// ==========================================
// 🎯 RANDOM PARAMS GENERATOR (with TARGET_SUBJECT)
// ==========================================
function generateRandomParams() {
  const targetSubject = process.env.TARGET_SUBJECT;
  
  const allSubjects = Object.keys(knowledgePointsDatabase);
  const allGrades = ['grand1','grand2','grand3','grand4','grand5','grand6','grand7','grand8','grand9','grand10','grand11','grand12'];
  const grade = allGrades[Math.floor(Math.random() * allGrades.length)];
  
  let subject;
  
  // ⚡️ FORCE SUBJECT if TARGET_SUBJECT is set
  if (targetSubject) {
    const subjectMap = {
      'math': '数学',
      'physics': '物理',
      'chemistry': '化学',
      'olympiad': '数学奥林匹克'
    };
    
    subject = subjectMap[targetSubject.toLowerCase()];
    
    if (!subject || !knowledgePointsDatabase[subject]) {
      console.error(`❌ Invalid TARGET_SUBJECT: ${targetSubject}`);
      subject = allSubjects[Math.floor(Math.random() * allSubjects.length)];
    }
  } else {
    subject = allSubjects[Math.floor(Math.random() * allSubjects.length)];
  }
  
  // Ensure the grade has topics for this subject
  const availableGrades = Object.keys(knowledgePointsDatabase[subject]);
  const validGrade = availableGrades.includes(grade) ? grade : availableGrades[0];
  
  const knowledgePoints = knowledgePointsDatabase[subject][validGrade];
  const knowledgePoint = knowledgePoints[Math.floor(Math.random() * knowledgePoints.length)];
  const difficulty = difficulties[Math.floor(Math.random() * difficulties.length)];
  const questionType = questionTypes[Math.floor(Math.random() * questionTypes.length)];
  
  return { subject, grade: validGrade, difficulty, questionType, knowledgePoint };
}

// ==========================================
// 📝 PROMPT BUILDER
// ==========================================
function buildPrompt(params) {
  const gradeNum = parseInt(params.grade.replace('grand', ''));
  
  // Map timer based on difficulty
  const timerMap = {
    '初级难度': 60,
    '中级难度': 90,
    '高级难度': 120
  };
  const calculatedTimer = timerMap[params.difficulty] || 90;
  
  return `
ROLE: You are an expert US K-12 Curriculum Designer.

TASK: Generate EXACTLY 1 high-quality question.

CONTEXT:
- Grade: ${gradeNum} (US K-12 Standard)
- Subject: ${params.subject}
- Topic: ${params.knowledgePoint}
- Difficulty: ${params.difficulty}
- Type: ${params.questionType}

⚠️ CRITICAL LANGUAGE CONSTRAINT:
- **OUTPUT MUST BE IN ACADEMIC ENGLISH.**
- "content", "options", "explanation" → **ENGLISH ONLY** (NO Chinese characters)
- "tags" → Bilingual format: "English (Chinese)"

RULES:
1. Return ONLY valid JSON (no markdown, no greetings).
2. Options: If type is "选择题", provide exactly 4 options ["A)...", "B)...", "C)...", "D)..."]. If "填空题", use empty array [].
3. Tags: 2-3 bilingual tags like ["Linear Equations (一元一次方程)", "Algebra (代数)"].
4. Timer: Set "timer_seconds" to ${calculatedTimer}.
5. LaTeX: Use double backslashes (\\\\\\\\frac{1}{2}, \\\\\\\\sqrt{x}).

JSON STRUCTURE:
{
  "content": "Question text in English. Use LaTeX: \\\\\\\\( x^2 \\\\\\\\).",
  "options": ["A) 1", "B) 2", "C) 3", "D) 4"],
  "answer": "B",
  "explanation": "Step-by-step explanation in English.",
  "tags": ["Linear Equations (一元一次方程)", "Algebra (代数)"],
  "timer_seconds": ${calculatedTimer}
}

NOW GENERATE 1 QUESTION:
`;
}

// ==========================================
// 🔧 JSON EXTRACTION HELPER (BULLETPROOF)
// ==========================================
function extractJson(text) {
  // 1. Remove Markdown code blocks
  let clean = text.replace(/```json/g, '').replace(/```/g, '').trim();
  
  // 2. Find the first '{' or '['
  const firstCurly = clean.indexOf('{');
  const firstSquare = clean.indexOf('[');
  
  let start = -1;
  let end = -1;

  // Determine if it starts with { or [
  if (firstCurly !== -1 && (firstSquare === -1 || firstCurly < firstSquare)) {
    start = firstCurly;
    end = clean.lastIndexOf('}') + 1;
  } else if (firstSquare !== -1) {
    start = firstSquare;
    end = clean.lastIndexOf(']') + 1;
  }

  if (start !== -1 && end !== -1) {
    clean = clean.substring(start, end);
  }

  try {
    const parsed = JSON.parse(clean);
    // 3. Normalize to Array: If it's a single object, wrap it in an array
    return Array.isArray(parsed) ? parsed : [parsed];
  } catch (e) {
    console.error("❌ Failed to parse cleaned JSON:", clean.substring(0, 100) + "...");
    throw e;
  }
}

// ==========================================
// 🤖 DEEPSEEK API CALLER
// ==========================================
async function callDeepSeekAPI(params) {
  const prompt = buildPrompt(params);
  const startTime = Date.now();
  
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
      max_tokens: 4096  // ✅ INCREASED: 2000 → 4096 to prevent truncation
    });

    const duration = ((Date.now() - startTime) / 1000).toFixed(1);
    
    if (!response.choices || !response.choices[0]) {
      console.error(`   ❌ DeepSeek returned no content (${duration}s)`);
      return null;
    }
    
    const content = response.choices[0].message.content;
    console.log(`   ⏱️  API Response Time: ${duration}s`);
    
    // ✅ BULLETPROOF JSON EXTRACTION: Handle markdown, single object, and arrays
    let parsedArray;
    try {
      // extractJson now returns an array (single object wrapped or original array)
      parsedArray = extractJson(content);
    } catch (e) {
      // ✅ DEBUG LOGGING: Show exactly what DeepSeek returned
      console.error(`   ❌ JSON Parse Error: ${e.message}`);
      console.error(`   📄 Raw Output (first 500 chars):`);
      console.error(content.substring(0, 500));
      console.error(`   📄 Raw Output (last 200 chars):`);
      console.error(content.substring(Math.max(0, content.length - 200)));
      return null;
    }
    
    // We expect 1 question, so take the first element
    const parsed = parsedArray[0];
    
    // Validate structure
    if (!parsed || !parsed.content || !parsed.answer) {
      console.error(`   ❌ Invalid question structure (missing content or answer)`);
      console.error(`   📋 Parsed Object:`, JSON.stringify(parsed, null, 2));
      return null;
    }
    
    // Add metadata
    return {
      content: parsed.content,
      options: parsed.options || [],
      answer: parsed.answer,
      explanation: parsed.explanation || '',
      subject: params.subject,
      grade: params.grade, // ✅ Use 'grade' column name
      difficulty: params.difficulty,
      tags: parsed.tags || [],
      timer_seconds: parsed.timer_seconds || 90,
      is_image_question: false
    };
    
  } catch (err) {
    const duration = ((Date.now() - startTime) / 1000).toFixed(1);
    console.error(`   ❌ API Error (${duration}s): ${err.message}`);
    return null;
  }
}

// ==========================================
// 💾 ATOMIC SAVE TO SUPABASE (One Question)
// ==========================================
async function saveQuestionToSupabase(question) {
  try {
    const response = await httpsRequest(`${SUPABASE_URL}/rest/v1/questions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Prefer': 'return=representation'
      }
    }, question);

    // Check for errors
    if (response.code || response.error) {
      console.error(`   ❌ Supabase Error: ${response.message || response.error}`);
      return false;
    }
    
    if (Array.isArray(response) && response.length > 0) {
      console.log(`   💾 Saved to DB: ${question.subject} - ${question.grade} - ${question.content.substring(0, 50)}...`);
      return true;
    } else {
      console.error(`   ❌ Supabase returned unexpected response`);
      return false;
    }
    
  } catch (err) {
    console.error(`   ❌ Save Error: ${err.message}`);
    return false;
  }
}

// ==========================================
// 🚀 MAIN EXECUTION (ATOMIC MODE)
// ==========================================
async function main() {
  console.log(`🚀 Starting ATOMIC SAVE Mode (Generate → Save → Next)`);
  console.log(`📊 Target: ${TARGET_COUNT} questions`);
  console.log(`⏱️  Timeout: ${TASK_TIMEOUT_MS / 1000}s per question`);
  console.log(`⏳ Delay: ${DELAY_BETWEEN_QUESTIONS / 1000}s between questions`);
  
  if (process.env.TARGET_SUBJECT) {
    console.log(`🎯 TARGET_SUBJECT: ${process.env.TARGET_SUBJECT} (Matrix Mode)`);
  }
  console.log('');
  
  let successCount = 0;
  let failCount = 0;
  let consecutiveFailures = 0;

  for (let i = 1; i <= TARGET_COUNT; i++) {
    console.log(`\\n🔄 [${i}/${TARGET_COUNT}] Generating question...`);
    
    const params = generateRandomParams();
    console.log(`   📚 ${params.subject} - Grade ${params.grade.replace('grand', '')} - ${params.knowledgePoint}`);
    
    // ⚡️ STEP 1: Generate ONE question
    const question = await callDeepSeekAPI(params);
    
    if (!question) {
      failCount++;
      consecutiveFailures++;
      console.log(`   ⚠️  Failed to generate question (${consecutiveFailures} consecutive failures)`);
      
      // ❌ CRITICAL: If 3 consecutive failures, CRASH the job
      if (consecutiveFailures >= MAX_CONSECUTIVE_FAILURES) {
        console.error(`\\n❌ FATAL: ${MAX_CONSECUTIVE_FAILURES} consecutive failures!`);
        console.error(`❌ DeepSeek API may be down or rate-limited.`);
        console.error(`❌ Exiting with error code 1 (GitHub Actions will show RED ❌)`);
        process.exit(1);
      }
      
      await sleep(DELAY_BETWEEN_QUESTIONS);
      continue;
    }
    
    // ⚡️ STEP 2: IMMEDIATELY save to Supabase
    const saved = await saveQuestionToSupabase(question);
    
    if (saved) {
      successCount++;
      consecutiveFailures = 0; // Reset counter on success
      console.log(`   ✅ Success! Total saved: ${successCount}/${i}`);
    } else {
      failCount++;
      consecutiveFailures++;
      console.log(`   ❌ Failed to save (${consecutiveFailures} consecutive failures)`);
      
      if (consecutiveFailures >= MAX_CONSECUTIVE_FAILURES) {
        console.error(`\\n❌ FATAL: ${MAX_CONSECUTIVE_FAILURES} consecutive save failures!`);
        console.error(`❌ Supabase connection may be broken.`);
        process.exit(1);
      }
    }
    
    // ⚡️ STEP 3: Wait before next question
    if (i < TARGET_COUNT) {
      console.log(`   ⏳ Waiting ${DELAY_BETWEEN_QUESTIONS / 1000}s...`);
      await sleep(DELAY_BETWEEN_QUESTIONS);
    }
  }

  // Final Summary
  console.log(`\\n📊 ========== FINAL SUMMARY ==========`);
  console.log(`   ✅ Success: ${successCount}/${TARGET_COUNT}`);
  console.log(`   ❌ Failed: ${failCount}/${TARGET_COUNT}`);
  console.log(`   💾 Questions in Database: ${successCount}`);
  
  // ❌ CRITICAL: If NO questions were saved, EXIT WITH ERROR
  if (successCount === 0) {
    console.error(`\\n❌ FATAL: No questions were saved to the database!`);
    console.error(`❌ GitHub Actions will show as FAILED ❌`);
    process.exit(1);
  }
  
  console.log(`\\n✅ Job Complete! Saved ${successCount} questions.`);
}

// Execute
main().catch(err => {
  console.error('\\n💥 Unexpected Fatal Error:', err);
  process.exit(1);
});
