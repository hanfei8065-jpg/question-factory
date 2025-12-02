#!/usr/bin/env node

/**
 * 测试脚本：验证双语标签生成
 * 
 * 运行方法:
 *   node question-factory/test_bilingual_tags.js
 * 
 * 预期输出:
 *   - DeepSeek 应该返回 "English (中文)" 格式的标签
 *   - tags 字段不应被覆盖
 */

const https = require('https');

const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY || 'sk-c80e575eabed4d039b34d59fe62dd3fd';

// 简化版 Prompt
function buildTestPrompt() {
  return `
ROLE: You are an expert US K-12 Curriculum Designer.
TASK: Generate EXACTLY 1 high-quality Mathematics question.
CONTEXT: Grade 10, Topic: Linear Equations, Difficulty: Medium.

### CRITICAL RULES:
1. **OUTPUT FORMAT**: Return ONLY a valid JSON array. NO markdown formatting.
2. **LANGUAGE**: Question content in English.
3. **OPTIONS**: Provide exactly 4 options ["A)...", "B)...", "C)...", "D)..."].
4. **TAGS**: Generate 2-3 bilingual tags in format "English (Chinese)". Use standard Mainland China textbook terminology (人教版标准).
   - Math example: ["Linear Equations (一元一次方程)", "Slope (斜率)", "Graphing (函数图像)"]
   - CRITICAL: Chinese must match standard textbook terms.

### JSON STRUCTURE TEMPLATE:
[
  {
    "content": "Question text here.",
    "options": ["A) 1", "B) 2", "C) 3", "D) 4"],
    "answer": "B", 
    "explanation": "Step-by-step logic.",
    "tags": ["Linear Equations (一元一次方程)", "Algebra (代数)"],
    "timer_seconds": 60
  }
]

NOW GENERATE 1 QUESTION:
`;
}

// HTTPS 请求
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

// 主测试函数
async function testBilingualTags() {
  console.log('🧪 [Test] 开始测试双语标签生成...\n');

  try {
    const prompt = buildTestPrompt();
    
    console.log('📤 发送请求到 DeepSeek API...');
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
      max_tokens: 1500
    });

    if (!response.choices || !response.choices[0]) {
      console.error('❌ DeepSeek API 无响应');
      return;
    }

    const content = response.choices[0].message.content;
    console.log('\n📥 DeepSeek 原始响应:\n');
    console.log(content);
    console.log('\n' + '='.repeat(80) + '\n');

    // 解析 JSON
    const cleanContent = content.replace(/```json/g, '').replace(/```/g, '').trim();
    const questions = JSON.parse(cleanContent);

    if (!Array.isArray(questions) || questions.length === 0) {
      console.error('❌ 解析失败：返回内容不是数组');
      return;
    }

    const q = questions[0];
    
    console.log('✅ 解析成功！题目数据:\n');
    console.log('题目内容:', q.content);
    console.log('选项:', q.options);
    console.log('答案:', q.answer);
    console.log('\n🏷️  标签字段 (CRITICAL):');
    console.log('   Raw tags:', JSON.stringify(q.tags, null, 2));
    console.log('\n📊 验证结果:\n');

    // 验证逻辑
    let allPass = true;

    // 检查 1: tags 字段存在
    if (!q.tags || !Array.isArray(q.tags)) {
      console.log('❌ FAIL: tags 字段缺失或不是数组');
      allPass = false;
    } else {
      console.log('✅ PASS: tags 字段存在且为数组');
    }

    // 检查 2: 至少有 2 个标签
    if (q.tags && q.tags.length >= 2) {
      console.log('✅ PASS: 标签数量符合要求 (>= 2)');
    } else {
      console.log(`❌ FAIL: 标签数量不足 (${q.tags?.length || 0})`);
      allPass = false;
    }

    // 检查 3: 双语格式验证
    if (q.tags && q.tags.length > 0) {
      const bilingualPattern = /^.+\s*\(.+\)$/;
      let bilingualCount = 0;
      
      q.tags.forEach((tag, idx) => {
        if (bilingualPattern.test(tag)) {
          console.log(`✅ PASS: Tag ${idx + 1} 符合双语格式 - "${tag}"`);
          bilingualCount++;
        } else {
          console.log(`❌ FAIL: Tag ${idx + 1} 不符合双语格式 - "${tag}"`);
          allPass = false;
        }
      });

      if (bilingualCount === q.tags.length) {
        console.log(`✅ PASS: 所有标签 (${bilingualCount}/${q.tags.length}) 都是双语格式`);
      }
    }

    console.log('\n' + '='.repeat(80));
    console.log(allPass ? '\n🎉 测试通过！双语标签功能正常工作！' : '\n⚠️  测试失败，请检查 Prompt 或 API 响应');
    console.log('='.repeat(80) + '\n');

  } catch (err) {
    console.error('❌ 测试失败:', err.message);
    console.error(err.stack);
  }
}

// 执行测试
testBilingualTags();
