# Learnist.AI - 项目完整上下文文档

> **生成日期**: 2025年12月1日  
> **目的**: 为新的 Gemini 对话提供完整的项目背景和开发历史

---

## 📋 项目概述

### 项目名称
**Learnist.AI** - AI驱动的智能学习助手

### 核心定位
一款面向中学生的**拍照搜题 + AI辅导 + 刷题练习**的Flutter移动应用。

### 技术栈
- **框架**: Flutter 3.19.0+
- **语言**: Dart 3.9.2+
- **数据库**: Supabase (后端) + SQLite/Hive (本地缓存)
- **AI服务**: OpenAI GPT + Google ML Kit (OCR)
- **状态管理**: Provider + ValueNotifier
- **持久化**: SharedPreferences

### 目标用户
- 初高中学生 (Grade 9-12)
- 学科: 数学、物理、化学、奥数

---

## 🏗️ 核心功能架构

### 1. **拍照搜题 (Camera Page)**
- **Jade Aperture设计**: 仿生"玉石光圈"呼吸动画
- **Breach动画**: 点击后光圈展开，启动相机
- **智能裁剪**: 拍照后可调整题目区域（8方向拖拽）
- **科目选择**: 数学/物理/化学/奥数科目切换器
- **多语言支持**: 中/英/日/西 4语言热切换

### 2. **题库练习 (Question Bank Page)**
- **三步向导**: 科目选择 → 年级选择 → 主题选择
- **复仇模式**: 错题回顾专用入口（橙色卡片）
- **知识图谱**: 基于LEARNIST_SYLLABUS常量的题库分类

### 3. **竞技场 (Arena Page)**
- **动态题目生成**: 根据科目/年级/主题生成题目
- **Combo系统**: 连续答对显示Combo倍数
- **Review Mode**: 特殊的错题复习模式（橙色Banner）
- **AI导师**: 集成AITutorSheet底部弹窗

### 4. **解题页 (Solving Page)**
- **Glass Layer架构**: 题目层 → 涂鸦层 → 计算器层
- **Braun计算器**: 4种布拉恩风格计算器（触觉反馈）
- **ScribblePad**: 手写演算板（保存/清除/撤销）
- **BINGO庆祝**: 答对后金币雨动画 + XP奖励

### 5. **个人页 (Profile Page)**
- **实时数据**: 基于UserProgressService的真实进度
- **技能雷达图**: fl_chart实现的5维能力图
- **等级系统**: 7级段位（Newbie → Ultimate Sage）
- **证书导出**: (功能预留)

---

## 🎨 设计系统

### 视觉标识 (VI)
- **主色**: WeChat Green `#07C160` (全局统一)
- **背景**: `#F5F7FA` (浅灰)
- **深色文字**: `#1E293B`
- **辅助色**: `#64748B` (灰色)、`#FFA500` (橙色)

### 动画规范
- **呼吸动画**: 2000ms循环，1.0 ↔ 1.05缩放
- **Breach动画**: 300ms，Curves.easeOutCubic
- **Loading**: 800ms模拟网络延迟
- **BINGO**: 3秒金币雨 + 触觉反馈

### 组件库
- **BraunCalculator**: 4种计算器样式
- **ScribblePad**: 涂鸦板组件
- **OnboardingOverlay**: 首次引导浮层
- **AITutorSheet**: AI导师底部弹窗

---

## 📂 项目结构

```
lib/
├── main.dart                          # 入口 + 底部导航
├── pages/
│   ├── app_camera_page.dart          # 拍照页（核心页面）
│   ├── app_question_bank_page.dart   # 题库向导
│   ├── app_question_arena_page.dart  # 竞技场
│   ├── app_profile_page.dart         # 个人主页
│   ├── solving_page.dart             # 解题页
│   └── camera/
│       └── camera_painters.dart      # Jade Aperture绘制
├── widgets/
│   ├── braun_calculator.dart         # 计算器组件
│   ├── scribble_pad.dart             # 涂鸦板
│   ├── onboarding_overlay.dart       # 引导浮层
│   └── aitutor_sheet.dart            # AI导师弹窗
├── services/
│   ├── user_progress_service.dart    # 用户进度（XP/等级/连击）
│   └── translation_service.dart      # 多语言翻译
├── models/                            # 数据模型
├── constants/
│   └── syllabus.dart                 # 知识图谱（科目/年级/主题）
└── theme/
    ├── app_theme.dart                # WeChat风格主题
    └── theme.dart                    # 旧版主题（已弃用）
```

---

## 🚀 开发历史 (按时间倒序)

### **Day 7: 多语言系统 (2025-12-01)**
#### 实现内容
- ✅ 创建 `TranslationService` (Tr类)
- ✅ 支持4语言: 中文、英语、日语、西班牙语
- ✅ 50+翻译键覆盖全应用
- ✅ ValueNotifier热切换（无需重启）
- ✅ Camera页添加语言切换器（PopupMenuButton + Flag Emoji）
- ✅ main.dart底部导航标签动态化

#### 技术亮点
```dart
// 热切换核心
ValueListenableBuilder<String>(
  valueListenable: Tr.currentLocale,
  builder: (context, locale, child) => MaterialApp(...),
)

// 使用方式
Text(Tr.g('nav_scan'))  // 自动根据当前语言返回翻译
```

---

### **Day 6: 首次引导系统 (2025-11-30)**
#### 实现内容
- ✅ 创建 `OnboardingOverlay` 3步引导
  - Step 1: 中央光圈（全知之眼）
  - Step 2: 底部导航Arena
  - Step 3: 顶部计算器
- ✅ SharedPreferences持久化 `hasSeenOnboarding`
- ✅ Spotlight效果 + Pulsing Ring动画
- ✅ Debug功能: 长按中央区域重置引导

#### 视觉效果
- 黑色半透明遮罩 (85% opacity)
- 绿色光晕 (WeChat Green 30% opacity)
- 动态进度点指示器
- Skip按钮（右上角）

---

### **Day 5: 问题路由系统 (2025-11-30)**
#### 实现内容
- ✅ 重构 `AppQuestionArenaPage` 构造函数
  - 新参数: `subjectId`, `grade`, `topic`, `questionLimit`
- ✅ 智能Mock题目生成器
  - 数学题库 (6题)
  - 物理题库 (5题)
  - 化学题库 (4题)
  - 奥数题库 (3题)
  - 复习题库 (2题)
- ✅ Review Mode专用Banner（橙色渐变）
- ✅ Loading状态 (800ms模拟延迟)
- ✅ 连接Question Bank → Arena数据流

#### 数据流
```
QuestionBank (选择科目/年级/主题)
    ↓
Navigator.push with params
    ↓
Arena._fetchQuestions()
    ↓
_generateQuestionsBySubject(subjectId, grade, topic, limit)
    ↓
显示题目 + 开始练习
```

---

### **Day 4: 用户进度持久化 (2025-11-30)**
#### 实现内容
- ✅ 创建 `UserProgressService` (Singleton)
- ✅ 数据点:
  - `totalXP`: 总经验值
  - `questionsSolved`: 累计答题数
  - `currentStreak`: 连续学习天数
  - `lastStudyDate`: 最后学习日期
  - `rankTitle`: 等级称号（动态计算）
- ✅ 7级段位系统:
  ```
  Newbie Scholar     → 0 XP
  Bronze Learner     → 500 XP
  Silver Scholar     → 1,000 XP
  Gold Achiever      → 2,500 XP
  Platinum Master    → 5,000 XP
  Diamond Legend     → 10,000 XP
  Ultimate Sage      → 20,000 XP
  ```
- ✅ 集成到Profile Page（实时数据）
- ✅ 集成到Solving Page（答对奖励50 XP）
- ✅ 集成到Arena（每题20 XP）

#### 连击逻辑
- 同一天多次学习: Streak不变
- 连续第二天学习: Streak+1
- 中断1天以上: Streak重置为1

---

### **Day 3: 全局颜色标准化 (2025-11-30)**
#### 实现内容
- ✅ 扫描并替换旧颜色:
  - `#358373` (旧绿) → `#07C160` (WeChat Green)
  - `#5FCEB3` (旧浅绿) → `#07C160`
- ✅ 修改文件:
  - `app_question_bank_page.dart` (7处)
  - `app_question_arena_page.dart` (4处)
- ✅ 覆盖范围:
  - Revenge Mode卡片
  - 科目选择边框
  - 年级选择按钮
  - Combo徽章
  - 正确答案高亮
  - Ask Tutor按钮

---

### **Day 2: 关键功能修复 (2025-11-30)**
#### Critical Fix Batch - 5个致命问题
1. **✅ Question Bank导航修复**
   - 问题: Topic选择后TODO占位符
   - 修复: 添加Navigator.push到Arena

2. **✅ Revenge Mode按钮修复**
   - 问题: 卡片无onTap
   - 修复: 包裹GestureDetector，导航到Review模式

3. **✅ Braun Calculator连接**
   - 问题: 审计误报（实际已连接）
   - 验证: solving_page.dart已正确集成

4. **✅ Loading状态添加**
   - 问题: 答案验证800ms延迟无反馈
   - 修复: 添加_isLoading标志 + "Checking..."显示

5. **✅ Camera错误处理**
   - 问题: 相机初始化失败静默
   - 修复: try-catch + 用户可见错误UI + Retry按钮

---

### **Day 1: 专业解题页架构 (2025-11-29)**
#### 实现内容
- ✅ Glass Layer设计:
  ```
  Bottom: 题目内容 + AI解析
  Middle: ScribblePad涂鸦层
  Top:    BraunCalculator计算器
  ```
- ✅ 4种Braun计算器:
  - Variant 1: 经典黑白
  - Variant 2: 深空灰
  - Variant 3: 银河蓝
  - Variant 4: 晨曦金
- ✅ 触觉反馈（HapticFeedback.mediumImpact）
- ✅ 答案验证逻辑 + BINGO动画
- ✅ Confetti金币雨庆祝
- ✅ Robot状态机 (idle/thinking/happy)

---

### **Day 0: 项目初始化**
#### WeChat VI重构
- ✅ 统一主题为WeChat Green
- ✅ 创建app_theme.dart
- ✅ Jade Aperture相机设计
- ✅ 底部导航3页架构

---

## 🎯 核心数据结构

### LEARNIST_SYLLABUS
```dart
const List<Subject> LEARNIST_SYLLABUS = [
  Subject(
    id: 'math',
    name: 'Mathematics',
    grades: ['G9', 'G10', 'G11', 'G12'],
    topics: {
      'G9': ['Algebra I', 'Geometry Basics', ...],
      'G10': ['Geometry', 'Quadratic Functions', ...],
      'G11': ['Algebra II', 'Trigonometry', ...],
      'G12': ['Pre-Calculus', 'Calculus AB', ...],
    },
  ),
  Subject(id: 'physics', ...),
  Subject(id: 'chemistry', ...),
  Subject(id: 'olympiad', ...),
];
```

### UserStats Model
```dart
class UserStats {
  final int totalXP;
  final int questionsSolved;
  final int currentStreak;
  final String lastStudyDate;
  final String rankTitle;
}
```

### Translation Keys (示例)
```dart
'nav_scan': {'zh': '拍题', 'en': 'Scan', 'ja': 'スキャン', 'es': 'Escanear'}
'home_calc': {'zh': '计算器', 'en': 'Calc', 'ja': '電卓', 'es': 'Calc'}
```

---

## 🔧 关键依赖

### pubspec.yaml (核心库)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 核心功能
  camera: ^0.11.3
  image_picker: ^1.2.0
  provider: ^6.1.5
  shared_preferences: ^2.5.3
  
  # AI/ML
  google_ml_kit: ^0.16.3
  http: ^1.5.0
  
  # UI组件
  fl_chart: ^1.1.1              # 雷达图
  confetti: ^0.8.0               # 庆祝动画
  flutter_math_fork: ^0.7.4      # 数学公式
  math_expressions: ^2.4.0        # 表达式计算
  
  # 数据库
  sqflite: ^2.4.2
  hive: ^2.2.3
```

---

## 📊 当前状态

### ✅ 已完成功能
- [x] 相机拍照 + 裁剪
- [x] 题库向导 + 竞技场
- [x] 解题页 + 计算器 + 涂鸦板
- [x] 用户进度系统（XP/等级/连击）
- [x] 多语言系统（中英日西）
- [x] 首次引导
- [x] 全局WeChat VI

### ⏳ 待开发功能
- [ ] OCR图片识别 (Google ML Kit)
- [ ] AI解题 (OpenAI API)
- [ ] 错题本系统
- [ ] Supabase后端集成
- [ ] 证书导出
- [ ] 社交分享
- [ ] 每日任务系统

### 🐛 已知问题
- 无

---

## 🎯 下一步开发建议

### Priority 1 - OCR集成
```dart
// 需要实现
Future<String> recognizeText(File imageFile) async {
  final inputImage = InputImage.fromFile(imageFile);
  final textRecognizer = TextRecognizer();
  final recognizedText = await textRecognizer.processImage(inputImage);
  return recognizedText.text;
}
```

### Priority 2 - OpenAI解题
```dart
// 需要实现
Future<QuestionSolution> solveQuestion(String questionText) async {
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {'Authorization': 'Bearer $apiKey'},
    body: jsonEncode({
      'model': 'gpt-4',
      'messages': [
        {'role': 'system', 'content': '你是一个数学导师...'},
        {'role': 'user', 'content': questionText},
      ],
    }),
  );
  // Parse and return solution steps
}
```

### Priority 3 - 错题本
```dart
// 需要创建
class MistakeBookService {
  Future<void> addMistake(Question q, String userAnswer);
  Future<List<Question>> getMistakes({String? subjectFilter});
  Future<void> markAsReviewed(String questionId);
}
```

---

## 📝 编码规范

### 命名约定
- **Page**: `app_xxx_page.dart` (新) / `xxx_page.dart` (旧)
- **Widget**: `xxx_widget.dart` / `braun_calculator.dart`
- **Service**: `xxx_service.dart`
- **Model**: 直接命名如 `question.dart`, `user.dart`

### 状态管理
- **简单状态**: `setState` in StatefulWidget
- **跨组件共享**: `Provider`
- **响应式单值**: `ValueNotifier` + `ValueListenableBuilder`

### 颜色使用
```dart
const wechatGreen = Color(0xFF07C160);  // 主色
const bgGrey = Color(0xFFF5F7FA);       // 背景
const darkGrey = Color(0xFF1E293B);     // 深色文字
const lightGrey = Color(0xFF64748B);    // 浅色文字
const orange = Color(0xFFFFA500);       // 强调色
```

### 动画时长
```dart
Duration(milliseconds: 300)   // 快速交互
Duration(milliseconds: 800)   // 中等（模拟网络）
Duration(milliseconds: 2000)  // 慢速循环（呼吸）
```

---

## 🌟 设计亮点

### 1. Jade Aperture (玉石光圈)
- 仿生设计，模拟"全知之眼"
- 呼吸动画 (1.0 ↔ 1.05)
- Breach展开效果（CustomPainter绘制）

### 2. Glass Layer架构
- 三层透明叠加
- 底层题目可见性
- 中层涂鸦透明度
- 顶层计算器悬浮

### 3. 触觉反馈
- 每次按钮点击: `HapticFeedback.mediumImpact()`
- 答对: `HapticFeedback.heavyImpact()`
- 系统声音: `SystemSound.play(SystemSoundType.click)`

### 4. 热切换多语言
- 零延迟切换
- ValueNotifier驱动
- 无需重启应用
- 全局UI同步更新

---

## 💡 团队协作建议

### 给Gemini的建议
1. **熟悉核心页面**: 先读 `app_camera_page.dart` 和 `solving_page.dart`
2. **理解数据流**: QuestionBank → Arena → Solving的导航逻辑
3. **遵循VI规范**: 所有新颜色必须使用 `#07C160`
4. **测试多语言**: 新增UI文本必须添加翻译键
5. **保持动画一致性**: 使用统一的Duration和Curve

### 开发工作流
```bash
# 运行应用
flutter run

# 检查错误
flutter analyze

# 格式化代码
dart format .

# 生成图标
flutter pub run flutter_launcher_icons

# 清理缓存
flutter clean && flutter pub get
```

---

## 📞 关键联系信息

- **Repository**: `question-factory` (hanfei8065-jpg)
- **Branch**: `main`
- **Flutter Version**: 3.19.0+
- **Dart Version**: 3.9.2+

---

## 🎉 总结

这是一个**功能完整、设计精美、架构清晰**的Flutter学习应用。

**核心优势**:
- ✅ WeChat风格UI（用户熟悉度高）
- ✅ 3层Glass架构（专业且美观）
- ✅ 完整的进度系统（游戏化驱动）
- ✅ 4语言支持（国际化就绪）
- ✅ 零build错误（纯Dart方案）

**下一步重点**:
- 🔥 OCR集成（核心功能）
- 🔥 OpenAI解题（核心功能）
- 🔥 错题本（用户价值）

---

**🚀 准备好继续开发了吗？欢迎提出任何问题！**
