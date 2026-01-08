// app_factory_trigger.js - 激活指令：包含语言、学科和年级参数
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_KEY.');
  process.exit(1);
}

// 这里你可以手动修改参数来激活特定任务：
// lang: zh (中文) / en (英文)
// subject: Math / Physics
// grade: 10 / 11 / 12
const PARAMS = "subject=Math&grade=10&lang=zh"; 

const API_URL = `${SUPABASE_URL}/functions/v1/question-factory-v542?${PARAMS}`;
const API_KEY = SUPABASE_SERVICE_KEY;

async function triggerFactory() {
  console.log(`🚀 正在激活工厂生产线: [${PARAMS}]`);
  try {
    const res = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
    });
    const data = await res.json();
    console.log('✅ 工厂反馈:', data);
  } catch (err) {
    console.error('❌ 激活失败:', err);
    process.exit(1);
  }
}

triggerFactory();