import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/features/physics_lab/features/franck_hertz/models/franck_hertz_analysis_result.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/view_models/franck_hertz_view_model.dart';
import 'package:onetj/features/physics_lab/widgets/physics_lab_formula.dart';

part 'widgets/franck_hertz_form_widgets.dart';

class FranckHertzView extends StatefulWidget {
  const FranckHertzView({super.key});

  @override
  State<FranckHertzView> createState() => _FranckHertzViewState();
}

class _FranckHertzViewState extends State<FranckHertzView> {
  late final FranckHertzViewModel _viewModel;
  late final TextEditingController _vfController;
  late final TextEditingController _vg1kController;
  late final TextEditingController _vg2aController;
  late final TextEditingController _referenceVoltageController;
  late List<TextEditingController> _vg2kControllers;
  late List<TextEditingController> _ipControllers;

  @override
  void initState() {
    super.initState();
    _viewModel = FranckHertzViewModel();
    _vfController = TextEditingController();
    _vg1kController = TextEditingController();
    _vg2aController = TextEditingController();
    _referenceVoltageController = TextEditingController(
      text: _viewModel.referenceVoltageText,
    );
    _vg2kControllers = <TextEditingController>[];
    _ipControllers = <TextEditingController>[];
    _syncRowControllers();
  }

  @override
  void dispose() {
    _vfController.dispose();
    _vg1kController.dispose();
    _vg2aController.dispose();
    _referenceVoltageController.dispose();
    _disposeControllers(_vg2kControllers);
    _disposeControllers(_ipControllers);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        _syncMetadataControllers();
        _syncReferenceController();
        _syncRowControllers();
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.physicsLabFranckHertzTitle),
            actions: [
              IconButton(
                tooltip: l10n.physicsLabFranckHertzPresetFillLabel,
                onPressed: _handleApplyPreset,
                icon: const Icon(Icons.playlist_add_outlined),
              ),
              IconButton(
                tooltip: l10n.physicsLabFranckHertzAddRowLabel,
                onPressed: _handleAddRow,
                icon: const Icon(Icons.add),
              ),
              IconButton(
                tooltip: l10n.physicsLabFranckHertzClearAllLabel,
                onPressed: _handleClearAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // 实验说明
              _SectionCard(
                title: l10n.physicsLabFranckHertzIntroTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.physicsLabFranckHertzDescription),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: <Widget>[
                        Text(l10n.physicsLabFranckHertzDataFlowHintLeading),
                        const PhysicsLabFormula.inline(tex: r'V_f'),
                        Text(l10n.physicsLabFranckHertzDataFlowHintSeparator),
                        const PhysicsLabFormula.inline(tex: r'V_{G1K}'),
                        Text(l10n.physicsLabFranckHertzDataFlowHintSeparator),
                        const PhysicsLabFormula.inline(tex: r'V_{G2A}'),
                        Text(l10n.physicsLabFranckHertzDataFlowHintMiddle),
                        const PhysicsLabFormula.inline(tex: r'V_{G2K}'),
                        Text(l10n.physicsLabFranckHertzDataFlowHintBetween),
                        const PhysicsLabFormula.inline(tex: r'I_P'),
                        Text(l10n.physicsLabFranckHertzDataFlowHintTrailing),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 基础参数
              _SectionCard(
                title: l10n.physicsLabFranckHertzMetadataTitle,
                child: Column(
                  children: [
                    _NumberField(
                      controller: _vfController,
                      label: const PhysicsLabFormula.inline(tex: r'V_f'),
                      unit: l10n.physicsLabFranckHertzVoltUnit,
                      onChanged: _viewModel.updateVfText,
                    ),
                    const SizedBox(height: 12),
                    _NumberField(
                      controller: _vg1kController,
                      label: const PhysicsLabFormula.inline(tex: r'V_{G1K}'),
                      unit: l10n.physicsLabFranckHertzVoltUnit,
                      onChanged: _viewModel.updateVg1kText,
                    ),
                    const SizedBox(height: 12),
                    _NumberField(
                      controller: _vg2aController,
                      label: const PhysicsLabFormula.inline(tex: r'V_{G2A}'),
                      unit: l10n.physicsLabFranckHertzVoltUnit,
                      onChanged: _viewModel.updateVg2aText,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 原始数据
              _SectionCard(
                title: l10n.physicsLabFranckHertzMeasurementTitle,
                trailing: TextButton.icon(
                  onPressed: _handleAddRow,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.physicsLabFranckHertzAddRowLabel),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MeasurementHeaderRow(
                      rowLabel: l10n.physicsLabFranckHertzRowLabel,
                      actionLabel: l10n.physicsLabFranckHertzActionLabel,
                    ),
                    const SizedBox(height: 8),
                    for (int index = 0;
                        index < _viewModel.rows.length;
                        index += 1)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: index + 1 == _viewModel.rows.length ? 0 : 4,
                        ),
                        // 原始数据输入行
                        child: _MeasurementInputRow(
                          indexText: _viewModel.rows[index].index.toString(),
                          vg2kController: _vg2kControllers[index],
                          ipController: _ipControllers[index],
                          voltHintText: l10n.physicsLabFranckHertzVoltUnit,
                          currentHintText:
                              l10n.physicsLabFranckHertzCurrentUnit,
                          deleteTooltip:
                              l10n.physicsLabFranckHertzDeleteRowLabel,
                          canDelete: _viewModel.rows.length > 1,
                          onVg2kChanged: (String value) {
                            _viewModel.updateRowVg2kText(
                              index,
                              value,
                            );
                          },
                          onIpChanged: (String value) {
                            _viewModel.updateRowIpText(
                              index,
                              value,
                            );
                          },
                          onDelete: () => _handleRemoveRow(index),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // 计算结果
              _SectionCard(
                title: l10n.physicsLabFranckHertzResultTitle,
                child: _buildResultSection(context, l10n),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAddRow() {
    _viewModel.addRow();
    _syncRowControllers();
  }

  void _handleApplyPreset() {
    _viewModel.applyPreset();
    _syncRowControllers();
  }

  void _handleRemoveRow(int rowIndex) {
    _viewModel.removeRow(rowIndex);
    _syncRowControllers();
  }

  void _handleClearAll() {
    _viewModel.clearAll();
    _syncMetadataControllers();
    _syncRowControllers();
  }

  void _syncMetadataControllers() {
    final metadata = _viewModel.metadata;
    _syncControllerText(_vfController, metadata.vfText);
    _syncControllerText(_vg1kController, metadata.vg1kText);
    _syncControllerText(_vg2aController, metadata.vg2aText);
  }

  void _syncReferenceController() {
    _syncControllerText(
      _referenceVoltageController,
      _viewModel.referenceVoltageText,
    );
  }

  void _syncRowControllers() {
    _syncControllerList(
      existing: _vg2kControllers,
      values:
          _viewModel.rows.map((row) => row.vg2kText).toList(growable: false),
    );
    _syncControllerList(
      existing: _ipControllers,
      values: _viewModel.rows.map((row) => row.ipText).toList(growable: false),
    );
  }

  void _syncControllerList({
    required List<TextEditingController> existing,
    required List<String> values,
  }) {
    while (existing.length > values.length) {
      existing.removeLast().dispose();
    }
    while (existing.length < values.length) {
      existing.add(TextEditingController());
    }
    for (int index = 0; index < values.length; index += 1) {
      _syncControllerText(existing[index], values[index]);
    }
  }

  void _syncControllerText(TextEditingController controller, String text) {
    if (controller.text == text) {
      return;
    }
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _disposeControllers(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  Widget _buildResultSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final FranckHertzAnalysisResult result = _viewModel.analysisResult;
    final TextStyle? hintStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.physicsLabFranckHertzResultDescription,
          style: hintStyle,
        ),
        const SizedBox(height: 12),
        // 参考值
        _NumberField(
          controller: _referenceVoltageController,
          label: const PhysicsLabFormula.inline(tex: r'U_0'),
          unit: l10n.physicsLabFranckHertzVoltUnit,
          onChanged: _viewModel.updateReferenceVoltageText,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResultBadge(
              label: l10n.physicsLabFranckHertzValidPointCountLabel,
              value: result.validPoints.length.toString(),
            ),
            _ResultBadge(
              label: l10n.physicsLabFranckHertzSmoothedPointCountLabel,
              value: result.smoothedPoints.length.toString(),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _MethodResultCard(
          title: l10n.physicsLabFranckHertzPeakMethodTitle,
          featureCountLabel: l10n.physicsLabFranckHertzPeakCountLabel,
          intervalLabel: l10n.physicsLabFranckHertzAverageIntervalLabel,
          featureUnit: l10n.physicsLabFranckHertzVoltUnit,
          result: result.peakResult,
          emptyHint: l10n.physicsLabFranckHertzPeakMethodIncompleteHint,
        ),
        const SizedBox(height: 2),
        _MethodResultCard(
          title: l10n.physicsLabFranckHertzValleyMethodTitle,
          featureCountLabel: l10n.physicsLabFranckHertzValleyCountLabel,
          intervalLabel: l10n.physicsLabFranckHertzAverageIntervalLabel,
          featureUnit: l10n.physicsLabFranckHertzVoltUnit,
          result: result.valleyResult,
          emptyHint: l10n.physicsLabFranckHertzValleyMethodIncompleteHint,
        ),
        const SizedBox(height: 2),
        _FinalResultCard(
          finalResultLabel:
              l10n.physicsLabFranckHertzFinalExcitationPotentialLabel,
          referenceLabel: l10n.physicsLabFranckHertzReferenceVoltageLabel,
          relativeErrorLabel: l10n.physicsLabMichelsonRelativeErrorLabel,
          voltageUnit: l10n.physicsLabFranckHertzVoltUnit,
          result: result,
          emptyHint: l10n.physicsLabFranckHertzFinalResultIncompleteHint,
        ),
      ],
    );
  }
}
