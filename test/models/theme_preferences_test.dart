import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/theme_preferences.dart';

void main() {
  const Color testColor = Color(0xFF123456);
  const Color otherColor = Color(0xFF654321);

  group('ThemePreferences', () {
    group('defaultPreferences', () {
      test('使用默认主色且名称为空', () {
        const prefs = ThemePreferences.defaultPreferences;

        expect(prefs.lightSeedColor, ThemePreferences.kDefaultSeedColor);
        expect(prefs.lightSecondaryColor, ThemePreferences.kDefaultSeedColor);
        expect(prefs.darkSeedColor, ThemePreferences.kDefaultSeedColor);
        expect(prefs.darkSecondaryColor, ThemePreferences.kDefaultSeedColor);
        expect(prefs.name, '');
        expect(prefs.themeMode, ThemeMode.system);
        expect(prefs.homeLayout, HomeLayout.bottomNavigation);
      });
    });

    group('JSON 序列化', () {
      test('完整 JSON 往返', () {
        const prefs = ThemePreferences(
          name: '我的主题',
          lightSeedColor: testColor,
          lightSecondaryColor: otherColor,
          darkSeedColor: Color(0xFF000000),
          darkSecondaryColor: Color(0xFFFFFFFF),
          themeMode: ThemeMode.dark,
          homeLayout: HomeLayout.functionGrid,
        );

        final json = prefs.toJson();
        final restored = ThemePreferences.fromJson(json);

        expect(restored, prefs);
      });

      test('最小 JSON（仅必填字段）', () {
        const prefs = ThemePreferences(lightSeedColor: testColor);
        final json = prefs.toJson();
        final restored = ThemePreferences.fromJson(json);

        expect(restored.lightSeedColor, testColor);
        expect(restored.name, '');
        expect(restored.themeMode, ThemeMode.system);
      });

      test('fromJson 缺失字段使用默认值', () {
        final restored = ThemePreferences.fromJson(<String, dynamic>{});

        expect(restored.lightSeedColor, ThemePreferences.kDefaultSeedColor);
        expect(
            restored.lightSecondaryColor, ThemePreferences.kDefaultSeedColor);
        expect(restored.darkSeedColor, ThemePreferences.kDefaultSeedColor);
        expect(restored.darkSecondaryColor, ThemePreferences.kDefaultSeedColor);
        expect(restored.name, '');
        expect(restored.themeMode, ThemeMode.system);
        expect(restored.homeLayout, HomeLayout.bottomNavigation);
      });

      test('fromJson 非法主页布局使用默认值', () {
        final restored = ThemePreferences.fromJson({
          'homeLayout': 'unknown',
        });

        expect(restored.homeLayout, HomeLayout.bottomNavigation);
      });

      test('fromJson 非法颜色值使用默认值', () {
        final restored = ThemePreferences.fromJson({
          'lightSeedColor': 'not-a-number',
          'lightSecondaryColor': 3.14,
        });

        expect(restored.lightSeedColor, ThemePreferences.kDefaultSeedColor);
        expect(
            restored.lightSecondaryColor, ThemePreferences.kDefaultSeedColor);
      });

      test('fromJson 非法 themeMode 使用默认值', () {
        final restored = ThemePreferences.fromJson({
          'themeMode': 'unicorn',
        });

        expect(restored.themeMode, ThemeMode.system);
      });

      test('fromJsonString 解析 JSON 字符串', () {
        const prefs = ThemePreferences(
          name: 'test',
          lightSeedColor: testColor,
        );
        final jsonString = prefs.toJsonString();
        final restored = ThemePreferences.fromJsonString(jsonString);

        expect(restored, prefs);
      });

      test('toJsonString 输出有效 JSON', () {
        const prefs = ThemePreferences(lightSeedColor: testColor);
        final jsonString = prefs.toJsonString();

        expect(jsonString, isA<String>());
        expect(jsonString, contains('lightSeedColor'));
      });
    });

    group('copyWith', () {
      test('部分更新颜色', () {
        const prefs = ThemePreferences(lightSeedColor: testColor);
        final updated = prefs.copyWith(
          lightSeedColor: otherColor,
        );

        expect(updated.lightSeedColor, otherColor);
        // 其他字段保持不变
        expect(updated.lightSecondaryColor, prefs.lightSecondaryColor);
        expect(updated.name, prefs.name);
      });

      test('更新名称和主题模式', () {
        const prefs = ThemePreferences(lightSeedColor: testColor);
        final updated = prefs.copyWith(
          name: '新名称',
          themeMode: ThemeMode.dark,
          homeLayout: HomeLayout.functionGrid,
        );

        expect(updated.name, '新名称');
        expect(updated.themeMode, ThemeMode.dark);
        expect(updated.homeLayout, HomeLayout.functionGrid);
      });

      test('传入 null 保留原值', () {
        const prefs = ThemePreferences(
          name: '保留',
          lightSeedColor: testColor,
        );
        final updated = prefs.copyWith();

        expect(updated, prefs);
      });

      test('传入非 Color 类型保留原值', () {
        const prefs = ThemePreferences(lightSeedColor: testColor);
        final updated = prefs.copyWith(lightSeedColor: 'not-a-color');

        expect(updated.lightSeedColor, testColor);
      });
    });

    group('相等性', () {
      test('相同属性相等', () {
        const a = ThemePreferences(
          name: 'x',
          lightSeedColor: testColor,
          themeMode: ThemeMode.light,
        );
        const b = ThemePreferences(
          name: 'x',
          lightSeedColor: testColor,
          themeMode: ThemeMode.light,
        );

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('不同名称不相等', () {
        const a = ThemePreferences(name: 'a', lightSeedColor: testColor);
        const b = ThemePreferences(name: 'b', lightSeedColor: testColor);

        expect(a, isNot(b));
      });

      test('不同颜色不相等', () {
        const a = ThemePreferences(lightSeedColor: testColor);
        const b = ThemePreferences(lightSeedColor: otherColor);

        expect(a, isNot(b));
      });

      test('hasSameColor 忽略名称和主题模式', () {
        const a = ThemePreferences(
          name: 'a',
          lightSeedColor: testColor,
          lightSecondaryColor: otherColor,
          themeMode: ThemeMode.light,
        );
        const b = ThemePreferences(
          name: 'b',
          lightSeedColor: testColor,
          lightSecondaryColor: otherColor,
          themeMode: ThemeMode.dark,
        );

        expect(a.hasSameColor(b), isTrue);
        expect(a, isNot(b)); // == 仍不相等
      });

      test('hasSameColor 不同颜色返回 false', () {
        const a = ThemePreferences(lightSeedColor: testColor);
        const b = ThemePreferences(lightSeedColor: otherColor);

        expect(a.hasSameColor(b), isFalse);
      });
    });

    group('colorToInt', () {
      test('转换并还原', () {
        const color = Color(0xFF123456);
        final intValue = ThemePreferences.colorToInt(color);
        final restored = Color(intValue);

        expect(restored.toARGB32(), color.toARGB32());
      });

      test('黑色', () {
        expect(
            ThemePreferences.colorToInt(const Color(0xFF000000)), 0xFF000000);
      });

      test('白色', () {
        expect(
            ThemePreferences.colorToInt(const Color(0xFFFFFFFF)), 0xFFFFFFFF);
      });
    });
  });
}
