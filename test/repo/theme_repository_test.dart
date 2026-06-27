import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/theme_preferences.dart';
import 'package:onetj/repo/theme_repository.dart';

void main() {
  // 每个测试前重置单例，确保隔离
  late InMemoryThemeStorage storage;
  late ThemeRepository repo;

  setUp(() {
    storage = InMemoryThemeStorage();
    ThemeRepository.resetForTesting(storage: storage);
    repo = ThemeRepository.getInstance();
  });

  group('ThemeRepository', () {
    group('初始化', () {
      test('初始状态未初始化，使用默认值', () {
        expect(repo.initialized, isFalse);
        expect(repo.preferences, ThemePreferences.defaultPreferences);
      });

      test('initialize 从空存储加载，保持默认值', () async {
        await repo.initialize();

        expect(repo.initialized, isTrue);
        expect(repo.preferences, ThemePreferences.defaultPreferences);
      });

      test('initialize 从已有存储加载', () async {
        const savedPrefs = ThemePreferences(
          name: '已保存',
          lightSeedColor: Color(0xFFABCDEF),
          themeMode: ThemeMode.dark,
        );
        await storage.save(savedPrefs);
        await repo.initialize();

        expect(repo.preferences, savedPrefs);
      });

      test('重复 initialize 不会覆盖已加载数据', () async {
        const savedPrefs = ThemePreferences(
          lightSeedColor: Color(0xFFABCDEF),
        );
        await storage.save(savedPrefs);
        await repo.initialize();

        // 第二次 initialize 应无操作
        await repo.initialize();
        expect(repo.preferences.lightSeedColor, const Color(0xFFABCDEF));
      });

      test('initialize 通知监听者', () async {
        int notifyCount = 0;
        repo.addListener(() => notifyCount++);

        await repo.initialize();

        expect(notifyCount, 1);
      });
    });

    group('保存', () {
      test('save 写入存储并更新 preferences', () async {
        await repo.initialize();
        const newPrefs = ThemePreferences(
          lightSeedColor: Color(0xFF0000FF),
        );

        await repo.save(newPrefs);

        expect(repo.preferences, newPrefs);
        expect(await storage.read(), newPrefs);
      });

      test('save 相同值不重复写入', () async {
        await repo.initialize();
        int notifyCount = 0;
        repo.addListener(() => notifyCount++);

        await repo.save(repo.preferences); // 相同值

        expect(notifyCount, 0);
      });

      test('save 通知监听者', () async {
        await repo.initialize();
        int notifyCount = 0;
        repo.addListener(() => notifyCount++);

        await repo.save(const ThemePreferences(
          lightSeedColor: Color(0xFF00FF00),
        ));

        expect(notifyCount, 1);
      });
    });

    group('便捷方法', () {
      setUp(() async {
        await repo.initialize();
      });

      test('setThemeMode 更新主题模式', () async {
        await repo.setThemeMode(ThemeMode.dark);
        expect(repo.preferences.themeMode, ThemeMode.dark);
      });

      test('setLightSeedColor 更新亮色主色', () async {
        const color = Color(0xFF112233);
        await repo.setLightSeedColor(color);
        expect(repo.preferences.lightSeedColor, color);
      });

      test('setLightSecondaryColor 更新亮色辅色', () async {
        const color = Color(0xFF445566);
        await repo.setLightSecondaryColor(color);
        expect(repo.preferences.lightSecondaryColor, color);
      });

      test('setDarkSeedColor 更新暗色主色', () async {
        const color = Color(0xFF778899);
        await repo.setDarkSeedColor(color);
        expect(repo.preferences.darkSeedColor, color);
      });

      test('setDarkSecondaryColor 更新暗色辅色', () async {
        const color = Color(0xFFAABBCC);
        await repo.setDarkSecondaryColor(color);
        expect(repo.preferences.darkSecondaryColor, color);
      });

      test('reset 恢复默认值', () async {
        // 先修改
        await repo.setThemeMode(ThemeMode.dark);
        await repo.setLightSeedColor(const Color(0xFF000000));

        await repo.reset();

        expect(repo.preferences, ThemePreferences.defaultPreferences);
      });
    });

    group('InMemoryThemeStorage', () {
      test('read 返回 null 当无缓存', () async {
        final s = InMemoryThemeStorage();
        expect(await s.read(), isNull);
      });

      test('save 后 read 返回相同值', () async {
        final s = InMemoryThemeStorage();
        const prefs = ThemePreferences(lightSeedColor: Color(0xFF123456));
        await s.save(prefs);
        expect(await s.read(), prefs);
      });

      test('clear 后 read 返回 null', () async {
        final s = InMemoryThemeStorage();
        await s.save(const ThemePreferences(lightSeedColor: Color(0xFF123456)));
        await s.clear();
        expect(await s.read(), isNull);
      });
    });
  });
}
