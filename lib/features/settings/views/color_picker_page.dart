import 'package:flutter/material.dart';
import 'package:onetj/l10n/app_localizations.dart';

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

  Future<void> _showImportDialog(
    BuildContext context,
    ColorPickerViewModel viewModel,
    AppLocalizations l10n,
  ) async {
    final bool? didImport = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ImportDialog(l10n: l10n, viewModel: viewModel);
      },
    );

    if (!context.mounted) {
      return;
    }
    if (didImport == true) {
      _tabController.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.colorPickerImportSuccess),
          duration: const Duration(seconds: 2),
        ),
      );
      await viewModel.applyCurrent();
    }
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
          IconButton(
            tooltip: l10n.colorPickerShare,
            icon: const Icon(Icons.share),
            onPressed: () async {
              final bool ok = await viewModel.copyShareText();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? l10n.copiedToClipboard : l10n.copyFailed,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            tooltip: l10n.colorPickerImport,
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _showImportDialog(context, viewModel, l10n),
          ),
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

class _ImportDialog extends StatefulWidget {
  const _ImportDialog({
    required this.l10n,
    required this.viewModel,
  });

  final AppLocalizations l10n;
  final ColorPickerViewModel viewModel;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.colorPickerImportTitle),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.l10n.colorPickerImportHint,
          errorText: _errorText,
          border: const OutlineInputBorder(),
        ),
        maxLines: 2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.l10n.cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            final ImportColorResult result =
                widget.viewModel.importFromText(_controller.text);
            if (result == ImportColorResult.success) {
              Navigator.of(context).pop(true);
            } else {
              setState(() => _errorText = _errorForResult(result));
            }
          },
          child: Text(widget.l10n.colorPickerImportConfirm),
        ),
      ],
    );
  }

  String _errorForResult(ImportColorResult result) {
    switch (result) {
      case ImportColorResult.emptyInput:
        return widget.l10n.colorPickerImportHint;
      case ImportColorResult.invalidFormat:
        return widget.l10n.colorPickerImportInvalidFormat;
      case ImportColorResult.invalidLightSeed:
        return widget.l10n.colorPickerImportInvalidLightSeed;
      case ImportColorResult.success:
        return '';
    }
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
            final bool isSelected = viewModel.isPresetSelected(preset);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(100),
                        width: 2,
                      )
                    : BorderSide.none,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: preset.lightSeedColor,
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: _checkColorOn(preset.lightSeedColor),
                        )
                      : null,
                ),
                title: Text(preset.name),
                selected: isSelected,
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

  /// 根据背景色计算对勾颜色：浅色底深对勾，深色底浅对勾
  static Color _checkColorOn(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.light
        ? Colors.black87
        : Colors.white;
  }
}
