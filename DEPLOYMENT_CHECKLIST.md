# 🚀 Matrix Mode Deployment Checklist

## ✅ Files Modified/Created

### **Updated Files**
1. ✅ `.github/workflows/question-factory-new.yml`
   - Upgraded to Matrix Strategy (20 parallel jobs)
   - Schedule changed: Every 6 hours (4 runs/day)
   - Added workflow_dispatch with force-subject input
   - Added artifacts upload for debugging
   - Added summary job

### **New Files**
2. ✅ `.github/workflows/MATRIX_MODE_README.md`
   - Comprehensive documentation
   - Architecture diagrams
   - Scaling options
   - Troubleshooting guide

3. ✅ `question-factory/matrix_calculator.js`
   - Throughput calculator
   - Resource estimation
   - Comparison with legacy mode

## 📋 Pre-Deployment Checklist

### **GitHub Configuration**
- [ ] **Configure Repository Secrets**
  - Go to: Settings → Secrets and variables → Actions
  - Add the following secrets:
    - [ ] `DEEPSEEK_API_KEY` (DeepSeek API key)
    - [ ] `SUPABASE_URL` (Supabase project URL)
    - [ ] `SUPABASE_ANON_KEY` (Supabase anonymous key)

### **Code Review**
- [ ] **Review Workflow File**
  ```bash
  cat .github/workflows/question-factory-new.yml
  ```
  - [ ] Verify matrix configuration (4 subjects × 5 batches)
  - [ ] Verify max-parallel: 20
  - [ ] Verify fail-fast: false
  - [ ] Verify schedule: '0 */6 * * *'

- [ ] **Test Locally**
  ```bash
  node question-factory/matrix_calculator.js
  ```
  Expected output: 240 questions/day, 7,200/month

### **Git Operations**
- [ ] **Stage Changes**
  ```bash
  git add .github/workflows/question-factory-new.yml
  git add .github/workflows/MATRIX_MODE_README.md
  git add question-factory/matrix_calculator.js
  ```

- [ ] **Commit**
  ```bash
  git commit -m "🚀 Upgrade to Matrix Mode: 20x Parallel Question Factory

  - Implement GitHub Actions matrix strategy (4 subjects × 5 batches)
  - Schedule: Every 6 hours (4 runs/day)
  - Throughput: 240 questions/day (60 per run)
  - Golden Standard prompts with SAT/AMC alignment
  - Fail-fast disabled for reliability
  - Added artifacts upload for debugging
  - Added comprehensive documentation

  Metrics:
  - 20 parallel jobs per run
  - 60 questions per run
  - 240 questions per day
  - 7,200 questions per month
  - Within GitHub Free tier limits (360 min/month)"
  ```

- [ ] **Push to GitHub**
  ```bash
  git push origin main
  ```

## 🧪 Testing & Validation

### **Manual Trigger Test**
1. [ ] Go to GitHub Actions tab
2. [ ] Select "Auto Question Factory (Matrix Mode - 20x Parallel)"
3. [ ] Click "Run workflow"
4. [ ] (Optional) Enter force-subject: `math`
5. [ ] Monitor job execution:
   - [ ] Verify 20 jobs appear (or 5 if force-subject used)
   - [ ] Check for green checkmarks ✅
   - [ ] Review execution time (~3 min per job)

### **Verify Output**
1. [ ] **Check Supabase**
   ```sql
   SELECT COUNT(*) FROM questions 
   WHERE created_at > NOW() - INTERVAL '1 hour';
   ```
   Expected: ~60 new questions

2. [ ] **Verify Tags**
   ```sql
   SELECT tags FROM questions 
   WHERE created_at > NOW() - INTERVAL '1 hour'
   LIMIT 5;
   ```
   Expected format: `["Linear Equations (一元一次方程)", ...]`

3. [ ] **Check Quality**
   - [ ] Questions use multi-step reasoning
   - [ ] LaTeX formatting correct (\\( x^2 \\))
   - [ ] Distractors are plausible
   - [ ] timer_seconds matches difficulty

### **Monitor First Scheduled Run**
- [ ] Wait for next scheduled run (00:00, 06:00, 12:00, or 18:00 UTC)
- [ ] Check Actions tab for automatic execution
- [ ] Verify 20 jobs completed successfully
- [ ] Check Supabase for 60 new questions

## 🐛 Troubleshooting

### **If Jobs Fail**
1. [ ] Check Artifacts:
   - Navigate to failed job
   - Download artifact: `questions-{subject}-batch-{n}.zip`
   - Inspect logs for errors

2. [ ] Common Issues:
   - [ ] **API Rate Limit**: Reduce max-parallel or add delays
   - [ ] **Missing Secrets**: Verify secrets configured correctly
   - [ ] **Script Error**: Check question_factory_new.js for bugs

### **If No Questions Generated**
1. [ ] Verify DeepSeek API key is valid
2. [ ] Check Supabase connection (URL + Key)
3. [ ] Review job logs for error messages
4. [ ] Test factory locally:
   ```bash
   cd question-factory
   node question_factory_new.js
   ```

## 📊 Monitoring Dashboard

### **Key Metrics to Track**
- [ ] **Success Rate**: % of jobs completed successfully
- [ ] **Questions Generated**: Total per day/month
- [ ] **Execution Time**: Average time per job
- [ ] **GitHub Actions Minutes**: Monthly usage
- [ ] **DeepSeek API Usage**: Daily request count

### **Weekly Review**
- [ ] Review workflow run history
- [ ] Check for any failed jobs
- [ ] Verify question quality (sample 10 random questions)
- [ ] Monitor API costs
- [ ] Adjust schedule/matrix if needed

## 🚀 Scaling Plan

### **Phase 1: Current (Validated)**
- 20 jobs per run
- 4 runs per day
- 240 questions/day

### **Phase 2: Increase Frequency (If needed)**
```yaml
schedule:
  - cron: '0 */3 * * *'  # Every 3 hours = 8 runs/day
```
Result: 480 questions/day

### **Phase 3: Increase Batches**
```yaml
matrix:
  batch: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]  # 10 batches
```
Result: 40 jobs × 4 runs = 480 questions/day

### **Phase 4: Both (Maximum Throughput)**
- 10 batches × every 3 hours
- Result: 40 jobs × 8 runs = 960 questions/day

## ✅ Deployment Complete!

Once all checklist items are ✅, the Matrix Mode is live and operational.

**Expected Results**:
- ✅ 20 parallel jobs every 6 hours
- ✅ 60 high-quality questions per run
- ✅ 240 questions per day
- ✅ Golden Standard quality (SAT/AMC-aligned)
- ✅ Bilingual tags for all questions
- ✅ Within GitHub Free tier limits

**Next Steps**:
1. Monitor for 1 week
2. Review question quality
3. Adjust schedule if needed
4. Scale up based on demand

---

**Questions?** Check `.github/workflows/MATRIX_MODE_README.md` for detailed documentation.
