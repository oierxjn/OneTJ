import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/models/bohr_twist_pendulum_result.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/view_models/bohr_twist_pendulum_view_model.dart';
import 'package:onetj/features/physics_lab/widgets/physics_lab_formula.dart';

class BohrTwistPendulumView extends StatefulWidget {
  const BohrTwistPendulumView({required this.viewModel, super.key});

  final BohrTwistPendulumViewModel viewModel;

  @override
  State<BohrTwistPendulumView> createState() => _BohrTwistPendulumViewState();
}

class _BohrTwistPendulumViewState extends State<BohrTwistPendulumView> {
  late final BohrTwistPendulumViewModel _viewModel;
  late final TextEditingController _periodController;
  late final TextEditingController _periodTableController;
  late final TextEditingController _amplitudeTableController;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    _periodController = TextEditingController(text: _viewModel.periodText);
    _periodTableController =
        TextEditingController(text: _viewModel.periodTableText);
    _amplitudeTableController =
        TextEditingController(text: _viewModel.amplitudeTableText);
    _viewModel.load().then((_) {
      if (mounted) {
        _syncControllersFromViewModel();
      }
    });
  }

  @override
  void dispose() {
    _periodController.dispose();
    _periodTableController.dispose();
    _amplitudeTableController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (BuildContext context, _) {
        final BohrTwistPendulumResult result = _viewModel.result;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.physicsLabBohrTwistPendulumTitle),
            actions: [
              IconButton(
                tooltip: l10n.physicsLabBohrTwistPendulumPresetFillLabel,
                onPressed: _applyDefaultPreset,
                icon: const Icon(Icons.playlist_add_outlined),
              ),
              IconButton(
                tooltip: l10n.physicsLabBohrTwistPendulumClearAllLabel,
                onPressed: _clearAllInputs,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(6),
            children: [
              _InfoCard(
                title: l10n.physicsLabBohrTwistPendulumFormulaTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.physicsLabBohrTwistPendulumDescription),
                    const SizedBox(height: 12),
                    Text(l10n.physicsLabBohrTwistPendulumFormulaBody),
                    const SizedBox(height: 12),
                    const PhysicsLabFormula.block(
                      tex: r'\beta=\frac{\ln\theta_n-\ln\theta_{n+5}}{5T}',
                    ),
                    const SizedBox(height: 8),
                    const PhysicsLabFormula.block(
                      tex: r'\beta=-\frac{k}{T}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildFreeVibrationCard(l10n),
              const SizedBox(height: 8),
              _buildDampedVibrationCard(l10n),
              const SizedBox(height: 8),
              _buildResultCard(l10n, result),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreeVibrationCard(AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.physicsLabBohrTwistPendulumFreeVibrationTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NumberField(
            controller: _periodController,
            label: Text(l10n.physicsLabBohrTwistPendulumPeriodLabel),
            unit: l10n.physicsLabBohrTwistPendulumPeriodUnit,
            onChanged: _viewModel.updatePeriodText,
          ),
          const SizedBox(height: 12),
          _TableField(
            controller: _periodTableController,
            label: l10n.physicsLabBohrTwistPendulumPeriodTableLabel,
            hint: l10n.physicsLabBohrTwistPendulumPeriodTableHint,
            onChanged: _viewModel.updatePeriodTableText,
          ),
        ],
      ),
    );
  }

  Widget _buildDampedVibrationCard(AppLocalizations l10n) {
    return _SectionCard(
      title: l10n.physicsLabBohrTwistPendulumDampedVibrationTitle,
      child: _TableField(
        controller: _amplitudeTableController,
        label: l10n.physicsLabBohrTwistPendulumAmplitudeTableLabel,
        hint: l10n.physicsLabBohrTwistPendulumAmplitudeTableHint,
        onChanged: _viewModel.updateAmplitudeTableText,
      ),
    );
  }

  Widget _buildResultCard(
    AppLocalizations l10n,
    BohrTwistPendulumResult result,
  ) {
    return _SectionCard(
      title: l10n.physicsLabBohrTwistPendulumResultTitle,
      child: result.hasCompleteResult
          ? Column(
              children: [
                _ResultRow(
                  label:
                      Text(l10n.physicsLabBohrTwistPendulumAveragePeriodLabel),
                  value:
                      '${_formatPeriod(result.averagePeriod!)} ${l10n.physicsLabBohrTwistPendulumPeriodUnit}',
                ),
                const SizedBox(height: 8),
                _ResultRow(
                  label: Text(l10n.physicsLabBohrTwistPendulumLogMethodLabel),
                  value:
                      '${_formatDamping(result.logMethodBeta!)} ${l10n.physicsLabBohrTwistPendulumDampingUnit}',
                ),
                const SizedBox(height: 8),
                _ResultRow(
                  label: Text(l10n.physicsLabBohrTwistPendulumGraphMethodLabel),
                  value:
                      '${_formatDamping(result.graphicalBeta!)} ${l10n.physicsLabBohrTwistPendulumDampingUnit}',
                ),
              ],
            )
          : Text(
              l10n.physicsLabBohrTwistPendulumIncompleteHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
    );
  }

  void _syncControllersFromViewModel() {
    _syncControllerText(_periodController, _viewModel.periodText);
    _syncControllerText(_periodTableController, _viewModel.periodTableText);
    _syncControllerText(
      _amplitudeTableController,
      _viewModel.amplitudeTableText,
    );
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

  void _applyDefaultPreset() {
    _viewModel.applyDefaultPreset();
    _syncControllersFromViewModel();
  }

  void _clearAllInputs() {
    _periodController.clear();
    _periodTableController.clear();
    _amplitudeTableController.clear();
    _viewModel.clearAll();
  }

  String _formatPeriod(double value) {
    return value.toStringAsFixed(4);
  }

  String _formatDamping(double value) {
    return value.toStringAsFixed(6);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Widget label;
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
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.\-]')),
      ],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isDense: true,
        label: label,
        suffixText: unit,
      ),
      onChanged: onChanged,
    );
  }
}

class _TableField extends StatelessWidget {
  const _TableField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 6,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
        labelText: label,
        helperText: hint,
        helperMaxLines: 2,
      ),
      onChanged: onChanged,
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
