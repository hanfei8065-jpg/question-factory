#!/bin/bash
# Learnist 垃圾文件删除脚本

echo "🗑️  开始清理垃圾文件..."

# 1. 删除 /tmp 隔离区
echo "删除 /tmp/learnest_broken_code_backup/..."
rm -rf /tmp/learnest_broken_code_backup/

# 2. 删除 .disabled 文件
echo "删除 *.disabled 文件..."
rm -f lib/utils/image_processor.dart.disabled

# 3. 删除占位符文件
echo "删除 placeholder 文件..."
rm -f lib/pages/camera_page_placeholder.dart

# 4. 删除遗留脚本
echo "删除遗留脚本..."
rm -f scripts/purge_legacy_questions.js

# 5. 删除重复页面 (保留 app_* 版本)
echo "删除重复页面..."
cd lib/pages
# 删除旧的 question_bank (保留 app_question_bank)
rm -f question_bank_page.dart
# 删除旧的 profile (保留 app_profile)
rm -f profile_page.dart
# 删除旧的 solving (保留 app_question_arena)
rm -f solve_page.dart solving_page.dart
# 删除测试页面
rm -f camera_test_page.dart
rm -f bilingual_tag_demo_page.dart
# 删除引导页 (已有 splash)
rm -f camera_guide_page.dart

cd ../..

echo "✅ 清理完成!"
echo ""
echo "剩余垃圾文件检查:"
find lib -name "*.disabled" -o -name "*.bak*" -o -name "*placeholder*"
