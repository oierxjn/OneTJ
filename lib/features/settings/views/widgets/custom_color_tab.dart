import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/settings/view_models/color_picker_view_model.dart';

/// 可编辑的颜色属性枚举
enum _EditableColor {
  lightSeed,
  lightSecondary,
  darkSeed,
  darkSecondary;
}

/// 自定义调色 Tab
///
/// 包含子 Tab 切换四个颜色属性，每个属性对应一个取色器。
class CustomColorTab extends StatelessWidget {
  const CustomColorTab({
    required this.l10n,
    required this.viewModel,
    this.onSaved,
    super.key,
  });

  final AppLocalizations l10n;
  final ColorPickerViewModel viewModel;
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (BuildContext context, Widget? child) {
        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              // 预设名称输入 + 保存按钮
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: ValueKey<String>(viewModel.presetName),
                        controller: TextEditingController(
                          text: viewModel.presetName,
                        ),
                        onChanged: viewModel.updatePresetName,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: l10n.colorPickerPresetNameHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () async {
                        await viewModel.savePreset();
                        onSaved?.call();
                      },
                      child: Text(l10n.saveLabel),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: l10n.colorPickerLightSeed),
                  Tab(text: l10n.colorPickerLightSecondary),
                  Tab(text: l10n.colorPickerDarkSeed),
                  Tab(text: l10n.colorPickerDarkSecondary),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildColorPicker(
                      _EditableColor.lightSeed,
                      viewModel.current.lightSeedColor,
                    ),
                    _buildColorPicker(
                      _EditableColor.lightSecondary,
                      viewModel.current.lightSecondaryColor ?? viewModel.current.lightSeedColor,
                    ),
                    _buildColorPicker(
                      _EditableColor.darkSeed,
                      viewModel.current.effectiveDarkSeedColor,
                    ),
                    _buildColorPicker(
                      _EditableColor.darkSecondary,
                      viewModel.current.effectiveDarkSecondaryColor ?? viewModel.current.effectiveDarkSeedColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorPicker(
    _EditableColor target,
    Color currentColor,
  ) {
    final bool isSecondary = target == _EditableColor.lightSecondary ||
        target == _EditableColor.darkSecondary;
    final bool isDark = target == _EditableColor.darkSeed ||
        target == _EditableColor.darkSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 颜色预览
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          // 取色器
          ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (Color color) {
              _onColorChanged(target, color);
            },
            enableAlpha: false,
            hexInputBar: true,
            portraitOnly: true,
          ),
          // 辅色/暗色清空按钮
          if (isSecondary || isDark)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => _onColorCleared(target),
                child: Text(l10n.settingsLaunchWallpaperResetAction),
              ),
            ),
        ],
      ),
    );
  }

  void _onColorChanged(_EditableColor target, Color color) {
    switch (target) {
      case _EditableColor.lightSeed:
        viewModel.updateLightSeedColor(color);
      case _EditableColor.lightSecondary:
        viewModel.updateLightSecondaryColor(color);
      case _EditableColor.darkSeed:
        viewModel.updateDarkSeedColor(color);
      case _EditableColor.darkSecondary:
        viewModel.updateDarkSecondaryColor(color);
    }
  }

  void _onColorCleared(_EditableColor target) {
    switch (target) {
      case _EditableColor.lightSecondary:
        viewModel.updateLightSecondaryColor(null);
      case _EditableColor.darkSeed:
        viewModel.updateDarkSeedColor(null);
      case _EditableColor.darkSecondary:
        viewModel.updateDarkSecondaryColor(null);
      case _EditableColor.lightSeed:
        // 主色不允许清空
        break;
    }
  }
}