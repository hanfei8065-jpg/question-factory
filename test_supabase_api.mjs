// ES Module 语法，兼容 node-fetch v3 及以上
import fetch from 'node-fetch';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

async function testSupabase() {
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/?apikey=${SUPABASE_SERVICE_ROLE_KEY}`);
    if (res.ok) {
      console.log('Supabase API 连接成功！');
      console.log('状态码:', res.status);
    } else {
      console.log('Supabase API 连接失败，状态码:', res.status);
      const text = await res.text();
      console.log('返回内容:', text);
    }
  } catch (err) {
    console.error('请求异常:', err);
  }
}

testSupabase();
