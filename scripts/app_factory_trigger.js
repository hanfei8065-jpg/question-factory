// app_factory_trigger.js
// 只做云函数触发，不做本地产题逻辑



const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_KEY environment variable.');
  process.exit(1);
}
const API_URL = `${SUPABASE_URL}/functions/v1/question-factory-v542?lang=en`;
const API_KEY = SUPABASE_SERVICE_KEY;

async function triggerFactory() {
  try {
    const res = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
    });
    const data = await res.json();
    console.log('Factory response:', data);
  } catch (err) {
    console.error('Error triggering factory:', err);
    process.exit(1);
  }
}

triggerFactory();
