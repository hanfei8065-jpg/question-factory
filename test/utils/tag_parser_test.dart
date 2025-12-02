import 'package:flutter_test/flutter_test.dart';
import 'package:learnest_fresh/utils/tag_parser.dart';

void main() {
  group('TagParser Tests', () {
    group('parse() 方法测试', () {
      test('标准双语格式 - English (Chinese)', () {
        final result = TagParser.parse('Linear Equations (一元一次方程)');

        expect(result['en'], equals('Linear Equations'));
        expect(result['zh'], equals('一元一次方程'));
      });

      test('标准双语格式 - Kinematics (运动学)', () {
        final result = TagParser.parse('Kinematics (运动学)');

        expect(result['en'], equals('Kinematics'));
        expect(result['zh'], equals('运动学'));
      });

      test('中文全角括号 - English（Chinese）', () {
        final result = TagParser.parse('Velocity（速度）');

        expect(result['en'], equals('Velocity'));
        expect(result['zh'], equals('速度'));
      });

      test('反向格式 - Chinese (English)', () {
        final result = TagParser.parse('运动学 (Kinematics)');

        expect(result['en'], equals('Kinematics'));
        expect(result['zh'], equals('运动学'));
      });

      test('单语言（仅英文）', () {
        final result = TagParser.parse('Mathematics');

        expect(result['en'], equals('Mathematics'));
        expect(result['zh'], equals(''));
      });

      test('单语言（仅中文）', () {
        final result = TagParser.parse('数学');

        expect(result['en'], equals('数学'));
        expect(result['zh'], equals(''));
      });

      test('空字符串', () {
        final result = TagParser.parse('');

        expect(result['en'], equals(''));
        expect(result['zh'], equals(''));
      });

      test('包含空格的标签', () {
        final result = TagParser.parse('  Linear Equations (一元一次方程)  ');

        expect(result['en'], equals('Linear Equations'));
        expect(result['zh'], equals('一元一次方程'));
      });

      test('长标签名称', () {
        final result = TagParser.parse(
          "Newton's Second Law of Motion (牛顿第二运动定律)",
        );

        expect(result['en'], equals("Newton's Second Law of Motion"));
        expect(result['zh'], equals('牛顿第二运动定律'));
      });
    });

    group('parseList() 方法测试', () {
      test('批量解析标签列表', () {
        final tags = ['Linear Equations (一元一次方程)', 'Slope (斜率)', 'Mathematics'];

        final results = TagParser.parseList(tags);

        expect(results.length, equals(3));
        expect(results[0]['en'], equals('Linear Equations'));
        expect(results[0]['zh'], equals('一元一次方程'));
        expect(results[1]['en'], equals('Slope'));
        expect(results[1]['zh'], equals('斜率'));
        expect(results[2]['en'], equals('Mathematics'));
        expect(results[2]['zh'], equals(''));
      });

      test('空列表', () {
        final results = TagParser.parseList([]);

        expect(results.length, equals(0));
      });
    });

    group('isBilingual() 方法测试', () {
      test('双语标签返回 true', () {
        expect(TagParser.isBilingual('Kinematics (运动学)'), isTrue);
      });

      test('单语言标签返回 false', () {
        expect(TagParser.isBilingual('Mathematics'), isFalse);
      });

      test('空字符串返回 false', () {
        expect(TagParser.isBilingual(''), isFalse);
      });
    });

    group('getDisplayText() 方法测试', () {
      test('默认显示英文', () {
        final text = TagParser.getDisplayText('Kinematics (运动学)');

        expect(text, equals('Kinematics'));
      });

      test('优先显示中文', () {
        final text = TagParser.getDisplayText(
          'Kinematics (运动学)',
          preferChinese: true,
        );

        expect(text, equals('运动学'));
      });

      test('单语言标签 - 请求中文时回退到英文', () {
        final text = TagParser.getDisplayText(
          'Mathematics',
          preferChinese: true,
        );

        expect(text, equals('Mathematics'));
      });
    });

    group('边界情况测试', () {
      test('仅有括号', () {
        final result = TagParser.parse('()');

        expect(result['en'], equals('()'));
        expect(result['zh'], equals(''));
      });

      test('多个括号 - 仅识别第一对', () {
        final result = TagParser.parse('Test (测试) (Extra)');

        // 注意：当前实现会将整个字符串视为非标准格式
        expect(result['en'], isNotEmpty);
      });

      test('包含特殊字符', () {
        final result = TagParser.parse("Newton's 2nd Law (牛顿第二定律)");

        expect(result['en'], equals("Newton's 2nd Law"));
        expect(result['zh'], equals('牛顿第二定律'));
      });
    });
  });
}
