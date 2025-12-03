#!/usr/bin/env node

// Check the actual schema of questions table
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

async function checkSchema() {
  console.log('🔍 Fetching first question to see actual schema...\n');
  
  try {
    const response = await httpsRequest(
      `${SUPABASE_URL}/rest/v1/questions?limit=1`,
      {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    if (Array.isArray(response) && response.length > 0) {
      console.log('✅ Actual column names in questions table:');
      console.log(JSON.stringify(Object.keys(response[0]), null, 2));
      console.log('\n📋 Full sample row:');
      console.log(JSON.stringify(response[0], null, 2));
    } else {
      console.log('⚠️  No questions in table or error:', response);
    }
  } catch (err) {
    console.error('❌ Error:', err.message);
  }
}

checkSchema();
