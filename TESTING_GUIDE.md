# 🧪 测试指南 - 如何验证新功能

## ✅ 1. 语言系统测试 (最准确方法)

### 测试步骤:
1. **打开App** → 进入首页
2. **点击右上角绿色语言按钮** (EN/ZH/ES/JA)
3. **观察变化:**
   - 底部导航栏文字切换 (Home → 首页 → Inicio → ホーム)
   - 学科按钮文字切换 (Math → 数学 → Matemáticas → 数学)
   - 所有页面同步更新

### 验证清单:
- ✅ 点击语言按钮循环切换 4 种语言
- ✅ 切换后立即生效,无需重启
- ✅ 跳转到其他页面后语言保持
- ✅ 无报错或闪退

### 代码位置:
- 语言文件: `assets/i18n/en.json`, `zh.json`, `es.json`, `ja.json`
- 服务代码: `lib/services/translation_service.dart`
- 使用方法: `Tr.get('nav_home')`

---

## ✅ 2. 计算器+输入板测试

### 测试步骤:
1. **打开App** → 点击顶部工具栏"计算器图标"
2. **验证布局:**
   - 上 1/3: 灰色手写画板区域
   - 下 2/3: 白色计算器键盘
3. **测试手写:**
   - 在画板上涂鸦
   - 点击右上角"清除"按钮
4. **测试计算器:**
   - 点击数字键: 7, 8, 9
   - 点击运算符: +, -, ×, ÷
   - 点击 = 号

### 验证清单:
- ✅ 画板可以流畅绘制笔画
- ✅ 清除按钮清空所有笔画
- ✅ 计算器按键响应正确
- ✅ 按键有视觉反馈 (点击效果)
- ✅ WeChat绿色 "=" 按钮突出显示

### 代码位置:
- 画板: `lib/widgets/handwriting_canvas.dart`
- 计算器: `lib/pages/calculator_page.dart`

---

## ⚠️ 3. 相册+PDF测试 (需要先实现)

### 当前状态:
- ✅ 依赖已安装: `file_picker: ^8.1.6`
- ❌ 功能未集成到UI

### 下一步实现后测试:
1. **首页点击"相册按钮"** (左下角图片图标)
2. **选择图片** → 验证跳转到裁剪页
3. **选择PDF** → 验证第一页转为图片

### 临时验证方法:
```bash
# 检查依赖是否安装成功
flutter pub get
grep "file_picker" pubspec.lock
```

---

## ⚠️ 4. DeepSeek服务测试 (需要API Key)

### 当前状态:
- ✅ 代码已重构: `AIService` 替代 `OpenAIService`
- ✅ Prompts已创建: `lib/config/prompts.dart`
- ❌ 未实际调用API

### 测试方法 (有API Key后):
1. **编辑 `.env` 文件:**
```env
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxx
DEEPSEEK_API_BASE_URL=https://api.deepseek.com
```

2. **测试代码 (临时添加到某页面):**
```dart
import 'package:learnest_fresh/services/ai_service.dart';
import 'package:learnest_fresh/config/prompts.dart';

// 测试按钮
ElevatedButton(
  onPressed: () async {
    final aiService = AIService();
    final prompt = AIPrompts.getPrompt('math');
    print('Math Prompt: $prompt');
    
    // TODO: 测试实际API调用
    // final result = await aiService.processImage('path/to/image');
  },
  child: Text('Test DeepSeek'),
)
```

3. **验证:**
- ✅ Prompts正确返回 (Math/Physics/Chemistry/Olympiad)
- ✅ API Key读取成功
- ✅ 请求返回DeepSeek响应

---

## 🎨 5. 首页布局测试 (Gauth风格)

### 测试步骤:
1. **打开App** → 观察首页布局
2. **检查元素位置:**
   - 顶部: 优惠券 | 搜索框 | 计算器 (三栏布局)
   - 中心: 大绿圆 (呼吸动画)
   - 中下: 学科标签横向滚动
   - 底部: 相册 | 快门 | 手电筒 (三个圆按钮)

3. **测试交互:**
   - 点击绿圆 → 跳转相机页
   - 点击快门按钮 → 跳转相机页
   - 点击学科标签 → 高亮选中效果
   - 点击语言按钮 → 切换语言

### 对比参考:
- **Gauth布局:** 十字准星居中 + 底部三按钮
- **我们的布局:** 绿圆居中 + 底部三按钮 (位置对齐)

### 验证清单:
- ✅ 大绿圆在屏幕中心偏上
- ✅ 底部三按钮水平均匀分布
- ✅ 快门按钮最大 (72x72), 两侧按钮稍小 (56x56)
- ✅ 学科标签选中时变绿色背景
- ✅ 语言切换按钮在右上角

---

## 📊 综合测试清单

### 编译测试:
```bash
flutter analyze  # 应该显示 0 errors
flutter run      # 应该成功启动
```

### 功能测试优先级:
1. **P0 (必须测试):**
   - ✅ 语言切换 4 种语言
   - ✅ 首页布局和按钮位置
   - ✅ 计算器+画板布局

2. **P1 (重要但可延后):**
   - ⚠️ 相册选择 (待集成)
   - ⚠️ DeepSeek API (需要Key)

3. **P2 (后续优化):**
   - Logo SVG显示
   - 动画流畅度
   - 性能优化

---

## 🐛 常见问题

### Q: 语言切换后没反应?
**A:** 检查 `main.dart` 是否调用了 `await Tr.init()`

### Q: 计算器画板画不出来?
**A:** 检查 `HandwritingCanvas` 的 `GestureDetector` 是否覆盖整个区域

### Q: 首页按钮位置不对?
**A:** 调整 `screenHeight` 和 `screenWidth` 的百分比参数

### Q: DeepSeek无法调用?
**A:** 确认 `.env` 文件中有 `DEEPSEEK_API_KEY`

---

## ✅ 测试完成标准

**Step 1 完成标准:**
- [ ] 4种语言可切换,无报错
- [ ] 首页布局符合Gauth风格
- [ ] 计算器页面上下布局正确
- [ ] 画板可以涂鸦+清除
- [ ] 所有页面使用 `Tr.get()` 获取文本

**下一步 (Step 2):**
- [ ] 集成相册选择
- [ ] 实现解题页手势滑动
- [ ] 应用深空黑背景
- [ ] 提取雷达图组件
