import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/settings/view_models/color_picker_view_model.dart';
import 'package:onetj/models/theme_preferences.dart';
import 'package:onetj/repo/color_preset_repository.dart';
import 'package:onetj/repo/theme_repository.dart';

/// 处理所有微任务和定时器事件
Future<void> _pumpEventQueue() async {
  for (int i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// 等待 [vm] 的 [_loadUserPresets] 异步完成。
Future<void> _waitForLoad(ColorPickerViewModel vm) => _pumpEventQueue();

/// 测试用的 ThemeChangeNotifier，使用 InMemoryThemeStorage 隔离
ThemeChangeNotifier _createFakeThemeNotifier() {
  ThemeRepository.resetForTesting();
  final repo = ThemeRepository.getInstance();
  return ThemeChangeNotifier(repository: repo);
}

/// 测试用的 ColorPresetRepository，使用 InMemoryColorPresetStorage 隔离
ColorPresetRepository _createFakePresetRepo() {
  ColorPresetRepository.resetForTesting();
  return ColorPresetRepository.getInstance();
}

void main() {
  late ThemeChangeNotifier themeNotifier;
  late ColorPresetRepository presetRepo;
  late ColorPickerViewModel viewModel;

  const defaultColor = ThemePreferences.kDefaultSeedColor;
  const testColor = Color(0xFF123456);
  const otherColor = Color(0xFF654321);

  setUp(() {
    themeNotifier = _createFakeThemeNotifier();
    presetRepo = _createFakePresetRepo();
    viewModel = ColorPickerViewModel(
      themeChangeNotifier: themeNotifier,
      presetRepository: presetRepo,
    );
  });

  tearDown(() {
    viewModel.dispose();
    themeNotifier.dispose();
  });

  group('ColorPickerViewModel', () {
    // ============================================================
    // 初始状态
    // ============================================================
    group('初始状态', () {
      test('构造时快照当前主题偏好', () {
        expect(viewModel.current, themeNotifier.preferences);
      });

      test('初始 presetName 由 _loadUserPresets 生成', () {
        // _loadUserPresets 在构造时异步调用，空用户预设时生成 '预设1'
        expect(viewModel.presetName, '预设1');
      });

      test('初始 userPresets 为空列表', () {
        expect(viewModel.userPresets, isEmpty);
      });

      test('presets 包含内置预设', () {
        expect(viewModel.presets, containsAll(kPresetColorThemes));
      });

      test('presets 用户预设在内置预设之前', () async {
        // 先保存一个用户预设
        await presetRepo.savePreset(const ThemePreferences(
          name: '我的预设',
          lightSeedColor: testColor,
        ));
        // 重新创建 ViewModel 以加载用户预设
        viewModel.dispose();
        viewModel = ColorPickerViewModel(
          themeChangeNotifier: themeNotifier,
          presetRepository: presetRepo,
        );
        // 等异步加载完成
        await _waitForLoad(viewModel);

        final presets = viewModel.presets;
        expect(presets.first.name, '我的预设');
      });

      test('isUserPreset 正确区分用户/内置预设', () {
        // 0 个用户预设时，所有预设都是内置的
        final presets = viewModel.presets;
        for (int i = 0; i < presets.length; i++) {
          expect(viewModel.isUserPreset(i), isFalse);
        }
      });
    });

    // ============================================================
    // 更新颜色
    // ============================================================
    group('更新颜色', () {
      test('updateLightSeedColor 更新 current 并应用到主题', () async {
        await viewModel.updateLightSeedColor(testColor);

        expect(viewModel.current.lightSeedColor, testColor);
        expect(themeNotifier.preferences.lightSeedColor, testColor);
      });

      test('updateLightSecondaryColor 更新 current 并应用到主题', () async {
        await viewModel.updateLightSecondaryColor(testColor);

        expect(viewModel.current.lightSecondaryColor, testColor);
        expect(themeNotifier.preferences.lightSecondaryColor, testColor);
      });

      test('updateDarkSeedColor 更新 current 并应用到主题', () async {
        await viewModel.updateDarkSeedColor(testColor);

        expect(viewModel.current.darkSeedColor, testColor);
        expect(themeNotifier.preferences.darkSeedColor, testColor);
      });

      test('updateDarkSecondaryColor 更新 current 并应用到主题', () async {
        await viewModel.updateDarkSecondaryColor(testColor);

        expect(viewModel.current.darkSecondaryColor, testColor);
        expect(themeNotifier.preferences.darkSecondaryColor, testColor);
      });

      test('更新颜色后通知监听者', () async {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        await viewModel.updateLightSeedColor(testColor);

        expect(notifyCount, 1);
      });
    });

    // ============================================================
    // 预设管理
    // ============================================================
    group('预设管理', () {
      test('savePreset 空名称生成默认名称', () async {
        await viewModel.updateLightSeedColor(testColor);
        await viewModel.savePreset();

        final presets = viewModel.userPresets;
        expect(presets.length, 1);
        expect(presets.first.name, '预设1');
      });

      test('savePreset 使用自定义名称', () async {
        viewModel.updatePresetName('我的配色');
        await viewModel.updateLightSeedColor(testColor);
        await viewModel.savePreset();

        final presets = viewModel.userPresets;
        expect(presets.first.name, '我的配色');
      });

      test('savePreset 保存后 current 名称更新', () async {
        viewModel.updatePresetName('测试');
        await viewModel.updateLightSeedColor(testColor);
        await viewModel.savePreset();

        expect(viewModel.current.name, '测试');
      });

      test('savePreset 通知监听者', () async {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);
        // 重置计数（构造时的 _loadUserPresets 可能已触发）
        notifyCount = 0;

        await viewModel.updateLightSeedColor(testColor);
        await viewModel.savePreset();

        expect(notifyCount, greaterThan(0));
      });

      test('deletePreset 删除指定索引', () async {
        // 先保存两个预设，在 setUp 的 viewModel 中通过 _loadUserPresets 加载
        await presetRepo.savePreset(const ThemePreferences(
          name: 'A',
          lightSeedColor: Color(0xFFAAAAAA),
        ));
        await presetRepo.savePreset(const ThemePreferences(
          name: 'B',
          lightSeedColor: Color(0xFFBBBBBB),
        ));

        // 重新创建 ViewModel 以触发 _loadUserPresets
        viewModel.dispose();
        viewModel = ColorPickerViewModel(
          themeChangeNotifier: themeNotifier,
          presetRepository: presetRepo,
        );
        await _pumpEventQueue();

        // 直接验证 _userPresets 已加载
        final presets = viewModel.presets;
        expect(presets.where((p) => p.name == 'A'), isNotEmpty);
        expect(presets.where((p) => p.name == 'B'), isNotEmpty);

        // 前两个是用户预设
        expect(viewModel.isUserPreset(0), isTrue);
        expect(viewModel.isUserPreset(1), isTrue);

        await viewModel.deletePreset(0);
        expect(viewModel.userPresets.length, 1);
        expect(viewModel.userPresets.first.name, 'B');
      });

      test('deletePreset 负数索引不操作', () async {
        await presetRepo.savePreset(const ThemePreferences(
          name: 'A',
          lightSeedColor: testColor,
        ));
        viewModel.dispose();
        viewModel = ColorPickerViewModel(
          themeChangeNotifier: themeNotifier,
          presetRepository: presetRepo,
        );
        await _waitForLoad(viewModel);

        await viewModel.deletePreset(-1);

        expect(viewModel.userPresets.length, 1);
      });

      test('deletePreset 越界索引不操作', () async {
        await presetRepo.savePreset(const ThemePreferences(
          name: 'A',
          lightSeedColor: testColor,
        ));
        viewModel.dispose();
        viewModel = ColorPickerViewModel(
          themeChangeNotifier: themeNotifier,
          presetRepository: presetRepo,
        );
        await _waitForLoad(viewModel);

        await viewModel.deletePreset(999);

        expect(viewModel.userPresets.length, 1);
      });
    });

    // ============================================================
    // selectPreset
    // ============================================================
    group('selectPreset', () {
      test('选择预设后 current 颜色更新', () async {
        const preset = ThemePreferences(
          name: '测试预设',
          lightSeedColor: testColor,
          lightSecondaryColor: otherColor,
        );

        await viewModel.selectPreset(preset);

        expect(viewModel.current.lightSeedColor, testColor);
        expect(viewModel.current.lightSecondaryColor, otherColor);
        expect(viewModel.presetName, '测试预设');
      });

      test('选择预设后应用到主题', () async {
        const preset = ThemePreferences(
          lightSeedColor: testColor,
        );

        await viewModel.selectPreset(preset);

        expect(themeNotifier.preferences.lightSeedColor, testColor);
      });
    });

    // ============================================================
    // undo
    // ============================================================
    group('undo', () {
      test('undo 恢复颜色到快照', () async {
        final snapshot = viewModel.current;
        await viewModel.updateLightSeedColor(testColor);

        await viewModel.undo();

        expect(viewModel.current.lightSeedColor, snapshot.lightSeedColor);
      });

      test('undo 通知监听者', () async {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);
        await viewModel.updateLightSeedColor(testColor);
        notifyCount = 0; // 重置

        await viewModel.undo();

        expect(notifyCount, 1);
      });
    });

    // ============================================================
    // 分享导入
    // ============================================================
    group('分享导入', () {
      test('shareText 格式为 4 段 8 位 hex', () {
        final text = viewModel.shareText;

        // 格式: #RRGGBBAA#RRGGBBAA#RRGGBBAA#RRGGBBAA
        final parts = text.split('#');
        expect(parts.length, 5); // 第一段为空
        for (int i = 1; i <= 4; i++) {
          expect(parts[i].length, 8);
          expect(int.tryParse(parts[i], radix: 16), isNotNull);
        }
      });

      test('importFromText 空字符串返回 emptyInput', () {
        final result = viewModel.importFromText('');
        expect(result, ImportColorResult.emptyInput);
      });

      test('importFromText 格式错误返回 invalidFormat', () {
        final result = viewModel.importFromText('#AABBCCDD');
        expect(result, ImportColorResult.invalidFormat);
      });

      test('importFromText 无效主色返回 invalidLightSeed', () {
        final result = viewModel.importFromText('#zzzzzzzz#AABBCCDD#AABBCCDD#AABBCCDD');
        expect(result, ImportColorResult.invalidLightSeed);
      });

      test('importFromText 成功导入更新 current', () {
        final result = viewModel.importFromText(
          '#ff123456#ff654321#ffaabbcc#ffddeeff',
        );

        expect(result, ImportColorResult.success);
        expect(viewModel.current.lightSeedColor, const Color(0xFF123456));
        expect(viewModel.current.lightSecondaryColor, const Color(0xFF654321));
        expect(viewModel.current.darkSeedColor, const Color(0xFFAABBCC));
        expect(viewModel.current.darkSecondaryColor, const Color(0xFFDDEEFF));
      });

      test('importFromText 空段保留原色', () {
        final original = viewModel.current.lightSecondaryColor;

        final result = viewModel.importFromText(
          '#ff123456###',
        );

        expect(result, ImportColorResult.success);
        expect(viewModel.current.lightSeedColor, const Color(0xFF123456));
        // 空段保留原值
        expect(viewModel.current.lightSecondaryColor, original);
      });

      test('importFromText 成功后清空 presetName', () {
        viewModel.updatePresetName('旧名称');

        viewModel.importFromText('#ff123456#ff654321#ffaabbcc#ffddeeff');

        expect(viewModel.presetName, '');
      });
    });

    // ============================================================
    // isPresetSelected
    // ============================================================
    group('isPresetSelected', () {
      test('颜色匹配返回 true', () {
        final current = viewModel.current;
        expect(viewModel.isPresetSelected(current), isTrue);
      });

      test('颜色不匹配返回 false', () {
        const different = ThemePreferences(
          lightSeedColor: Color(0xFFFFFFFF),
        );
        expect(viewModel.isPresetSelected(different), isFalse);
      });
    });

    // ============================================================
    // updatePresetName
    // ============================================================
    group('updatePresetName', () {
      test('更新 presetName 并通知监听者', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.updatePresetName('新名称');

        expect(viewModel.presetName, '新名称');
        expect(notifyCount, 1);
      });
    });
  });
}
