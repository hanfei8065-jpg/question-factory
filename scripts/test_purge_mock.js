#!/usr/bin/env node

/**
 * ==========================================
 * Mock Test for Legacy Questions Purge Script
 * ==========================================
 * This simulates the script behavior without actual API calls
 */

console.log('🗑️  LEGACY QUESTIONS PURGE SCRIPT (MOCK TEST)\n');
console.log('='.repeat(80));
console.log('📊 Supabase: https://xxx.supabase.co');
console.log('🔧 Mode: 🔍 DRY RUN (Preview Only)');
console.log('='.repeat(80));
console.log();

// ==========================================
// Mock Data
// ==========================================
const mockData = {
  totalQuestions: 150,
  legacyQuestions: 100,
  newQuestions: 50,
  sampleLegacy: [
    {
      id: 'legacy-001',
      subject: '数学',
      grade: 'grand10',
      difficulty: '中级难度',
      timer_seconds: null,
      created_at: '2025-11-20T10:30:00Z'
    },
    {
      id: 'legacy-002',
      subject: '物理',
      grade: 'grand11',
      difficulty: '高级难度',
      timer_seconds: null,
      created_at: '2025-11-21T14:15:00Z'
    },
    {
      id: 'legacy-003',
      subject: '化学',
      grade: 'grand9',
      difficulty: '初级难度',
      timer_seconds: null,
      created_at: '2025-11-22T09:45:00Z'
    },
    {
      id: 'legacy-004',
      subject: '数学',
      grade: 'grand12',
      difficulty: '竞赛难度',
      timer_seconds: null,
      created_at: '2025-11-23T16:20:00Z'
    },
    {
      id: 'legacy-005',
      subject: '物理',
      grade: 'grand10',
      difficulty: '中级难度',
      timer_seconds: null,
      created_at: '2025-11-24T11:00:00Z'
    }
  ]
};

// ==========================================
// Simulate Script Execution
// ==========================================

console.log('📋 STEP 1: Analyzing Database...\n');

console.log('   Database Statistics:');
console.log(`   - Total Questions: ${mockData.totalQuestions}`);
console.log(`   - Legacy Questions (timer_seconds IS NULL): ${mockData.legacyQuestions}`);
console.log(`   - New Quality Questions (timer_seconds IS NOT NULL): ${mockData.newQuestions}`);
console.log();

console.log('🔍 STEP 2: Preview of Legacy Questions to be Deleted:\n');

console.log('   Sample Legacy Questions (first 5):');
mockData.sampleLegacy.forEach((q, i) => {
  console.log(`   ${i + 1}. ID: ${q.id}`);
  console.log(`      Subject: ${q.subject}, Grade: ${q.grade}, Difficulty: ${q.difficulty}`);
  console.log(`      Timer: ${q.timer_seconds === null ? '❌ NULL (Legacy)' : q.timer_seconds}`);
  console.log(`      Created: ${q.created_at}`);
  console.log();
});

console.log('='.repeat(80));
console.log();
console.log('⚠️  DRY RUN MODE - No changes will be made');
console.log();
console.log('📊 Summary:');
console.log(`   - Would delete: ${mockData.legacyQuestions} legacy questions`);
console.log(`   - Would keep: ${mockData.newQuestions} new quality questions`);
console.log();
console.log('🚀 To execute the deletion, run:');
console.log('   node scripts/purge_legacy_questions.js --confirm');
console.log('='.repeat(80));
console.log();

// ==========================================
// Simulate Confirm Mode
// ==========================================

const isConfirmMode = process.argv.includes('--confirm');

if (isConfirmMode) {
  console.log();
  console.log('⚠️  CONFIRM MODE ACTIVE - Deleting legacy questions...\n');
  
  // Simulate deletion delay
  setTimeout(() => {
    console.log('✅ Deletion successful!\n');
    
    console.log('📊 Final Database State:');
    console.log(`   - Deleted: ${mockData.legacyQuestions} legacy questions`);
    console.log(`   - Remaining Legacy: 0 (should be 0)`);
    console.log(`   - Remaining New Quality Questions: ${mockData.newQuestions}`);
    console.log();
    console.log('✅ Database cleanup complete! All legacy questions removed.');
    console.log('='.repeat(80));
  }, 1000);
} else {
  console.log('💡 TIP: This is a mock test. To test with real Supabase:');
  console.log('   1. Ensure your .env has valid SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
  console.log('   2. Run: node scripts/purge_legacy_questions.js');
  console.log();
}
