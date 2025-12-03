# 🎨 Visual Question Bank - Implementation Guide

## Overview
The Visual Question Bank generates math and physics questions with **SVG diagrams** to create a unique competitive moat.

---

## ✅ Step 1: Database Setup

### Run SQL in Supabase Console

1. Go to: https://supabase.com/dashboard/projects
2. Select your project: **learnest-production**
3. Click **SQL Editor** (left sidebar)
4. Copy and paste the SQL from: `supabase/add_svg_diagram_column.sql`
5. Click **Run**

**Expected Output:**
```
ALTER TABLE
column_name  | data_type | is_nullable
-------------+-----------+-------------
svg_diagram  | text      | YES
```

---

## ✅ Step 2: App Dependencies

### Install flutter_svg

```bash
cd /Users/feihan/learnest_fresh
flutter pub get
```

**Verify:** Check that `flutter_svg: ^2.0.10` appears in `pubspec.yaml` dependencies.

---

## ✅ Step 3: Generate Visual Questions Locally

### Test the Visual Factory

```bash
# Navigate to project root
cd /Users/feihan/learnest_fresh

# Generate 5 visual questions (Math Geometry + Physics Mechanics)
node question-factory/question_factory_visual.js 5
```

### Expected Output:
```
🎨 Visual Question Factory (SVG Diagrams)
📊 Target: 5 questions

🔄 [1/5] Generating visual question...
   📐 数学 - Grade 8 - 勾股定理
   ✅ Generated with SVG (856 chars)

🔄 [2/5] Generating visual question...
   📐 物理 - Grade 10 - 斜面问题
   ✅ Generated with SVG (1024 chars)

...

💾 Saving 5 visual questions to Supabase...
✅ Success! Inserted 5 visual questions with SVG diagrams.
```

---

## ✅ Step 4: Verify in App

### Run the Flutter App

```bash
cd /Users/feihan/learnest_fresh
flutter run
```

### Test Visual Questions:
1. Navigate to **Question Arena**
2. Select **Math (数学)** or **Physics (物理)**
3. Look for questions with **SVG diagrams above the text**

**Visual Indicator:**
- White container with rounded corners
- Centered diagram (max height: 200px)
- Gray border (#E0E0E0)

---

## 📐 SVG Diagram Structure

### Example: Right Triangle
```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300">
  <polygon points="50,250 50,100 200,250" fill="none" stroke="black" stroke-width="2"/>
  <rect x="50" y="235" width="15" height="15" fill="none" stroke="black" stroke-width="1"/>
  <text x="30" y="180" font-size="16" fill="black">3</text>
  <text x="120" y="270" font-size="16" fill="black">4</text>
  <text x="130" y="170" font-size="16" fill="black">?</text>
</svg>
```

### Key Features:
- **ViewBox:** Always `0 0 300 300` for consistent scaling
- **Stroke Width:** 2-3 for clarity on mobile screens
- **Text Labels:** Font size 14-16 for readability
- **Colors:** Black lines, light fills (#e8f5e9, #bbdefb)

---

## 🔧 Troubleshooting

### Issue: SVG Not Rendering
**Solution:** Check that `svg_diagram` field contains valid XML:
```sql
SELECT id, subject, LEFT(svg_diagram, 100) 
FROM questions 
WHERE svg_diagram IS NOT NULL 
LIMIT 5;
```

### Issue: "Unused import" Warning
**Solution:** This is expected until you run the app. The import will be used when SVG questions appear.

### Issue: No Visual Questions in Arena
**Solution:** 
1. Verify questions were inserted:
   ```sql
   SELECT COUNT(*) FROM questions WHERE svg_diagram IS NOT NULL;
   ```
2. Check filter logic in `QuestionService.dart` (ensure visual questions aren't filtered out)

---

## 🚀 Production Deployment

### GitHub Actions Integration
To add visual questions to the automated factory:

1. Create `.github/workflows/visual-factory.yml`
2. Schedule: Once per day (visual questions take longer to generate)
3. Batch size: 10-20 questions per run

**Why slower?**
- DeepSeek needs more tokens for SVG generation (~4000 tokens vs ~3000)
- Each question requires careful diagram validation

---

## 📊 Expected Coverage

### Math Topics (Grades 7-12):
- Triangle properties, Pythagorean theorem
- Circles, polygons, area calculations
- Function graphs, trigonometric functions
- Analytic geometry, vectors

### Physics Topics (Grades 7-12):
- Force diagrams (inclined planes, pulleys)
- Motion trajectories (projectile, circular)
- Electric circuits, field lines
- Optics (reflection, refraction)

### Total Visual Question Pool Target:
- **500-1000 visual questions** (competitive moat)
- Generation rate: ~50 per week via GitHub Actions

---

## ✅ Checklist

Before marking as complete:

- [ ] SQL executed in Supabase (svg_diagram column added)
- [ ] `flutter pub get` completed successfully
- [ ] Generated 5+ test questions locally
- [ ] Verified SVG rendering in Flutter app
- [ ] Questions display correctly in Arena page
- [ ] No compilation errors in app

---

**Status:** Ready for Testing 🎉
