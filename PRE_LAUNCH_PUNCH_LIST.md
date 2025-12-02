# 🚨 Pre-Launch Punch List
**Learnist.AI - Usability & Logic Audit**  
**Auditor:** Senior PM & UX Lead  
**Date:** 2025-11-30  
**Status:** 🔴 **NOT READY FOR LAUNCH**

---

## 🔴 CRITICAL BLOCKERS (App Crashes or User Gets Stuck)

### 🔴-1: **Question Bank "Revenge Mode" Button - Navigation Dead End**
**File:** `lib/pages/app_question_bank_page.dart` (Lines 53-77)  
**Issue:** The "复仇模式" (Revenge Mode) card is tappable but has **NO `onTap` handler**. User clicks, nothing happens.  
**Impact:** **HIGH** - Featured card at top of page does nothing. User confusion.  
**Evidence:**
```dart
// Line 53-77: Container with NO GestureDetector
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF358373), // ❌ Old color, not WeChat Green
    // ...
  ),
  child: Row(
    children: [
      Icon(Icons.sports_martial_arts, color: Colors.white, size: 32),
      // ... NO onTap!
    ],
  ),
),
```
**Expected:** Should navigate to a "Daily Revenge" quiz page or show a dialog.

---

### 🔴-2: **Question Bank Topic Selection - Navigation Incomplete**
**File:** `lib/pages/app_question_bank_page.dart` (Line 209)  
**Issue:** Selecting a topic only updates state but does **NOT navigate anywhere**. Comment says `// TODO: 跳转到 QuestionArenaPage`.  
**Impact:** **CRITICAL** - Core user journey broken. User selects topic → nothing happens.  
**Evidence:**
```dart
GestureDetector(
  onTap: () {
    setState(() => selectedTopic = t);
    // TODO: 跳转到 QuestionArenaPage ❌ NOT IMPLEMENTED
  },
  // ...
)
```
**Expected:** Should navigate to `QuestionArenaPage` with selected subject/grade/topic.

---

### 🔴-3: **Camera Page - No Error Handling for Camera Failure**
**File:** `lib/pages/app_camera_page.dart` (Lines 72-88)  
**Issue:** `_initializeCamera()` catches errors but **only prints to console**. No user feedback if camera fails.  
**Impact:** **HIGH** - If camera permission denied or hardware fails, app shows black screen with no explanation.  
**Evidence:**
```dart
Future<void> _initializeCamera() async {
  try {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return; // ❌ Silent failure
    // ...
  } catch (e) {
    debugPrint('Camera initialization error: $e'); // ❌ Only console log
  }
}
```
**Expected:** Show `AlertDialog` or `SnackBar` explaining camera is unavailable.

---

### 🔴-4: **Solving Page - No Loading State for Answer Submission**
**File:** `lib/pages/solving_page.dart` (Lines 59-84)  
**Issue:** When user submits answer, there's an 800ms delay (`Future.delayed`) but **NO loading indicator**. App appears frozen.  
**Impact:** **MEDIUM** - Poor UX. User doesn't know if app is processing.  
**Evidence:**
```dart
void _onSubmitAnswer() {
  // ...
  setState(() => _robotState = 'thinking'); // ❌ Only robot changes, no spinner
  
  Future.delayed(const Duration(milliseconds: 800), () {
    // Check answer after delay, but no visual feedback to user
  });
}
```
**Expected:** Show `CircularProgressIndicator` or disable submit button during processing.

---

### 🔴-5: **Calculator Selection Page - All Calculators are Placeholders**
**File:** `lib/pages/calculator_selection_page.dart` (Lines 127-234)  
**Issue:** All 4 calculator types navigate to **placeholder pages** with "开发中..." (In Development). Dead ends.  
**Impact:** **CRITICAL** - Calculator feature advertised but non-functional.  
**Evidence:**
```dart
class BasicCalculatorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('基础计算器\n开发中...'), // ❌ Placeholder
      ),
    );
  }
}
```
**Expected:** Connect to `BraunCalculator` widgets from `lib/widgets/braun_calculator.dart`.

---

## 🟡 UX FRICTION (Confusing or Missing Feedback)

### 🟡-1: **Solving Page "Ask Dr. Logic" - No Actual Functionality**
**File:** `lib/pages/solving_page.dart` (Lines 223-236)  
**Issue:** Button shows `SnackBar` with "Dr. Logic AI助手正在分析..." but **never opens a sheet or AI chat**. Just changes robot state.  
**Impact:** **MEDIUM** - User expects AI tutor but gets fake loading message.  
**Evidence:**
```dart
void _onAskDrLogic() {
  setState(() => _robotState = 'thinking');
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Dr. Logic AI助手正在分析...')), // ❌ Fake
  );
  
  Future.delayed(const Duration(seconds: 2), () {
    setState(() => _robotState = 'idle'); // ❌ Just reverts, no AI response
  });
}
```
**Expected:** Should open a `BottomSheet` with AI chat interface or step-by-step hints.

---

### 🟡-2: **Camera Page Calculator Button - SnackBar Only**
**File:** `lib/pages/app_camera_page.dart` (Lines 475-481)  
**Issue:** Calculator button shows "计算器功能开发中..." instead of navigating.  
**Impact:** **LOW** - Button exists but doesn't work.  
**Evidence:**
```dart
void _onCalculatorTap() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('计算器功能开发中...')), // ❌
  );
}
```
**Expected:** Navigate to `CalculatorSelectionPage` or disable button.

---

### 🟡-3: **Profile Page Certificate/Report Dialogs - Vague Messages**
**File:** `lib/pages/app_profile_page.dart` (Lines 59-103)  
**Issue:** Lock dialogs say "达到 Legend 段位解锁" but don't show **current progress** or **how far away** user is.  
**Impact:** **MEDIUM** - User doesn't know if they're 10% or 90% to unlocking.  
**Evidence:**
```dart
void _showCertificateDialog() {
  showDialog(
    // ...
    content: const Text('达到 Legend 段位解锁官方推荐信'), // ❌ No progress shown
  );
}
```
**Expected:** Show "Currently: Silver Scholar (850/1000 XP). Need Legend (2000 XP) to unlock."

---

### 🟡-4: **Bottom Navigation State Loss on Tab Switch**
**File:** `lib/main.dart` (Lines 43-47)  
**Issue:** Using `IndexedStack` **preserves state**, but if user navigates deep into Camera flow (e.g., Solving Page), switching tabs and back will **lose the Solving Page**.  
**Impact:** **LOW** - User has to retake photo if they switch tabs accidentally.  
**Evidence:**
```dart
final List<Widget> _pages = [
  const AppCameraPage(),  // ❌ State resets when navigating to SolvingPage
  const AppQuestionBankPage(),
  const AppProfilePage(),
];
```
**Expected:** Acceptable for MVP, but should save "last viewed question" in Question Bank.

---

### 🟡-5: **No "Back to Crop" Button in Solving Page**
**File:** `lib/pages/solving_page.dart` (Line 302)  
**Issue:** If user navigates to Solving Page and realizes the crop was wrong, they can **only go back** via AppBar back button. No "Re-Crop" option.  
**Impact:** **LOW** - Minor UX friction.  
**Expected:** Add a "重新裁剪" button in Solving Page AppBar actions.

---

### 🟡-6: **Scribble Pad Has No Clear/Undo Button**
**File:** `lib/widgets/scribble_pad.dart`  
**Issue:** User can draw on Solving Page but **cannot erase mistakes** or clear all strokes. No undo.  
**Impact:** **MEDIUM** - Drawing becomes unusable if user makes mistake.  
**Expected:** Add floating "Clear" or "Undo" button over scribble pad.

---

## 🟢 POLISH/VISUALS (Inconsistent Colors or Icons)

### 🟢-1: **Question Bank "Revenge Mode" - Old Cyberpunk Color**
**File:** `lib/pages/app_question_bank_page.dart` (Lines 53, 57, 119, 129, 168, 174, 183)  
**Issue:** Uses **`#358373`** (old Jade Green) instead of **`#07C160`** (WeChat Green).  
**Impact:** **LOW** - Visual inconsistency with new VI.  
**Evidence:**
```dart
color: const Color(0xFF358373), // ❌ Should be 0xFF07C160
```
**7 occurrences** in the file.  
**Expected:** Replace all with `AppTheme.brandPrimary` or `Color(0xFF07C160)`.

---

### 🟢-2: **Profile Page Stats Row - Hardcoded Colors**
**File:** `lib/pages/app_profile_page.dart` (Lines 450-475)  
**Issue:** Uses inline color constants instead of `AppTheme` variables.  
**Impact:** **LOW** - Not using centralized theme.  
**Evidence:**
```dart
Widget _buildStatColumn(String value, String label, Color valueColor, Color labelColor) {
  // ❌ Colors passed as params, not from AppTheme
}
```
**Expected:** Use `AppTheme.textPrimary`, `AppTheme.textSecondary` for consistency.

---

### 🟢-3: **Camera Page Subjects Row - Hardcoded Padding**
**File:** `lib/pages/app_camera_page.dart` (Multiple locations)  
**Issue:** Uses magic numbers like `16.0`, `20.0` instead of `AppTheme.spacing16`, `AppTheme.spacing20`.  
**Impact:** **LOW** - Not following 8pt grid system.  
**Expected:** Replace with `AppTheme.spacingXX` constants.

---

### 🟢-4: **Solving Page Trophy Icon - Not Using Custom Asset**
**File:** `lib/pages/solving_page.dart` (Lines 110-120)  
**Issue:** BINGO dialog uses **placeholder yellow circle + emoji icon** instead of custom trophy asset.  
**Impact:** **LOW** - Looks generic, not branded.  
**Evidence:**
```dart
Container(
  width: 120,
  height: 120,
  decoration: const BoxDecoration(
    color: Color(0xFFFFD700), // ❌ Placeholder yellow circle
    shape: BoxShape.circle,
  ),
  child: const Icon(Icons.emoji_events, size: 64, color: Colors.white),
)
```
**Expected:** Use custom trophy Lottie animation or SVG asset.

---

### 🟢-5: **Profile Page Radar Chart - No Animation on First Load**
**File:** `lib/pages/app_profile_page.dart` (Lines 41-48)  
**Issue:** Radar chart animates **only once** on `initState`. If user scrolls down and back up, no re-animation.  
**Impact:** **LOW** - Minor polish issue.  
**Expected:** Trigger animation when chart becomes visible (use `VisibilityDetector`).

---

### 🟢-6: **Main Navigator - Icon Size Inconsistency**
**File:** `lib/main.dart` (Lines 68-91)  
**Issue:** Bottom nav icons hardcoded to `size: 26`. Should use `AppTheme.iconSizeL` (24).  
**Impact:** **LOW** - Not following theme system.  
**Evidence:**
```dart
Icon(_currentIndex == 0 ? Icons.camera_alt : Icons.camera_alt_outlined, size: 26),
// ❌ Should be AppTheme.iconSizeL
```

---

## 📊 SUMMARY TABLE

| Category | Count | Severity | Must Fix Before Launch? |
|----------|-------|----------|-------------------------|
| 🔴 **Critical Blockers** | 5 | HIGH | ✅ **YES** |
| 🟡 **UX Friction** | 6 | MEDIUM | ⚠️ **RECOMMENDED** |
| 🟢 **Polish/Visuals** | 6 | LOW | ❌ **OPTIONAL** |
| **TOTAL ISSUES** | **17** | - | - |

---

## 🎯 RECOMMENDED FIX PRIORITY

### Sprint 1: Critical Path (1-2 days)
1. 🔴-2: Implement Question Bank → Arena navigation
2. 🔴-5: Connect Calculator Selection to Braun Calculators
3. 🔴-3: Add camera error handling with user feedback
4. 🔴-1: Add Revenge Mode dialog/navigation

### Sprint 2: UX Polish (1 day)
5. 🔴-4: Add loading state for answer submission
6. 🟡-1: Implement Dr. Logic bottom sheet (or remove button)
7. 🟡-6: Add scribble pad clear/undo
8. 🟡-3: Improve certificate/report dialogs with progress

### Sprint 3: Visual Consistency (0.5 days)
9. 🟢-1: Fix all `#358373` → `#07C160` in Question Bank
10. 🟢-2-6: Apply `AppTheme` constants throughout

---

## 🚦 LAUNCH READINESS ASSESSMENT

**Current State:** 🔴 **NOT READY**

**Reasons:**
- ❌ Core user journey broken (Question Bank topic selection)
- ❌ Advertised features non-functional (All calculators, Dr. Logic)
- ❌ No error handling for critical failures (Camera)

**Minimum Viable Launch Requires:**
- ✅ Fix all 🔴 Critical Blockers (Estimated: 2 days)
- ✅ Fix 🟡-1, 🟡-6 (Dr. Logic + Scribble Clear)
- ✅ Fix 🟢-1 (Color consistency)

**Estimated Time to MVP:** **3 days** (with 1 developer)

---

## 📝 NOTES FOR PM

1. **Decision Required:** Should we **remove** "Dr. Logic" button entirely if AI backend isn't ready? Or implement a basic FAQ bottom sheet?

2. **Decision Required:** Should Calculator Selection page be **hidden** until Braun Calculators are fully integrated?

3. **Technical Debt:** `camera_page.dart` (1537 lines) has duplicate code and should be refactored. Currently using `app_camera_page.dart` (774 lines, cleaner).

4. **Asset Gap:** Robot avatar assets (`robot_idle.png`, `robot_thinking.png`, `robot_happy.png`) are **missing**. App uses fallback icons.

5. **Design System Adoption:** Only ~40% of codebase uses `AppTheme` constants. Remaining 60% uses hardcoded values.

---

**Awaiting Command to Begin Fixes.** 🛠️
