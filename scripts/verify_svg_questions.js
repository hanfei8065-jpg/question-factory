#!/usr/bin/env node

// Quick script to verify SVG questions in Supabase
const https = require('https');
const fs = require('fs');
const path = require('path');

// Load .env
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

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

function httpsRequest(url, options) {
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
    req.end();
  });
}

async function checkSVGQuestions() {
  console.log('🔍 Checking for SVG questions in Supabase...\n');
  
  try {
    // Query for questions with SVG diagrams (using correct column: grade, not grade_level)
    const response = await httpsRequest(
      `${SUPABASE_URL}/rest/v1/questions?svg_diagram=not.is.null&select=id,subject,grade,problem_text,svg_diagram&limit=10`,
      {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    if (Array.isArray(response)) {
      console.log(`✅ Found ${response.length} questions with SVG diagrams:\n`);
      response.forEach((q, i) => {
        console.log(`${i + 1}. ID: ${q.id}`);
        console.log(`   Subject: ${q.subject}, Grade: ${q.grade}`);
        console.log(`   Question: ${q.problem_text.substring(0, 80)}...`);
        console.log(`   SVG Size: ${q.svg_diagram ? q.svg_diagram.length : 0} chars`);
        console.log(`   SVG Preview: ${q.svg_diagram ? q.svg_diagram.substring(0, 100) : 'N/A'}...`);
        console.log('');
      });
    } else {
      console.error('❌ Unexpected response:', response);
    }
  } catch (err) {
    console.error('❌ Error:', err.message);
  }
}

checkSVGQuestions();
