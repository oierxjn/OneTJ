import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/theme_preferences.dart';
import 'package:onetj/repo/color_preset_repository.dart';

void main() {
  late InMemoryColorPresetStorage storage;
  late ColorPresetRepository repo;

  setUp(() {
    storage = InMemoryColorPresetStorage();
    repo = ColorPresetRepository(storage: storage);
  });

  const presetA = ThemePreferences(
    name: '预设A',
    lightSeedColor: Color(0xFF111111),
  );
  const presetB = ThemePreferences(
    name: '预设B',
    lightSeedColor: Color(0xFF222222),
  );
  const presetC = ThemePreferences(
    name: '预设C',
    lightSeedColor: Color(0xFF333333),
  );

  group('ColorPresetRepository', () {
    group('getPresets', () {
      test('空存储返回空列表', () async {
        final presets = await repo.getPresets();
        expect(presets, isEmpty);
      });

      test('返回已保存的预设', () async {
        await repo.savePreset(presetA);
        await repo.savePreset(presetB);

        final presets = await repo.getPresets();
        expect(presets, [presetA, presetB]);
      });
    });

    group('savePreset', () {
      test('追加到列表末尾', () async {
        await repo.savePreset(presetA);
        await repo.savePreset(presetB);

        final presets = await repo.getPresets();
        expect(presets.length, 2);
        expect(presets.last, presetB);
      });
    });

    group('deletePreset', () {
      test('删除指定索引', () async {
        await repo.savePreset(presetA);
        await repo.savePreset(presetB);
        await repo.savePreset(presetC);

        await repo.deletePreset(1); // 删除 presetB

        final presets = await repo.getPresets();
        expect(presets, [presetA, presetC]);
      });

      test('负数索引不操作', () async {
        await repo.savePreset(presetA);
        await repo.deletePreset(-1);

        final presets = await repo.getPresets();
        expect(presets.length, 1);
      });

      test('越界索引不操作', () async {
        await repo.savePreset(presetA);
        await repo.deletePreset(999);

        final presets = await repo.getPresets();
        expect(presets.length, 1);
      });

      test('空列表删除不抛异常', () async {
        await repo.deletePreset(0); // 不应抛异常
      });
    });

    group('InMemoryColorPresetStorage', () {
      test('read 返回空列表当无缓存', () async {
        final s = InMemoryColorPresetStorage();
        expect(await s.read(), isEmpty);
      });

      test('save 后 read 返回相同值', () async {
        final s = InMemoryColorPresetStorage();
        await s.save([presetA, presetB]);
        expect(await s.read(), [presetA, presetB]);
      });

      test('clear 后 read 返回空列表', () async {
        final s = InMemoryColorPresetStorage();
        await s.save([presetA]);
        await s.clear();
        expect(await s.read(), isEmpty);
      });
    });
  });
}
