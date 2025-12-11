#!/usr/bin/env node

/**
 * 查询题库时间线
 * 显示第一道题和最后一道题的生成时间
 */

const https = require('https');

const SUPABASE_URL = 'https://wsoilhwdxncnumzttbaz.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indzb2lsaHdkeG5jbnVtenR0YmF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyMDk1NDksImV4cCI6MjA3Nzc4NTU0OX0.XXgTbuqXA0McFo17xakcRvGuX0ilkJfYIVpQ4JTxF_k';

function httpsRequest(url, options) {
  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(body));
        } catch (e) {
          console.error('解析响应失败:', body);
          reject(e);
        }
      });
    });
    
    req.on('error', reject);
    req.end();
  });
}

async function checkTimeline() {
  console.log('\n📅 题库时间线查询\n');
  console.log('='.repeat(60));
  
  try {
    // 查询最早的题目
    console.log('\n🔍 查询第一道题...');
    const earliest = await httpsRequest(
      `${SUPABASE_URL}/rest/v1/questions?select=id,problem_text,created_at&order=created_at.asc&limit=1`,
      {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    // 查询最晚的题目
    console.log('🔍 查询最后一道题...');
    const latest = await httpsRequest(
      `${SUPABASE_URL}/rest/v1/questions?select=id,problem_text,created_at&order=created_at.desc&limit=1`,
      {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    // 查询总题数
    console.log('🔍 查询总题数...');
    const count = await httpsRequest(
      `${SUPABASE_URL}/rest/v1/questions?select=count`,
      {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
          'Prefer': 'count=exact'
        }
      }
    );
    
    console.log('\n' + '='.repeat(60));
    console.log('\n✅ 查询成功!\n');
    
    if (earliest.length > 0 && latest.length > 0) {
      const firstTime = new Date(earliest[0].created_at);
      const lastTime = new Date(latest[0].created_at);
      
      console.log('📌 第一道题:');
      console.log('   时间:', firstTime.toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' }));
      console.log('   题目:', (earliest[0].problem_text || '').substring(0, 50) + '...');
      console.log('   ID:', earliest[0].id);
      
      console.log('\n📌 最后一道题:');
      console.log('   时间:', lastTime.toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' }));
      console.log('   题目:', (latest[0].problem_text || '').substring(0, 50) + '...');
      console.log('   ID:', latest[0].id);
      
      // 计算时间跨度
      const diffMs = lastTime - firstTime;
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
      const diffHours = Math.floor((diffMs % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
      const diffSeconds = Math.floor((diffMs % (1000 * 60)) / 1000);
      
      console.log('\n⏱️  时间跨度:');
      console.log(`   ${diffDays} 天 ${diffHours} 小时 ${diffMinutes} 分钟 ${diffSeconds} 秒`);
      
      // 计算题目总数
      console.log('\n📊 题库统计:');
      console.log('   总题数:', count[0]?.count || 'N/A');
      
      if (count[0]?.count && diffMs > 0) {
        const totalMinutes = diffMs / (1000 * 60);
        const questionsPerMinute = count[0].count / totalMinutes;
        console.log(`   生成速度: ${questionsPerMinute.toFixed(2)} 题/分钟`);
      }
      
    } else {
      console.log('⚠️  未找到题目数据');
    }
    
    console.log('\n' + '='.repeat(60) + '\n');
    
  } catch (error) {
    console.error('\n❌ 查询失败:', error.message);
    process.exit(1);
  }
}

checkTimeline();
