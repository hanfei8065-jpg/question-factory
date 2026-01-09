// [LEARNEST_FACTORY_TRIGGER_V2.0_HYPER_DRIVE]
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('❌ 缺失环境变量 SUPABASE_URL 或 SUPABASE_SERVICE_KEY');
  process.exit(1);
}

// --- 配置池：让 25 个机器人随机分配任务，全线开工 ---
const SUBJECTS = ['math', 'physics', 'chemistry', 'math_olympiad'];
const GRADES = ['grade1', 'grade2', 'grade3', 'grade7', 'grade8', 'grade9', 'grade10', 'grade11', 'grade12'];
const LANGS = ['zh', 'en'];

async function triggerSingleTask() {
  // 随机挑选任务参数
  const subject = SUBJECTS[Math.floor(Math.random() * SUBJECTS.length)];
  const grade = GRADES[Math.floor(Math.random() * GRADES.length)];
  const lang = LANGS[Math.floor(Math.random() * LANGS.length)];
  
  const PARAMS = `subject_id=${subject}&grade_id=${grade}&lang=${lang}`;
  const API_URL = `${SUPABASE_URL}/functions/v1/question-factory-v542?${PARAMS}`;

  try {
    const res = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json',
      },
    });
    const data = await res.json();
    console.log(`✅ 生产成功 [${lang}-${subject}-${grade}]:`, data.count || '1道题');
  } catch (err) {
    console.error(`❌ 生产失败 [${PARAMS}]:`, err.message);
  }
}

// --- 核心超频逻辑：每个机器人连续执行 10 次任务 ---
async function runHyperDrive() {
  const TOTAL_REPEATS = 10; // 每个机器人产 10 次题
  console.log(`🚀 启动超频模式：并行机器人已就绪，预计本轮产题总量: ${25 * TOTAL_REPEATS}`);

  for (let i = 0; i < TOTAL_REPEATS; i++) {
    console.log(`📡 正在发送第 ${i + 1}/${TOTAL_REPEATS} 波指令...`);
    await triggerSingleTask();
    // 稍微停 2 秒，防止 API 压力过大被封
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
  console.log('🏁 本机器人任务已全部完成。');
}

runHyperDrive();