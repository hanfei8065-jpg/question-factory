# Learnist 代码清理计划

## 🎯 目标: 唯一真相源 (Single Source of Truth)

### 📋 待删除文件清单

#### ✅ 立即删除 (100%垃圾):
1. `/tmp/learnest_broken_code_backup/` - 整个目录 (20个旧文件)
2. `lib/utils/image_processor.dart.disabled`
3. `lib/pages/camera_page_placeholder.dart` (临时占位)
4. `scripts/purge_legacy_questions.js` (遗留脚本)

#### ⚠️ 需要确认的文件:
- `lib/data/` 目录 - 检查是否还在使用
- `lib/pages/` 中是否有重复页面

---

## 📁 唯一真相架构

### Pages (每个功能一个文件):
```
lib/pages/
├── home_page.dart              ✅ 唯一首页
├── app_question_bank_page.dart ✅ Dr. Logic聊天
├── app_question_arena_page.dart ✅ 竞技场
├── session_summary_page.dart   ✅ 总结页
├── app_camera_page.dart        ✅ 相机页
└── app_profile_page.dart       ✅ 个人中心
```

### Services (每个服务一个文件):
```
lib/services/
├── translation_service.dart    ✅ 4语言翻译
├── user_progress_service.dart  ✅ 用户进度
├── question_service.dart       ✅ 题目管理
└── supabase_service.dart      ✅ 后端API
```

### Models (每个数据模型一个文件):
```
lib/models/
├── question.dart              ✅ 题目模型
└── user_progress.dart         ✅ 进度模型
```

---

## 🚀 执行步骤

### 1. 备份当前工作代码
```bash
git add -A
git commit -m "Backup before cleanup"
git push
```

### 2. 删除垃圾文件
```bash
rm -rf /tmp/learnest_broken_code_backup/
rm lib/utils/image_processor.dart.disabled
rm lib/pages/camera_page_placeholder.dart
rm scripts/purge_legacy_questions.js
```

### 3. 清理 build 缓存
```bash
flutter clean
rm -rf ios/Pods/
rm ios/Podfile.lock
```

### 4. 全新编译
```bash
cd ios && pod install
cd .. && flutter run --release
```

---

## ✅ 验证清理成功

- [ ] `find lib -name "*.disabled"` 返回空
- [ ] `find lib -name "*.bak*"` 返回空
- [ ] `find lib -name "*placeholder*"` 返回空
- [ ] App 成功编译且运行正常
- [ ] 所有页面都是唯一真相源

---

**原则**: 一个功能 = 一个文件,绝不保留备份版本在代码库中!
