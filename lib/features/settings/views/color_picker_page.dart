import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/settings/view_models/color_picker_view_model.dart';
import 'package:onetj/features/settings/views/widgets/custom_color_tab.dart';
import 'package:onetj/models/theme_preferences.dart';

/// 配色方案选择页面
///
/// 主 Tab 分为"预设"和"自定义"，自定义下含子 Tab 切换四个颜色属性。
class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({
    required this.viewModel,
    super.key,
  });

  final ColorPickerViewModel viewModel;

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorPickerViewModel viewModel = widget.viewModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.colorPickerTitle),
        actions: [
          IconButton(
            tooltip: l10n.colorPickerUndo,
            icon: const Icon(Icons.undo),
            onPressed: () => viewModel.undo(),
          ),
          // TODO 分享功能
          // IconButton(
          //   tooltip: l10n.colorPickerShare,
          //   icon: const Icon(Icons.share),
          //   onPressed: () {},
          // ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.colorPickerPresetsTab),
            Tab(text: l10n.colorPickerCustomTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ColorPresetsTab(l10n: l10n, viewModel: viewModel),
          CustomColorTab(
          l10n: l10n,
          viewModel: viewModel,
          onSaved: () => Navigator.of(context).pop(),
        ),
        ],
      ),
    );
  }
}

class _ColorPresetsTab extends StatelessWidget {
  const _ColorPresetsTab({
    required this.l10n,
    required this.viewModel,
  });

  final AppLocalizations l10n;
  final ColorPickerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (BuildContext context, Widget? child) {
        final List<ThemePreferences> presets = viewModel.presets;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: presets.length,
          itemBuilder: (BuildContext context, int index) {
            final ThemePreferences preset = presets[index];
            final bool isUser = viewModel.isUserPreset(index);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: preset.lightSeedColor,
                ),
                title: Text(preset.name),
                trailing: isUser
                    ? IconButton(
                        tooltip: l10n.colorPickerDeletePreset,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => viewModel.deletePreset(index),
                      )
                    : null,
                onTap: () => viewModel.selectPreset(preset),
              ),
            );
          },
        );
      },
    );
  }
}