import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/physics_lab/features/michelson/models/michelson_measurement_result.dart';
import 'package:onetj/features/physics_lab/features/michelson/view_models/michelson_interferometer_view_model.dart';
import 'package:onetj/features/physics_lab/widgets/physics_lab_formula.dart';

class MichelsonInterferometerView extends StatefulWidget {
  const MichelsonInterferometerView({super.key});

  @override
  State<MichelsonInterferometerView> createState() =>
      _MichelsonInterferometerViewState();
}

class _MichelsonInterferometerViewState
    extends State<MichelsonInterferometerView> {
  late final MichelsonInterferometerViewModel _viewModel;
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _viewModel = MichelsonInterferometerViewModel();
    _controllers = List<TextEditingController>.generate(
      MichelsonInterferometerViewModel.positionCount,
      (_) => TextEditingController(),
      growable: false,
    );
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final MichelsonMeasurementResult? result = _viewModel.result;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.physicsLabMichelsonTitle),
            actions: [
              IconButton(
                tooltip: l10n.physicsLabMichelsonClearAllLabel,
                onPressed: _clearAllInputs,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(6),
            children: [
              _InfoCard(
                title: l10n.physicsLabMichelsonFormulaTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.physicsLabMichelsonFormulaBody),
                    const SizedBox(height: 12),
                    const PhysicsLabFormula.block(
                      tex: r'\Delta d_n = d_{n+5} - d_n',
                    ),
                    const SizedBox(height: 8),
                    const PhysicsLabFormula.block(
                      tex: r'\lambda_n = \frac{\Delta d_n}{75}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildInputCard(l10n),
              const SizedBox(height: 8),
              _buildResultCard(l10n, result),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputCard(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.physicsLabMichelsonInputSectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.physicsLabMichelsonInputHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (int index = 0; index < 5; index += 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PositionInputField(
                            controller: _controllers[index],
                            label: _positionFormula(index + 1),
                            unit: l10n.physicsLabMichelsonMillimeterUnit,
                            onChanged: (value) {
                              _viewModel.updatePositionText(index, value);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (int index = 5; index < _controllers.length; index += 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PositionInputField(
                            controller: _controllers[index],
                            label: _positionFormula(index + 1),
                            unit: l10n.physicsLabMichelsonMillimeterUnit,
                            onChanged: (value) {
                              _viewModel.updatePositionText(index, value);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    AppLocalizations l10n,
    MichelsonMeasurementResult? result,
  ) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: result == null
            ? Text(
                l10n.physicsLabMichelsonIncompleteHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.physicsLabMichelsonResultSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  for (int index = 0;
                      index < result.differencesMm.length;
                      index += 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PhysicsLabFormula.block(
                        tex: _differenceFormula(
                          index,
                          result,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  for (int index = 0;
                      index < result.wavelengthsNm.length;
                      index += 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PhysicsLabFormula.block(
                        tex: _wavelengthFormula(
                          index,
                          result,
                        ),
                      ),
                    ),
                  const Divider(height: 24),
                  _ResultRow(
                    label: const PhysicsLabFormula.inline(
                      tex: r'\text{平均 }\lambda',
                    ),
                    value:
                        '${_formatNanometer(result.averageWavelengthNm)} ${l10n.physicsLabMichelsonNanometerUnit}',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: Text(l10n.physicsLabMichelsonRelativeErrorLabel),
                    value: '${_formatPercent(result.relativeErrorPercent)}%',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.physicsLabMichelsonReferenceHint(
                      '${_formatNanometer(
                        MichelsonInterferometerViewModel.referenceValue,
                      )} ${l10n.physicsLabMichelsonNanometerUnit}',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
      ),
    );
  }

  void _clearAllInputs() {
    for (final TextEditingController controller in _controllers) {
      controller.clear();
    }
    _viewModel.clearAll();
  }

  String _positionFormula(int index) {
    return 'd_{$index}';
  }

  String _differenceFormula(
    int index,
    MichelsonMeasurementResult result,
  ) {
    final int differenceIndex = index + 1;
    final int laterIndex = index + 6;
    final int earlierIndex = index + 1;
    final String laterValue = _formatMillimeter(result.positions[index + 5]);
    final String earlierValue = _formatMillimeter(result.positions[index]);
    final String differenceValue = _formatMillimeter(result.differencesMm[index]);
    return '\\Delta d_{$differenceIndex} = d_{$laterIndex} - d_{$earlierIndex}'
        ' = $laterValue - $earlierValue = $differenceValue\\,\\mathrm{mm}';
  }

  String _wavelengthFormula(
    int index,
    MichelsonMeasurementResult result,
  ) {
    final int wavelengthIndex = index + 1;
    final String differenceValue = _formatMillimeter(result.differencesMm[index]);
    final String wavelengthValue = _formatNanometer(result.wavelengthsNm[index]);
    return '\\lambda_{$wavelengthIndex} = \\frac{\\Delta d_{$wavelengthIndex}}'
        '{${_formatPlainNumber(MichelsonInterferometerViewModel.fringesPerStep)}}'
        ' = $wavelengthValue\\,\\mathrm{nm}\\quad(\\Delta d_{$wavelengthIndex}'
        '=$differenceValue\\,\\mathrm{mm})';
  }

  String _formatPlainNumber(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

  String _formatMillimeter(double value) {
    return value.toStringAsFixed(5);
  }

  String _formatNanometer(double value) {
    return value.toStringAsFixed(2);
  }

  String _formatPercent(double value) {
    return value.toStringAsFixed(2);
  }
}

class _PositionInputField extends StatelessWidget {
  const _PositionInputField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String unit;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[0-9\.\-]'),
        ),
      ],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isDense: true,
        label: PhysicsLabFormula.inline(
          tex: label,
        ),
        suffixText: unit,
      ),
      onChanged: onChanged,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
  });

  final Widget label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: label,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
