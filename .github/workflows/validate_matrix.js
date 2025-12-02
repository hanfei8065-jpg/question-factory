#!/usr/bin/env node

// ==========================================
// Matrix Mode Validation Script
// ==========================================
// Purpose: Validate GitHub Actions matrix configuration
// and simulate expected throughput

const fs = require('fs');
const yaml = require('js-yaml'); // Note: Requires `npm install js-yaml` to run

console.log('🔍 VALIDATING MATRIX MODE CONFIGURATION\n');
console.log('='.repeat(80));

// ==========================================
// 1. Read and Parse YAML
// ==========================================
const workflowPath = '.github/workflows/question-factory-new.yml';

let workflowContent;
try {
  workflowContent = fs.readFileSync(workflowPath, 'utf8');
  console.log(`✅ Loaded workflow file: ${workflowPath}\n`);
} catch (error) {
  console.error(`❌ Failed to read workflow file: ${error.message}`);
  process.exit(1);
}

let workflow;
try {
  workflow = yaml.load(workflowContent);
  console.log('✅ Successfully parsed YAML\n');
} catch (error) {
  console.error(`❌ YAML parsing error: ${error.message}`);
  process.exit(1);
}

// ==========================================
// 2. Extract Matrix Configuration
// ==========================================
const job = workflow.jobs['generate-questions-matrix'];
if (!job) {
  console.error('❌ Job "generate-questions-matrix" not found!');
  process.exit(1);
}

const matrix = job.strategy?.matrix;
if (!matrix) {
  console.error('❌ Matrix strategy not defined!');
  process.exit(1);
}

const subjects = matrix.subject || [];
const batches = matrix.batch || [];
const maxParallel = job.strategy['max-parallel'] || 0;
const failFast = job.strategy['fail-fast'];

console.log('📋 MATRIX CONFIGURATION:');
console.log(`   Subjects: ${subjects.join(', ')}`);
console.log(`   Batches: ${batches.join(', ')}`);
console.log(`   Max Parallel: ${maxParallel}`);
console.log(`   Fail Fast: ${failFast}`);
console.log();

// ==========================================
// 3. Calculate Expected Throughput
// ==========================================
const totalJobs = subjects.length * batches.length;
const questionsPerJob = 3; // Each job generates 3 questions
const questionsPerRun = totalJobs * questionsPerJob;

console.log('📊 EXPECTED THROUGHPUT:');
console.log(`   Total Matrix Jobs: ${totalJobs} (${subjects.length} subjects × ${batches.length} batches)`);
console.log(`   Questions per Job: ${questionsPerJob}`);
console.log(`   Questions per Run: ${questionsPerRun}`);
console.log();

// ==========================================
// 4. Schedule Analysis
// ==========================================
const schedule = workflow.on?.schedule?.[0]?.cron;
console.log('📅 SCHEDULE ANALYSIS:');
console.log(`   Cron: ${schedule || 'Not configured'}`);

if (schedule === '0 */6 * * *') {
  const runsPerDay = 4;
  const questionsPerDay = questionsPerRun * runsPerDay;
  const questionsPerMonth = questionsPerDay * 30;
  
  console.log(`   Frequency: Every 6 hours`);
  console.log(`   Runs per Day: ${runsPerDay}`);
  console.log(`   Questions per Day: ${questionsPerDay}`);
  console.log(`   Questions per Month: ${questionsPerMonth.toLocaleString()}`);
} else {
  console.log('   ⚠️  Non-standard cron schedule');
}
console.log();

// ==========================================
// 5. Validate Matrix Combinations
// ==========================================
console.log('🔍 VALIDATING MATRIX COMBINATIONS:\n');

const combinations = [];
subjects.forEach(subject => {
  batches.forEach(batch => {
    const jobName = `${subject}-batch-${batch}`;
    combinations.push({ subject, batch, jobName });
  });
});

console.log(`   Total Combinations: ${combinations.length}`);
console.log('\n   First 5 jobs:');
combinations.slice(0, 5).forEach((combo, i) => {
  console.log(`   ${i + 1}. ${combo.jobName}`);
});

console.log('   ...');

console.log(`\n   Last 5 jobs:`);
combinations.slice(-5).forEach((combo, i) => {
  console.log(`   ${combinations.length - 4 + i}. ${combo.jobName}`);
});
console.log();

// ==========================================
// 6. GitHub Actions Limits Check
// ==========================================
console.log('⚠️  GITHUB ACTIONS LIMITS CHECK:');

const githubFreeLimits = {
  maxParallel: 20,
  minutesPerMonth: 2000,
  storageGB: 0.5
};

const githubProLimits = {
  maxParallel: 60,
  minutesPerMonth: 3000,
  storageGB: 2
};

console.log('\n   Free Tier Limits:');
console.log(`   - Max Parallel Jobs: ${githubFreeLimits.maxParallel}`);
console.log(`   - Minutes/Month: ${githubFreeLimits.minutesPerMonth}`);
console.log(`   - Storage: ${githubFreeLimits.storageGB} GB`);

if (maxParallel > githubFreeLimits.maxParallel) {
  console.log(`   ⚠️  WARNING: max-parallel (${maxParallel}) exceeds Free tier limit!`);
  console.log(`   → Upgrade to Pro or reduce max-parallel to ${githubFreeLimits.maxParallel}`);
} else {
  console.log(`   ✅ max-parallel (${maxParallel}) within Free tier limits`);
}

// Estimate minutes usage per run (assuming 3 min per job)
const minutesPerJob = 3;
const minutesPerRun = minutesPerJob * Math.ceil(totalJobs / maxParallel);
const runsPerMonth = 4 * 30; // 4 runs/day × 30 days
const totalMinutesPerMonth = minutesPerRun * runsPerMonth;

console.log(`\n   Estimated Usage:`);
console.log(`   - Minutes per Job: ~${minutesPerJob}`);
console.log(`   - Minutes per Run: ~${minutesPerRun} (${totalJobs} jobs / ${maxParallel} parallel)`);
console.log(`   - Runs per Month: ${runsPerMonth}`);
console.log(`   - Total Minutes/Month: ~${totalMinutesPerMonth}`);

if (totalMinutesPerMonth > githubFreeLimits.minutesPerMonth) {
  console.log(`   ⚠️  WARNING: Estimated usage exceeds Free tier limit!`);
  console.log(`   → Consider reducing frequency or upgrading to Pro`);
} else {
  console.log(`   ✅ Estimated usage within Free tier limits`);
}
console.log();

// ==========================================
// 7. API Rate Limit Estimation
// ==========================================
console.log('🌐 DEEPSEEK API RATE LIMIT CHECK:');

const deepseekLimits = {
  requestsPerMinute: 50,
  requestsPerDay: 10000
};

console.log(`   Rate Limits:`);
console.log(`   - Requests/Minute: ${deepseekLimits.requestsPerMinute}`);
console.log(`   - Requests/Day: ${deepseekLimits.requestsPerDay}`);

const requestsPerJob = 1; // Each job = 1 DeepSeek API call
const requestsPerRun = totalJobs * requestsPerJob;
const requestsPerDay = requestsPerRun * 4; // 4 runs per day

console.log(`\n   Expected Usage:`);
console.log(`   - Requests per Job: ${requestsPerJob}`);
console.log(`   - Requests per Run: ${requestsPerRun}`);
console.log(`   - Requests per Day: ${requestsPerDay}`);

if (requestsPerRun > deepseekLimits.requestsPerMinute) {
  console.log(`   ⚠️  WARNING: ${requestsPerRun} parallel requests may exceed rate limit!`);
  console.log(`   → Consider reducing max-parallel or adding delays`);
} else {
  console.log(`   ✅ Requests per run (${requestsPerRun}) within rate limits`);
}

if (requestsPerDay > deepseekLimits.requestsPerDay) {
  console.log(`   ⚠️  WARNING: Daily requests (${requestsPerDay}) exceed limit!`);
} else {
  console.log(`   ✅ Daily requests (${requestsPerDay}) within limits`);
}
console.log();

// ==========================================
// 8. Final Summary
// ==========================================
console.log('='.repeat(80));
console.log('🎉 VALIDATION SUMMARY:\n');

const checks = [
  {
    name: 'YAML Syntax',
    pass: workflow !== null,
    details: 'Workflow file parsed successfully'
  },
  {
    name: 'Matrix Configuration',
    pass: totalJobs === 20,
    details: `${totalJobs} total jobs (expected: 20)`
  },
  {
    name: 'Max Parallel Setting',
    pass: maxParallel === 20,
    details: `max-parallel = ${maxParallel}`
  },
  {
    name: 'Fail Fast Disabled',
    pass: failFast === false,
    details: 'Jobs continue on failure'
  },
  {
    name: 'GitHub Free Tier Compliance',
    pass: maxParallel <= githubFreeLimits.maxParallel && totalMinutesPerMonth <= githubFreeLimits.minutesPerMonth,
    details: maxParallel <= githubFreeLimits.maxParallel ? 'Within limits' : 'Exceeds limits'
  }
];

checks.forEach(check => {
  const icon = check.pass ? '✅' : '❌';
  console.log(`${icon} ${check.name}`);
  console.log(`   ${check.details}\n`);
});

const allPass = checks.every(c => c.pass);

console.log('='.repeat(80));
if (allPass) {
  console.log('✅ ALL CHECKS PASSED - Matrix Mode Ready for Deployment!');
} else {
  console.log('⚠️  SOME CHECKS FAILED - Review warnings above');
}
console.log('='.repeat(80));

// Exit with appropriate code
process.exit(allPass ? 0 : 1);
