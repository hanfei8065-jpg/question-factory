# 🚀 Matrix Mode - 20x Parallel Question Factory

## 📊 Architecture Overview

```
GitHub Actions Scheduler (Every 6 hours)
    ↓
Matrix Strategy (4 subjects × 5 batches = 20 jobs)
    ↓
┌─────────────────────────────────────────────────────────┐
│  Parallel Execution (max-parallel: 20)                 │
├─────────────────────────────────────────────────────────┤
│  Math      │ Batch 1 | Batch 2 | Batch 3 | Batch 4 | 5 │
│  Physics   │ Batch 1 | Batch 2 | Batch 3 | Batch 4 | 5 │
│  Chemistry │ Batch 1 | Batch 2 | Batch 3 | Batch 4 | 5 │
│  Olympiad  │ Batch 1 | Batch 2 | Batch 3 | Batch 4 | 5 │
└─────────────────────────────────────────────────────────┘
    ↓
Each job generates 3 questions
    ↓
Total: 20 jobs × 3 questions = 60 questions per run
    ↓
Daily Output: 4 runs × 60 = 240 questions/day
```

---

## 🎯 Production Metrics

### **Throughput Comparison**

| Mode | Jobs/Run | Questions/Run | Runs/Day | Questions/Day |
|------|----------|---------------|----------|---------------|
| **Legacy (Sequential)** | 1 | 3 | 720 (every 2 min) | 2,160 |
| **Matrix Mode (NEW)** | 20 | 60 | 4 (every 6 hours) | **240** |

**Why reduce frequency?**
- **API Rate Limits**: DeepSeek has rate limits (~50 requests/min)
- **Cost Control**: 20x parallelism = 20x API costs per run
- **Quality over Quantity**: Golden Standard prompts require more compute
- **GitHub Actions Limits**: Free tier = 2,000 min/month

---

## 🔧 Configuration Details

### **Matrix Variables**

```yaml
matrix:
  subject: [math, physics, chemistry, olympiad]  # 4 subjects
  batch: [1, 2, 3, 4, 5]                         # 5 batches per subject
```

**Total Combinations**: 4 × 5 = **20 parallel jobs**

### **Schedule**

```yaml
schedule:
  - cron: '0 */6 * * *'  # Every 6 hours (00:00, 06:00, 12:00, 18:00 UTC)
```

**Runs per day**: 4  
**Questions per day**: 4 runs × 60 = **240**  
**Questions per month**: 240 × 30 = **7,200**

---

## 🎨 Job Naming Convention

Each matrix job gets a unique name:

```
math-batch-1
math-batch-2
physics-batch-1
chemistry-batch-3
olympiad-batch-5
...
```

**Total**: 20 uniquely named jobs per run

---

## 📦 Artifacts

Each job uploads logs for debugging:

```yaml
- name: Upload Artifacts
  uses: actions/upload-artifact@v4
  with:
    name: questions-${{ matrix.subject }}-batch-${{ matrix.batch }}
    path: question-factory/logs/
    retention-days: 7
```

**Example artifacts**:
- `questions-math-batch-1.zip`
- `questions-physics-batch-3.zip`
- `questions-olympiad-batch-5.zip`

---

## 🚦 Failure Handling

```yaml
strategy:
  fail-fast: false  # Continue other jobs even if one fails
```

**Behavior**:
- If `math-batch-2` fails, other 19 jobs continue
- Summary job runs regardless of failures
- Artifacts preserved for 7 days for debugging

---

## 🔐 Required Secrets

Set these in **GitHub Repository Settings → Secrets**:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `DEEPSEEK_API_KEY` | DeepSeek API authentication | `sk-...` |
| `SUPABASE_URL` | Supabase project URL | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | `eyJhbG...` |

---

## 🧪 Manual Trigger

Run via **GitHub Actions UI**:

1. Go to **Actions** tab
2. Select **"Auto Question Factory (Matrix Mode)"**
3. Click **"Run workflow"**
4. (Optional) Enter `force-subject` input (e.g., `math`)

**Force-subject** (future feature):
- If specified, only runs jobs for that subject
- Example: `force-subject: math` → Only 5 jobs (math-batch-1 to 5)

---

## 📈 Scaling Options

### **Increase Parallelism**

Change `max-parallel` to run more concurrent jobs:

```yaml
strategy:
  max-parallel: 60  # GitHub Pro allows up to 60
```

### **Increase Batches**

Add more batches per subject:

```yaml
matrix:
  batch: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]  # 10 batches
```

**Result**: 4 subjects × 10 batches = **40 jobs** × 3 questions = **120 questions/run**

### **Increase Frequency**

Run every 3 hours instead of 6:

```yaml
schedule:
  - cron: '0 */3 * * *'  # 8 runs/day
```

**Result**: 8 runs × 60 = **480 questions/day**

⚠️ **Warning**: Monitor API costs and GitHub Actions minutes!

---

## 🐛 Troubleshooting

### **Job Failures**

**Symptom**: Some jobs fail with API errors  
**Cause**: DeepSeek rate limit exceeded  
**Solution**: Reduce `max-parallel` or increase delay between jobs

### **Missing Secrets**

**Symptom**: `Context access might be invalid` warning  
**Cause**: Secrets not configured in GitHub  
**Solution**: Add secrets in **Settings → Secrets → Actions**

### **No Questions Generated**

**Symptom**: Jobs succeed but no questions in Supabase  
**Cause**: `question_factory_new.js` script error  
**Solution**: Check artifacts logs for error details

---

## 📊 Monitoring Dashboard

### **View Job Status**

1. Go to **Actions** tab
2. Click on latest workflow run
3. View matrix visualization:

```
✅ math-batch-1     (2m 34s)
✅ math-batch-2     (2m 41s)
❌ math-batch-3     (Failed after 1m 12s)
✅ physics-batch-1  (2m 29s)
...
```

### **Download Logs**

1. Click on failed job (e.g., `math-batch-3`)
2. Scroll to "Artifacts" section
3. Download `questions-math-batch-3.zip`
4. Inspect logs for error details

---

## 🎯 Expected Output (Per Run)

```
Total Jobs: 20
├── Math: 5 batches × 3 questions = 15
├── Physics: 5 batches × 3 questions = 15
├── Chemistry: 5 batches × 3 questions = 15
└── Olympiad: 5 batches × 3 questions = 15
────────────────────────────────────────
Total: 60 questions
```

**Quality Metrics** (with Golden Standard):
- ✅ Multi-step reasoning: ~80% of questions
- ✅ SAT/AMC-aligned (Grade 10-12): ~70%
- ✅ Bilingual tags: 100%
- ✅ Plausible distractors: ~90%

---

## 🚀 Next Steps

1. **Commit and push** the updated workflow
2. **Configure secrets** in GitHub repository settings
3. **Trigger manually** to test (Actions → Run workflow)
4. **Monitor first run** for errors
5. **Enable schedule** once validated

---

## 📞 Support

**Issue?** Check:
1. Artifacts logs
2. Supabase database for new questions
3. DeepSeek API dashboard for quota usage
4. GitHub Actions logs for detailed errors

**Contact**: Open GitHub issue with:
- Workflow run URL
- Error message from logs
- Expected vs actual behavior
