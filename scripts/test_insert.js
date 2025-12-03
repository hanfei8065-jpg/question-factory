#!/usr/bin/env node

// Test insert to find the correct column names
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

function httpsRequest(url, options, data) {
  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        console.log('Response status:', res.statusCode);
        console.log('Response headers:', res.headers);
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

async function testInsert() {
  console.log('🧪 Testing insert with complete required fields...\n');
  
  const testRow = {
    content: "Test visual question with SVG",
    options: ["Option A", "Option B", "Option C", "Option D"],  // Array format
    answer: "A",
    svg_diagram: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" stroke="black" stroke-width="2" fill="none"/></svg>'
  };
  
  try {
    const response = await httpsRequest(
      `${SUPABASE_URL}/rest/v1/questions`,
      {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`,
          'Content-Type': 'application/json',
          'Prefer': 'return=representation'
        }
      },
      [testRow]
    );

    console.log('\n📊 Response:');
    console.log(JSON.stringify(response, null, 2));
    
    if (Array.isArray(response) && response.length > 0) {
      console.log('\n✅ SUCCESS! Inserted row. Schema:');
      Object.keys(response[0]).forEach(col => {
        console.log(`   - ${col}: ${typeof response[0][col]} = ${JSON.stringify(response[0][col]).substring(0, 60)}`);
      });
    }
  } catch (err) {
    console.error('\n❌ Error:', err.message);
  }
}

testInsert();
