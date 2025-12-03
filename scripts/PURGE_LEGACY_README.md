# Legacy Questions Purge Script

## Purpose
Remove old questions (produced before Matrix Factory upgrade) while preserving new high-quality questions.

---

## Logic

### Question Classification

| Type | Criteria | Source | Quality |
|------|----------|--------|---------|
| **Legacy Questions** | `timer_seconds IS NULL` | Old sequential factory | Low (no timer, no CoT, no SAT alignment) |
| **New Questions** | `timer_seconds IS NOT NULL` | Matrix Factory with Golden Standard | High (30/60/90s timer, CoT logic, SAT/AMC aligned) |

---

## Safety Features

### Dry-Run Mode (Default)
- **Preview** what will be deleted without making changes
- **Counts** legacy vs. new questions
- **Shows** sample legacy questions (first 5)
- **Requires** `--confirm` flag to execute deletion

### Confirm Mode
- **Deletes** only legacy questions (`timer_seconds IS NULL`)
- **Preserves** all new quality questions
- **Verifies** deletion by recounting after operation

---

## Usage

### 1. Preview (Dry-Run Mode)
```bash
node scripts/purge_legacy_questions.js
```

**Output Example:**
```
🗑️  LEGACY QUESTIONS PURGE SCRIPT
================================================================================
📊 Supabase: https://xxx.supabase.co
🔧 Mode: 🔍 DRY RUN (Preview Only)
================================================================================

📋 STEP 1: Analyzing Database...

   Database Statistics:
   - Total Questions: 150
   - Legacy Questions (timer_seconds IS NULL): 100
   - New Quality Questions (timer_seconds IS NOT NULL): 50

🔍 STEP 2: Preview of Legacy Questions to be Deleted:

   Sample Legacy Questions (first 5):
   1. ID: 123
      Subject: math, Grade: grand10, Difficulty: 中级难度
      Timer: ❌ NULL (Legacy)
      Created: 2025-11-20T10:30:00Z

   ... (4 more)

================================================================================

⚠️  DRY RUN MODE - No changes will be made

📊 Summary:
   - Would delete: 100 legacy questions
   - Would keep: 50 new quality questions

🚀 To execute the deletion, run:
   node scripts/purge_legacy_questions.js --confirm
================================================================================
```

---

### 2. Execute Deletion (Confirm Mode)
```bash
node scripts/purge_legacy_questions.js --confirm
```

**Output Example:**
```
🗑️  LEGACY QUESTIONS PURGE SCRIPT
================================================================================
📊 Supabase: https://xxx.supabase.co
🔧 Mode: ⚠️  CONFIRM (Will Delete)
================================================================================

📋 STEP 1: Analyzing Database...

   Database Statistics:
   - Total Questions: 150
   - Legacy Questions (timer_seconds IS NULL): 100
   - New Quality Questions (timer_seconds IS NOT NULL): 50

⚠️  CONFIRM MODE ACTIVE - Deleting legacy questions...

✅ Deletion successful!

📊 Final Database State:
   - Deleted: 100 legacy questions
   - Remaining Legacy: 0 (should be 0)
   - Remaining New Quality Questions: 50

✅ Database cleanup complete! All legacy questions removed.
================================================================================
```

---

## Prerequisites

### Environment Variables
Ensure your `.env` file contains:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### Dependencies
- Node.js 18+
- `dotenv` package (already in project)

---

## What Gets Deleted?

### ❌ Legacy Questions (Will Be Deleted)
- Questions with `timer_seconds IS NULL`
- Produced before Matrix Factory upgrade
- Missing Golden Standard features:
  - No timer calibration
  - No Chain of Thought (CoT) logic
  - No SAT/AMC difficulty alignment
  - No plausible distractors
  - Old brand color (`#00A86B` vs. `#07C160`)

### ✅ New Questions (Will Be Kept)
- Questions with `timer_seconds IS NOT NULL` (30, 60, or 90)
- Produced by Matrix Factory
- Includes Golden Standard features:
  - Timer: 30s (初级), 60s (中级), 90s (高级)
  - CoT: Multi-step reasoning required
  - Difficulty: SAT/AMC aligned for Grade 10-12
  - Distractors: Plausible common mistakes
  - Tags: Bilingual format "English (中文)"
  - Brand: WeChat Green (#07C160)

---

## Verification

### After Running in Confirm Mode

**1. Check Supabase Dashboard:**
```sql
SELECT 
  COUNT(*) as total,
  COUNT(CASE WHEN timer_seconds IS NULL THEN 1 END) as legacy,
  COUNT(CASE WHEN timer_seconds IS NOT NULL THEN 1 END) as new_quality
FROM questions;
```

Expected Result:
```
total: 50
legacy: 0
new_quality: 50
```

**2. Verify Timer Values:**
```sql
SELECT timer_seconds, COUNT(*) as count
FROM questions
GROUP BY timer_seconds;
```

Expected Result:
```
timer_seconds | count
--------------|------
30            | 15
60            | 20
90            | 15
```

**3. Check Bilingual Tags:**
```sql
SELECT tags
FROM questions
LIMIT 5;
```

Expected Format:
```json
["Linear Equations (一元一次方程)", "Slope (斜率)"]
```

---

## Safety Checklist

Before running with `--confirm`:

- [ ] **Backup**: Ensure you have a recent database backup
- [ ] **Dry-Run**: Run without `--confirm` first to preview
- [ ] **Review Samples**: Check the 5 sample questions to confirm they're old
- [ ] **Check Count**: Verify legacy count matches expectations
- [ ] **Environment**: Confirm `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are correct

---

## Troubleshooting

### Issue: "Missing environment variables"
**Cause**: `.env` file not loaded or missing keys  
**Solution**: 
```bash
cat .env | grep SUPABASE
# Ensure both SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY exist
```

### Issue: "No legacy questions found"
**Cause**: Database already clean  
**Action**: No action needed, all questions are new quality questions ✅

### Issue: Deletion failed
**Cause**: API error or permissions issue  
**Solution**: 
1. Check Supabase service role key has DELETE permissions
2. Verify network connection to Supabase
3. Check script output for specific error message

---

## Rollback (If Needed)

If you accidentally delete questions:

### Option 1: Restore from Backup
```sql
-- Use Supabase Dashboard → Database → Backups
-- Select backup from before deletion
-- Click "Restore"
```

### Option 2: Regenerate Questions
```bash
# Trigger Matrix Factory manually
cd question-factory
node question_factory_new.js

# Or wait for next scheduled run (every 6 hours)
```

---

## Expected Timeline

| Phase | Time | Description |
|-------|------|-------------|
| **Dry-Run** | ~5 seconds | Preview deletion, analyze database |
| **Confirm Execution** | ~10-30 seconds | Delete legacy questions (depends on count) |
| **Verification** | ~5 seconds | Recount and confirm cleanup |

**Total**: ~1 minute for complete cleanup

---

## Integration with Matrix Factory

### Before Cleanup
```
Total Questions: 150
├── Legacy (timer_seconds IS NULL): 100
└── New Quality (timer_seconds IS NOT NULL): 50
```

### After Cleanup
```
Total Questions: 50 (all new quality)
└── New Quality Questions: 50
    ├── 30s timer: 15 questions
    ├── 60s timer: 20 questions
    └── 90s timer: 15 questions
```

### After Next Matrix Run (6 hours later)
```
Total Questions: 110 (all new quality)
└── New Quality Questions: 110
    ├── Previous: 50
    └── New Batch: 60 (20 jobs × 3 questions)
```

---

## Automation (Optional)

### Run Cleanup Before Each Matrix Run

**GitHub Actions** (add to `.github/workflows/question-factory-new.yml`):

```yaml
- name: Cleanup Legacy Questions
  run: |
    cd scripts
    node purge_legacy_questions.js --confirm
  env:
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
```

### Weekly Cron Job

```yaml
# .github/workflows/database-cleanup.yml
name: Weekly Database Cleanup

on:
  schedule:
    - cron: '0 0 * * 0'  # Every Sunday at midnight UTC
  workflow_dispatch:

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - name: Purge Legacy Questions
        run: node scripts/purge_legacy_questions.js --confirm
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
```

---

## Summary

**Safe**: Dry-run by default, requires `--confirm` to execute  
**Targeted**: Only deletes `timer_seconds IS NULL` questions  
**Preserves**: All new quality questions from Matrix Factory  
**Verifies**: Recounts after deletion to confirm cleanup  
**Fast**: Completes in ~1 minute for typical databases  

**Command**:
```bash
# Preview (safe)
node scripts/purge_legacy_questions.js

# Execute (requires confirmation)
node scripts/purge_legacy_questions.js --confirm
```
