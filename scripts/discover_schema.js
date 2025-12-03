#!/usr/bin/env node

// Get actual columns by trying different column names
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

async function discoverSchema() {
  console.log('🔬 Discovering actual schema by querying all columns...\n');
  
  // Try to get ALL columns by using select=*
  const response = await httpsRequest(
    `${SUPABASE_URL}/rest/v1/questions?limit=1`,  // Get just 1 row with all columns
    {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json'
      }
    }
  );

  console.log('📊 Response:');
  console.log(JSON.stringify(response, null, 2));
  
  if (Array.isArray(response) && response.length > 0) {
    console.log('\n✅ Found columns:');
    Object.keys(response[0]).forEach(col => {
      console.log(`   - ${col}: ${typeof response[0][col]}`);
    });
  } else if (Array.isArray(response) && response.length === 0) {
    console.log('\n⚠️ Table is empty, trying to describe schema via OPTIONS...');
  } else {
    console.log('\n❌ Unexpected response format');
  }
}

discoverSchema().catch(console.error);
