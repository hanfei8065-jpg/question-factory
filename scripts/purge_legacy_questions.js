#!/usr/bin/env node

/**
 * ==========================================
 * Legacy Questions Purge Script
 * ==========================================
 * Purpose: Remove old questions (before Golden Standard upgrade)
 * 
 * Logic:
 * - Legacy Questions: timer_seconds IS NULL (old format)
 * - New Questions: timer_seconds IS NOT NULL (Matrix Factory output)
 * 
 * Safety: Dry-run mode by default, requires --confirm flag to execute
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// ==========================================
// Load Environment Variables from .env
// ==========================================
function loadEnv() {
  const envPath = path.join(__dirname, '..', '.env');
  
  if (!fs.existsSync(envPath)) {
    console.warn('⚠️  Warning: .env file not found, using process.env');
    return;
  }
  
  const envContent = fs.readFileSync(envPath, 'utf8');
  const lines = envContent.split('\n');
  
  lines.forEach(line => {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) return;
    
    const [key, ...valueParts] = trimmed.split('=');
    const value = valueParts.join('=').replace(/^["']|["']$/g, ''); // Remove quotes
    
    if (key && value) {
      process.env[key.trim()] = value.trim();
    }
  });
}

loadEnv();

// ==========================================
// Configuration
// ==========================================
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

// Check if running in confirm mode
const isDryRun = !process.argv.includes('--confirm');

// ==========================================
// Utility Functions
// ==========================================

/**
 * Execute Supabase REST API request
 */
function supabaseRequest(method, endpoint, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(endpoint, `${SUPABASE_URL}/rest/v1/`);
    
    const options = {
      method: method,
      headers: {
        'apikey': SUPABASE_SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      }
    };

    const req = https.request(url, options, (res) => {
      let data = '';
      
      res.on('data', chunk => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsed = data ? JSON.parse(data) : {};
          resolve({ status: res.statusCode, data: parsed, headers: res.headers });
        } catch (e) {
          resolve({ status: res.statusCode, data: data, headers: res.headers });
        }
      });
    });

    req.on('error', reject);
    
    if (body) {
      req.write(JSON.stringify(body));
    }
    
    req.end();
  });
}

/**
 * Count questions matching criteria
 */
async function countQuestions(whereClause) {
  const response = await supabaseRequest(
    'GET',
    `questions?select=count&${whereClause}`
  );
  
  // Parse count from Content-Range header (e.g., "0-9/10" means 10 total)
  const contentRange = response.headers['content-range'];
  if (contentRange) {
    const match = contentRange.match(/\/(\d+)$/);
    return match ? parseInt(match[1]) : 0;
  }
  
  return 0;
}

/**
 * Delete questions matching criteria
 */
async function deleteQuestions(whereClause) {
  const response = await supabaseRequest(
    'DELETE',
    `questions?${whereClause}`
  );
  
  return response;
}

/**
 * Get sample questions for preview
 */
async function getSampleQuestions(whereClause, limit = 5) {
  const response = await supabaseRequest(
    'GET',
    `questions?select=id,subject,grade,difficulty,timer_seconds,created_at&${whereClause}&limit=${limit}`
  );
  
  return response.data;
}

// ==========================================
// Main Script
// ==========================================

async function main() {
  console.log('🗑️  LEGACY QUESTIONS PURGE SCRIPT\n');
  console.log('='.repeat(80));
  
  // Validate environment variables
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    console.error('❌ ERROR: Missing environment variables');
    console.error('   Please ensure .env contains:');
    console.error('   - SUPABASE_URL');
    console.error('   - SUPABASE_SERVICE_ROLE_KEY');
    process.exit(1);
  }

  console.log(`📊 Supabase: ${SUPABASE_URL}`);
  console.log(`🔧 Mode: ${isDryRun ? '🔍 DRY RUN (Preview Only)' : '⚠️  CONFIRM (Will Delete)'}`);
  console.log('='.repeat(80));
  console.log();

  // ==========================================
  // Step 1: Count Legacy Questions
  // ==========================================
  console.log('📋 STEP 1: Analyzing Database...\n');

  const legacyCount = await countQuestions('timer_seconds=is.null');
  const newCount = await countQuestions('timer_seconds=not.is.null');
  const totalCount = legacyCount + newCount;

  console.log('   Database Statistics:');
  console.log(`   - Total Questions: ${totalCount}`);
  console.log(`   - Legacy Questions (timer_seconds IS NULL): ${legacyCount}`);
  console.log(`   - New Quality Questions (timer_seconds IS NOT NULL): ${newCount}`);
  console.log();

  if (legacyCount === 0) {
    console.log('✅ No legacy questions found. Database is clean!');
    console.log('='.repeat(80));
    process.exit(0);
  }

  // ==========================================
  // Step 2: Preview Legacy Questions
  // ==========================================
  console.log('🔍 STEP 2: Preview of Legacy Questions to be Deleted:\n');

  const sampleLegacy = await getSampleQuestions('timer_seconds=is.null', 5);
  
  if (sampleLegacy && sampleLegacy.length > 0) {
    console.log('   Sample Legacy Questions (first 5):');
    sampleLegacy.forEach((q, i) => {
      console.log(`   ${i + 1}. ID: ${q.id}`);
      console.log(`      Subject: ${q.subject || 'N/A'}, Grade: ${q.grade || 'N/A'}, Difficulty: ${q.difficulty || 'N/A'}`);
      console.log(`      Timer: ${q.timer_seconds === null ? '❌ NULL (Legacy)' : q.timer_seconds}`);
      console.log(`      Created: ${q.created_at || 'N/A'}`);
      console.log();
    });
  }

  // ==========================================
  // Step 3: Deletion Decision
  // ==========================================
  console.log('='.repeat(80));
  console.log();

  if (isDryRun) {
    console.log('⚠️  DRY RUN MODE - No changes will be made');
    console.log();
    console.log('📊 Summary:');
    console.log(`   - Would delete: ${legacyCount} legacy questions`);
    console.log(`   - Would keep: ${newCount} new quality questions`);
    console.log();
    console.log('🚀 To execute the deletion, run:');
    console.log('   node scripts/purge_legacy_questions.js --confirm');
    console.log('='.repeat(80));
    process.exit(0);
  }

  // ==========================================
  // Step 4: Execute Deletion (Confirm Mode)
  // ==========================================
  console.log('⚠️  CONFIRM MODE ACTIVE - Deleting legacy questions...\n');

  const deleteResponse = await deleteQuestions('timer_seconds=is.null');

  if (deleteResponse.status >= 200 && deleteResponse.status < 300) {
    console.log('✅ Deletion successful!\n');
    
    // Recount to verify
    const remainingLegacy = await countQuestions('timer_seconds=is.null');
    const remainingNew = await countQuestions('timer_seconds=not.is.null');
    
    console.log('📊 Final Database State:');
    console.log(`   - Deleted: ${legacyCount} legacy questions`);
    console.log(`   - Remaining Legacy: ${remainingLegacy} (should be 0)`);
    console.log(`   - Remaining New Quality Questions: ${remainingNew}`);
    console.log();
    
    if (remainingLegacy === 0) {
      console.log('✅ Database cleanup complete! All legacy questions removed.');
    } else {
      console.log('⚠️  Warning: Some legacy questions may still remain.');
    }
  } else {
    console.error('❌ Deletion failed!');
    console.error(`   Status: ${deleteResponse.status}`);
    console.error(`   Response: ${JSON.stringify(deleteResponse.data, null, 2)}`);
    process.exit(1);
  }

  console.log('='.repeat(80));
}

// ==========================================
// Error Handling & Execution
// ==========================================

main().catch(error => {
  console.error('\n❌ SCRIPT ERROR:');
  console.error(error);
  process.exit(1);
});
