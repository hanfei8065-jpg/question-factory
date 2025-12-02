# 🌐 Supabase 集成指南

## ✅ 完成状态

### 已完成
1. ✅ **QuestionService 创建** (`lib/services/question_service.dart`)
2. ✅ **Arena 页面集成** (`lib/pages/app_question_arena_page.dart`)
3. ✅ **Main 初始化** (`lib/main.dart`)
4. ✅ **错误处理 + Fallback 逻辑**

### 待完成
1. ⏳ **添加依赖** `supabase_flutter: ^2.0.0`
2. ⏳ **运行 `flutter pub get`**
3. ⏳ **测试真实数据获取**

---

## 📦 步骤 1: 添加依赖

打开 `pubspec.yaml`，在 `dependencies:` 部分添加：

```yaml
dependencies:
  # ... existing dependencies ...
  
  supabase_flutter: ^2.0.0  # ✅ 添加这一行
```

然后运行：
```bash
flutter pub get
```

---

## 🚀 步骤 2: 验证集成

### A. 检查 Supabase 初始化日志

运行 App 后，查看控制台输出：

```
✅ Supabase initialized: https://wsolihwdxncnumzttbaz.supabase.co
```

如果看到这行，说明初始化成功。

### B. 进入任意题库（Math/Physics/Chemistry）

查看控制台日志：

**成功获取数据：**
```
🌐 Fetching REAL data from Supabase...
🔍 QuestionService: Fetching questions...
   Subject: math, Grade: null, Limit: 10
✅ QuestionService: Received 15 questions from Supabase
✅ Loaded 5 REAL questions from Supabase
```

**失败回退到 Mock：**
```
🌐 Fetching REAL data from Supabase...
❌ Failed to fetch questions from Supabase: ...
🔄 Falling back to MOCK data...
```

---

## 📋 代码说明

### 1. QuestionService (`lib/services/question_service.dart`)

**核心方法：**
```dart
Future<List<Question>> fetchQuestions({
  required String subject,  // 'math', 'physics', 'chemistry'
  int? grade,               // 10, 11, 12
  List<String>? tags,       // ['algebra', 'equations']
  int limit = 20,
  int? difficulty,          // 1-4
})
```

**功能特性：**
- ✅ 从 Supabase `questions` 表查询
- ✅ 按学科、年级、难度过滤
- ✅ 客户端 tags 过滤（因为 Supabase JSONB 查询复杂）
- ✅ 自动解析 `timer_seconds` 字段
- ✅ 错误处理（抛出异常让调用方处理）

**辅助方法：**
- `healthCheck()` - 测试连接是否正常
- `getQuestionCount()` - 获取题目总数（用于统计）
- `fetchReviewQuestions()` - 复习模式（TODO: 实现错题查询）

---

### 2. Arena 集成 (`lib/pages/app_question_arena_page.dart`)

**新增状态变量：**
```dart
final _questionService = QuestionService();
String? _errorMessage;
bool _useRealData = true; // 真实数据开关
```

**新版 `_fetchQuestions()` 逻辑：**

```dart
Future<void> _fetchQuestions() async {
  try {
    if (_useRealData) {
      // 🔥 从 Supabase 获取
      List<Question> questionObjects = await _questionService.fetchQuestions(...);
      
      // 转换为 Map (兼容现有 UI)
      questions = questionObjects.map((q) => {
        'question': q.content,
        'options': q.options,
        'answer': q.options.indexOf(q.answer),
        'timer_seconds': q.timerSeconds ?? 60, // ✅ 关键映射
      }).toList();
      
    } else {
      // 使用 Mock 数据
      await _fetchMockQuestions();
    }
  } catch (e) {
    // 🔄 失败回退到 Mock
    await _fetchMockQuestions();
  }
}
```

**数据流：**
1. Supabase `questions` 表 (JSON)
2. ↓ QuestionService.fetchQuestions()
3. ↓ List<Question> 对象
4. ↓ 转换为 Map<String, dynamic>
5. ↓ Arena UI 渲染

---

### 3. Main 初始化 (`lib/main.dart`)

**新增代码：**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // 1. Load .env
  await dotenv.load(fileName: '.env');
  
  // 2. Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '',
    debug: true, // 显示日志
  );
  
  // ... rest of initialization
}
```

**环境变量（`.env`）：**
```properties
SUPABASE_URL=https://wsolihwdxncnumzttbaz.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 🎛️ 开关控制

### 临时切换到 Mock 数据（调试用）

在 `app_question_arena_page.dart` 中：

```dart
// 第 57 行
bool _useRealData = true; // 改为 false 使用 Mock
```

这样可以在：
- ❌ Supabase 离线时
- 🐞 调试 UI 时
- 🚀 测试新功能时

...直接使用 Mock 数据，无需等待网络请求。

---

## 🔧 问题排查

### 问题 1: 编译错误 `Undefined name 'Supabase'`

**原因：** 未添加 `supabase_flutter` 依赖

**解决：**
```bash
flutter pub add supabase_flutter
flutter pub get
```

---

### 问题 2: 运行时错误 `No questions found in database`

**原因：** Supabase 表中没有对应学科的题目

**排查：**
1. 检查 Question Factory 是否正常运行（GitHub Actions）
2. 登录 Supabase Dashboard 查看 `questions` 表数据
3. 运行健康检查：
   ```dart
   final healthy = await QuestionService().healthCheck();
   print('Supabase healthy: $healthy');
   ```

**临时方案：** 设置 `_useRealData = false` 使用 Mock

---

### 问题 3: 答案索引错误

**症状：** 选择正确答案但标记为错误

**原因：** Supabase 存储的 `answer` 格式可能不是选项索引

**排查：**
在 `_fetchQuestions()` 中添加日志：
```dart
print('Question: ${q.content}');
print('Answer: ${q.answer}'); // 查看原始值
print('Options: ${q.options}');
print('Index: ${q.options.indexOf(q.answer)}');
```

**修复：** 调整 Question Factory 输出格式，确保 `answer` 为选项文本（如 "A) 108"）

---

## 📊 数据库 Schema 要求

Supabase `questions` 表必须包含以下字段：

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `id` | text | ✅ | 主键 |
| `content` | text | ✅ | 题目内容 |
| `options` | text[] | ✅ | 选项数组 |
| `answer` | text | ✅ | 正确答案（选项文本） |
| `explanation` | text | ✅ | 解析 |
| `subject` | text | ✅ | 学科 (math/physics/chemistry) |
| `grade` | int | ❌ | 年级 (10/11/12) |
| `difficulty` | int | ❌ | 难度 (1-4) |
| `tags` | jsonb | ❌ | 标签数组 |
| `timer_seconds` | int | ✅ | **倒计时秒数** |
| `created_at` | timestamp | ❌ | 创建时间 |

**索引建议：**
```sql
CREATE INDEX idx_questions_subject ON questions(subject);
CREATE INDEX idx_questions_grade ON questions(grade);
CREATE INDEX idx_questions_difficulty ON questions(difficulty);
```

---

## 🧪 测试清单

完成依赖添加后，测试以下场景：

### ✅ 基础功能
- [ ] App 启动无报错
- [ ] 看到 Supabase 初始化日志
- [ ] 进入 Math Arena，题目正常加载
- [ ] 倒计时正常显示（绿→橙→红）
- [ ] 选择答案后计时器停止

### ✅ 数据验证
- [ ] 题目内容来自 Supabase（非 Mock）
- [ ] `timer_seconds` 字段正确显示（30/60/90/120秒）
- [ ] 答案判断正确
- [ ] 解析显示正常

### ✅ 错误处理
- [ ] 断网时自动回退到 Mock
- [ ] 数据库无题目时显示友好提示
- [ ] 日志清晰显示错误原因

### ✅ 多学科测试
- [ ] Math 题目正常
- [ ] Physics 题目正常
- [ ] Chemistry 题目正常
- [ ] Olympiad 题目正常（如有）

---

## 🚀 下一步优化

### 1. 本地缓存（离线支持）
```dart
// 将 Supabase 数据保存到 SQLite
await DatabaseService().saveQuestions(questions);

// 离线时从本地加载
if (offline) {
  questions = await DatabaseService().getQuestions(subject);
}
```

### 2. 智能推荐
根据用户历史错题推荐复习内容：
```dart
// 获取用户最常错的标签
final weakTags = await UserProgressService().getWeakTags();

// 针对性获取题目
final questions = await QuestionService().fetchQuestions(
  subject: 'math',
  tags: weakTags,
);
```

### 3. 实时更新
使用 Supabase Realtime 监听新题目：
```dart
Supabase.instance.client
  .from('questions')
  .stream(primaryKey: ['id'])
  .listen((data) {
    print('New questions available!');
    _fetchQuestions(); // 刷新
  });
```

---

## 📞 联系方式

遇到问题？
- 查看日志输出（Flutter Console）
- 检查 Supabase Dashboard 数据
- 验证 Question Factory 运行状态
- 尝试设置 `_useRealData = false` 隔离问题

**一切就绪！添加依赖后即可享受从 Supabase 获取真实题目的强大功能！** 🎉
