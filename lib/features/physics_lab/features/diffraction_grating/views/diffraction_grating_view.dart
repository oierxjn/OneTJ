import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_angle.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_calibration_result.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_wavelength_result.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/view_models/diffraction_grating_view_model.dart';
import 'package:onetj/features/physics_lab/widgets/physics_lab_formula.dart';

part 'widgets/diffraction_grating_form_widgets.dart';

const String _degreeSymbol = '\u00B0';

class DiffractionGratingView extends StatefulWidget {
  const DiffractionGratingView({required this.viewModel, super.key});

  final DiffractionGratingViewModel viewModel;

  @override
  State<DiffractionGratingView> createState() => _DiffractionGratingViewState();
}

class _DiffractionGratingViewState extends State<DiffractionGratingView> {
  late final DiffractionGratingViewModel _viewModel;
  late final TextEditingController _calibrationReferenceController;
  late final List<List<_AngleFieldControllers>> _calibrationControllers;
  late final List<TextEditingController> _groupReferenceControllers;
  late final List<List<List<_AngleFieldControllers>>> _groupControllers;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    _calibrationReferenceController = TextEditingController(
      text: _viewModel.calibrationReferenceText,
    );
    _calibrationControllers = List<List<_AngleFieldControllers>>.generate(
      DiffractionGratingViewModel.calibrationRowCount,
      (int rowIndex) => List<_AngleFieldControllers>.generate(
        DiffractionGratingViewModel.readingCountPerRow,
        (int readingIndex) => _AngleFieldControllers.fromCombinedText(
          _viewModel.calibrationTexts[rowIndex][readingIndex],
        ),
        growable: false,
      ),
      growable: false,
    );
    _groupReferenceControllers = List<TextEditingController>.generate(
      DiffractionGratingViewModel.wavelengthGroupCount,
      (int groupIndex) => TextEditingController(
        text: _viewModel.referenceWavelengthTexts[groupIndex],
      ),
      growable: false,
    );
    _groupControllers = List<List<List<_AngleFieldControllers>>>.generate(
      DiffractionGratingViewModel.wavelengthGroupCount,
      (int groupIndex) => List<List<_AngleFieldControllers>>.generate(
        DiffractionGratingViewModel.wavelengthRowCount,
        (int rowIndex) => List<_AngleFieldControllers>.generate(
          DiffractionGratingViewModel.readingCountPerRow,
          (int readingIndex) => _AngleFieldControllers.fromCombinedText(
            _viewModel.wavelengthTexts[groupIndex][rowIndex][readingIndex],
          ),
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );
    _viewModel.load().then((_) {
      if (mounted) {
        _syncControllersFromViewModel();
      }
    });
  }

  @override
  void dispose() {
    _calibrationReferenceController.dispose();
    for (final List<_AngleFieldControllers> row in _calibrationControllers) {
      for (final _AngleFieldControllers controllers in row) {
        controllers.dispose();
      }
    }
    for (final TextEditingController controller in _groupReferenceControllers) {
      controller.dispose();
    }
    for (final List<List<_AngleFieldControllers>> group in _groupControllers) {
      for (final List<_AngleFieldControllers> row in group) {
        for (final _AngleFieldControllers controllers in row) {
          controllers.dispose();
        }
      }
    }
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (BuildContext context, _) {
        final DiffractionGratingCalibrationResult? calibrationResult =
            _viewModel.calibrationResult;
        final List<List<DiffractionGratingWavelengthRowResult?>>
            wavelengthRowResults = _viewModel.wavelengthRowResults;
        final List<DiffractionGratingWavelengthGroupResult?> wavelengthResults =
            _viewModel.wavelengthResults;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.physicsLabDiffractionGratingTitle),
            actions: [
              IconButton(
                tooltip: l10n.physicsLabDiffractionGratingPresetFillLabel,
                onPressed: _applyDefaultPreset,
                icon: const Icon(Icons.playlist_add_outlined),
              ),
              IconButton(
                tooltip: l10n.physicsLabDiffractionGratingClearAllLabel,
                onPressed: _clearAllInputs,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(6),
            children: [
              _InfoCard(
                title: l10n.physicsLabDiffractionGratingFormulaTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.physicsLabDiffractionGratingDescription),
                    const SizedBox(height: 8),
                    Text(l10n.physicsLabDiffractionGratingFormulaBody),
                    const SizedBox(height: 8),
                    const PhysicsLabFormula.block(
                      tex:
                          r'\gamma=\frac{\left|\alpha_2-\alpha_1\right|+\left|\alpha_2^\prime-\alpha_1^\prime\right|}{4}',
                    ),
                    const SizedBox(height: 8),
                    const PhysicsLabFormula.block(
                      tex: r'd=\frac{k\lambda_0}{\sin\gamma}',
                    ),
                    const SizedBox(height: 8),
                    const PhysicsLabFormula.block(
                      tex: r'\lambda=\frac{d\sin\gamma}{k}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildCalibrationCard(l10n, calibrationResult),
              const SizedBox(height: 8),
              _buildWavelengthGroupCard(
                l10n: l10n,
                groupIndex: 0,
                rowResults: wavelengthRowResults[0],
                result: wavelengthResults[0],
              ),
              const SizedBox(height: 8),
              _buildWavelengthGroupCard(
                l10n: l10n,
                groupIndex: 1,
                rowResults: wavelengthRowResults[1],
                result: wavelengthResults[1],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalibrationCard(
    AppLocalizations l10n,
    DiffractionGratingCalibrationResult? result,
  ) {
    final _MeasurementRowCardResult? rowResult = result == null
        ? null
        : _buildCalibrationRowCardResult(
            l10n: l10n,
            rowResult: result.rows.first,
          );
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.physicsLabDiffractionGratingWavelengthSectionTitle(1),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.physicsLabDiffractionGratingCalibrationHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            // 输入校准参考波长
            _NumericTextField(
              controller: _calibrationReferenceController,
              label: l10n.physicsLabDiffractionGratingCalibrationReferenceLabel,
              unit: l10n.physicsLabMichelsonNanometerUnit,
              onChanged: _viewModel.updateCalibrationReferenceText,
            ),
            const SizedBox(height: 8),
            _MeasurementRowCard(
              title: l10n.physicsLabDiffractionGratingWavelengthRowTitle(
                DiffractionGratingViewModel.calibrationOrders.first,
              ),
              controllers: _calibrationControllers.first,
              labels: _readingLabelTexes(),
              onChanged: (int readingIndex, String value) {
                _viewModel.updateCalibrationReading(0, readingIndex, value);
              },
              result: rowResult,
              showPrimaryBadge: false,
            ),
            const Divider(height: 20),
            if (result == null)
              Text(
                l10n.physicsLabDiffractionGratingCalibrationIncompleteHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              _ResultRow(
                label: Text(
                  l10n.physicsLabDiffractionGratingAverageGratingConstantLabel,
                ),
                value:
                    '${_formatMillimeter(result.averageGratingConstantMm)} ${l10n.physicsLabMichelsonMillimeterUnit}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWavelengthGroupCard({
    required AppLocalizations l10n,
    required int groupIndex,
    required List<DiffractionGratingWavelengthRowResult?> rowResults,
    required DiffractionGratingWavelengthGroupResult? result,
  }) {
    final DiffractionGratingCalibrationResult? calibrationResult =
        _viewModel.calibrationResult;
    final bool calibrationReady = calibrationResult != null;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.physicsLabDiffractionGratingWavelengthSectionTitle(
                groupIndex + 2,
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.physicsLabDiffractionGratingWavelengthHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            _ReadOnlySummaryTile(
              label: l10n.physicsLabDiffractionGratingInheritedGratingConstant,
              value: calibrationReady
                  ? '${_formatMillimeter(calibrationResult.averageGratingConstantMm)} ${l10n.physicsLabMichelsonMillimeterUnit}'
                  : l10n.physicsLabDiffractionGratingNeedCalibrationHint,
            ),
            const SizedBox(height: 8),
            _NumericTextField(
              controller: _groupReferenceControllers[groupIndex],
              label: l10n.physicsLabDiffractionGratingReferenceLabel,
              unit: l10n.physicsLabMichelsonNanometerUnit,
              onChanged: (String value) {
                _viewModel.updateReferenceWavelengthText(groupIndex, value);
              },
            ),
            const SizedBox(height: 8),
            for (int rowIndex = 0;
                rowIndex < DiffractionGratingViewModel.wavelengthRowCount;
                rowIndex += 1)
              Padding(
                padding: EdgeInsets.only(
                  bottom: rowIndex + 1 ==
                          DiffractionGratingViewModel.wavelengthRowCount
                      ? 0
                      : 8,
                ),
                child: _MeasurementRowCard(
                  title: l10n.physicsLabDiffractionGratingWavelengthRowTitle(
                    DiffractionGratingViewModel.wavelengthOrders[rowIndex],
                  ),
                  controllers: _groupControllers[groupIndex][rowIndex],
                  labels: _readingLabelTexes(),
                  onChanged: (int readingIndex, String value) {
                    _viewModel.updateWavelengthReading(
                      groupIndex,
                      rowIndex,
                      readingIndex,
                      value,
                    );
                  },
                  result: rowResults[rowIndex] == null
                      ? null
                      : _buildWavelengthRowCardResult(
                          l10n: l10n,
                          rowResult: rowResults[rowIndex]!,
                        ),
                ),
              ),
            const Divider(height: 20),
            if (!calibrationReady)
              Text(
                l10n.physicsLabDiffractionGratingNeedCalibrationHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else if (result == null)
              Text(
                l10n.physicsLabDiffractionGratingWavelengthIncompleteHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              Column(
                children: [
                  _ResultRow(
                    label: Text(
                      l10n.physicsLabDiffractionGratingAverageWavelengthLabel,
                    ),
                    value:
                        '${_formatNanometer(result.averageWavelengthNm)} ${l10n.physicsLabMichelsonNanometerUnit}',
                  ),
                  const SizedBox(height: 6),
                  _ResultRow(
                    label: Text(l10n.physicsLabMichelsonRelativeErrorLabel),
                    value: '${_formatPercent(result.relativeErrorPercent)}%',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<String> _readingLabelTexes() {
    return const <String>[
      r'\psi_1',
      r"\psi_1^{\prime}",
      r'\psi_2',
      r"\psi_2^{\prime}",
    ];
  }

  void _syncControllersFromViewModel() {
    _calibrationReferenceController.text =
        _viewModel.calibrationReferenceText;
    for (int rowIndex = 0;
        rowIndex < DiffractionGratingViewModel.calibrationRowCount;
        rowIndex += 1) {
      for (int readingIndex = 0;
          readingIndex < DiffractionGratingViewModel.readingCountPerRow;
          readingIndex += 1) {
        _calibrationControllers[rowIndex][readingIndex].setCombinedText(
          _viewModel.calibrationTexts[rowIndex][readingIndex],
        );
      }
    }
    for (int groupIndex = 0;
        groupIndex < DiffractionGratingViewModel.wavelengthGroupCount;
        groupIndex += 1) {
      _groupReferenceControllers[groupIndex].text =
          _viewModel.referenceWavelengthTexts[groupIndex];
      for (int rowIndex = 0;
          rowIndex < DiffractionGratingViewModel.wavelengthRowCount;
          rowIndex += 1) {
        for (int readingIndex = 0;
            readingIndex < DiffractionGratingViewModel.readingCountPerRow;
            readingIndex += 1) {
          _groupControllers[groupIndex][rowIndex][readingIndex]
              .setCombinedText(
            _viewModel.wavelengthTexts[groupIndex][rowIndex][readingIndex],
          );
        }
      }
    }
  }

  void _clearAllInputs() {
    _calibrationReferenceController.clear();
    for (final List<_AngleFieldControllers> row in _calibrationControllers) {
      for (final _AngleFieldControllers controllers in row) {
        controllers.clear();
      }
    }
    for (final TextEditingController controller in _groupReferenceControllers) {
      controller.clear();
    }
    for (final List<List<_AngleFieldControllers>> group in _groupControllers) {
      for (final List<_AngleFieldControllers> row in group) {
        for (final _AngleFieldControllers controllers in row) {
          controllers.clear();
        }
      }
    }
    _viewModel.clearAll();
  }

  void _applyDefaultPreset() {
    _viewModel.applyDefaultPreset();
    _calibrationReferenceController.text = _viewModel.calibrationReferenceText;
    for (int rowIndex = 0;
        rowIndex < DiffractionGratingViewModel.calibrationRowCount;
        rowIndex += 1) {
      for (int readingIndex = 0;
          readingIndex < DiffractionGratingViewModel.readingCountPerRow;
          readingIndex += 1) {
        _calibrationControllers[rowIndex][readingIndex].setCombinedText(
          _viewModel.calibrationTexts[rowIndex][readingIndex],
        );
      }
    }
    for (int groupIndex = 0;
        groupIndex < DiffractionGratingViewModel.wavelengthGroupCount;
        groupIndex += 1) {
      _groupReferenceControllers[groupIndex].text =
          _viewModel.referenceWavelengthTexts[groupIndex];
      for (int rowIndex = 0;
          rowIndex < DiffractionGratingViewModel.wavelengthRowCount;
          rowIndex += 1) {
        for (int readingIndex = 0;
            readingIndex < DiffractionGratingViewModel.readingCountPerRow;
            readingIndex += 1) {
          _groupControllers[groupIndex][rowIndex][readingIndex].setCombinedText(
            _viewModel.wavelengthTexts[groupIndex][rowIndex][readingIndex],
          );
        }
      }
    }
  }

  _MeasurementRowCardResult _buildCalibrationRowCardResult({
    required AppLocalizations l10n,
    required DiffractionGratingCalibrationRowResult rowResult,
  }) {
    return _MeasurementRowCardResult(
      firstDifferenceDegrees: rowResult.measurement.firstDifferenceDegrees,
      secondDifferenceDegrees: rowResult.measurement.secondDifferenceDegrees,
      gammaDegrees: rowResult.measurement.gammaDegrees,
      sinGamma: rowResult.measurement.sinGamma,
      primaryFormulaTex: 'd',
      primaryValueText:
          '${_formatMillimeter(rowResult.gratingConstantMm)} ${l10n.physicsLabMichelsonMillimeterUnit}',
    );
  }

  _MeasurementRowCardResult _buildWavelengthRowCardResult({
    required AppLocalizations l10n,
    required DiffractionGratingWavelengthRowResult rowResult,
  }) {
    return _MeasurementRowCardResult(
      firstDifferenceDegrees: rowResult.measurement.firstDifferenceDegrees,
      secondDifferenceDegrees: rowResult.measurement.secondDifferenceDegrees,
      gammaDegrees: rowResult.measurement.gammaDegrees,
      sinGamma: rowResult.measurement.sinGamma,
      primaryFormulaTex: r'\lambda',
      primaryValueText:
          '${_formatNanometer(rowResult.wavelengthNm)} ${l10n.physicsLabMichelsonNanometerUnit}',
      secondaryLabelText: l10n.physicsLabMichelsonRelativeErrorLabel,
      secondaryValueText: '${_formatPercent(rowResult.relativeErrorPercent)}%',
    );
  }

  String _formatMillimeter(double value) {
    return value.toStringAsFixed(6);
  }

  String _formatNanometer(double value) {
    return value.toStringAsFixed(2);
  }

  String _formatPercent(double value) {
    return value.toStringAsFixed(2);
  }
}
