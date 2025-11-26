const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

(async () => {
  const { data, error } = await supabase.from('questions').select('id').limit(1);
  if (error) {
    console.error('Supabase连接失败:', error.message);
  } else {
    console.log('Supabase连接成功，示例数据:', data);
  }
})();
