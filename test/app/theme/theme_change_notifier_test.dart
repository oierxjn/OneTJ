import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/models/theme_preferences.dart';
import 'package:onetj/repo/theme_repository.dart';

void main() {
  late InMemoryThemeStorage storage;
  late ThemeRepository repo;
  late ThemeChangeNotifier notifier;

  setUp(() {
    storage = InMemoryThemeStorage();
    repo = ThemeRepository(storage: storage);
    notifier = ThemeChangeNotifier(repository: repo);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('ThemeChangeNotifier', () {
    group('初始状态', () {
      test('未初始化时 initialized 为 false', () {
        expect(notifier.initialized, isFalse);
      });

      test('未初始化时使用默认偏好', () {
        expect(notifier.preferences, ThemePreferences.defaultPreferences);
      });

      test('未初始化时仍有有效的 ColorScheme', () {
        expect(notifier.lightColorScheme, isA<ColorScheme>());
        expect(notifier.darkColorScheme, isA<ColorScheme>());
      });

      test('themeMode 反映 repository 当前值', () {
        expect(notifier.themeMode, ThemeMode.system);
      });
    });

    group('initialize', () {
      test('初始化后 initialized 为 true', () async {
        await notifier.initialize();
        expect(notifier.initialized, isTrue);
      });

      test('初始化后加载存储中的值', () async {
        const savedPrefs = ThemePreferences(
          lightSeedColor: Color(0xFFABCDEF),
          themeMode: ThemeMode.dark,
        );
        await storage.save(savedPrefs);
        await notifier.initialize();

        expect(notifier.preferences.lightSeedColor, const Color(0xFFABCDEF));
        expect(notifier.themeMode, ThemeMode.dark);
      });
    });

    group('updatePreferences', () {
      test('更新后 preferences 变化', () async {
        await notifier.initialize();
        const newPrefs = ThemePreferences(
          lightSeedColor: Color(0xFF0000FF),
        );

        await notifier.updatePreferences(newPrefs);

        expect(notifier.preferences.lightSeedColor, const Color(0xFF0000FF));
      });

      test('更新后通知监听者', () async {
        await notifier.initialize();
        int notifyCount = 0;
        notifier.addListener(() => notifyCount++);

        await notifier.updatePreferences(const ThemePreferences(
          lightSeedColor: Color(0xFF00FF00),
        ));

        expect(notifyCount, 1);
      });
    });

    group('便捷方法', () {
      setUp(() async {
        await notifier.initialize();
      });

      test('setThemeMode', () async {
        await notifier.setThemeMode(ThemeMode.dark);
        expect(notifier.themeMode, ThemeMode.dark);
      });

      test('setHomeLayout 通知并更新主页布局', () async {
        int notifyCount = 0;
        notifier.addListener(() => notifyCount++);

        await notifier.setHomeLayout(HomeLayout.functionGrid);

        expect(notifier.preferences.homeLayout, HomeLayout.functionGrid);
        expect(notifyCount, 1);
      });

      test('setLightSeedColor', () async {
        const color = Color(0xFF112233);
        await notifier.setLightSeedColor(color);
        expect(notifier.preferences.lightSeedColor, color);
      });

      test('setDarkSeedColor', () async {
        const color = Color(0xFF445566);
        await notifier.setDarkSeedColor(color);
        expect(notifier.preferences.darkSeedColor, color);
      });

      test('reset', () async {
        await notifier.setThemeMode(ThemeMode.dark);
        await notifier.setLightSeedColor(const Color(0xFF000000));

        await notifier.reset();

        expect(notifier.preferences, ThemePreferences.defaultPreferences);
      });
    });

    group('ColorScheme 重建', () {
      test('updatePreferences 后 ColorScheme 更新', () async {
        await notifier.initialize();
        final oldLight = notifier.lightColorScheme;

        await notifier.updatePreferences(const ThemePreferences(
          lightSeedColor: Color(0xFF00FF00),
        ));

        // ColorScheme 应已更新（不同种子颜色产生不同 scheme）
        expect(notifier.lightColorScheme, isNot(oldLight));
      });
    });
  });
}
