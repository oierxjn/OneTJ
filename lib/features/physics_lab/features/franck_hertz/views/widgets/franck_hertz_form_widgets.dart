part of '../franck_hertz_view.dart';

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _MeasurementHeaderRow extends StatelessWidget {
  const _MeasurementHeaderRow({
    required this.rowLabel,
    required this.actionLabel,
  });

  final String rowLabel;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              rowLabel,
              style: style,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle.merge(
              style: style,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: PhysicsLabFormula.inline(tex: r'V_{G2K}'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle.merge(
              style: style,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: PhysicsLabFormula.inline(tex: r'I_P'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            child: Text(
              actionLabel,
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementInputRow extends StatelessWidget {
  const _MeasurementInputRow({
    required this.indexText,
    required this.vg2kController,
    required this.ipController,
    required this.voltHintText,
    required this.currentHintText,
    required this.deleteTooltip,
    required this.canDelete,
    required this.onVg2kChanged,
    required this.onIpChanged,
    required this.onDelete,
  });

  final String indexText;
  final TextEditingController vg2kController;
  final TextEditingController ipController;
  final String voltHintText;
  final String currentHintText;
  final String deleteTooltip;
  final bool canDelete;
  final ValueChanged<String> onVg2kChanged;
  final ValueChanged<String> onIpChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              indexText,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CompactNumberField(
              controller: vg2kController,
              hintText: voltHintText,
              onChanged: onVg2kChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CompactNumberField(
              controller: ipController,
              hintText: currentHintText,
              onChanged: onIpChanged,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            child: IconButton(
              tooltip: deleteTooltip,
              onPressed: canDelete ? onDelete : null,
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodResultCard extends StatelessWidget {
  const _MethodResultCard({
    required this.title,
    required this.featureCountLabel,
    required this.intervalLabel,
    required this.featureUnit,
    required this.result,
    required this.emptyHint,
  });

  final String title;
  final String featureCountLabel;
  final String intervalLabel;
  final String featureUnit;
  final FranckHertzMethodResult? result;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: result == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emptyHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ResultBadge(
                        label: featureCountLabel,
                        value: result!.featurePoints.length.toString(),
                      ),
                      _ResultBadge(
                        label: intervalLabel,
                        value:
                            '${_formatVoltage(result!.averageInterval)} $featureUnit',
                      ),
                      _ResultBadge(
                        label: 'ΔV',
                        value: result!.intervals
                            .map((double value) => _formatVoltage(value))
                            .join(', '),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _FinalResultCard extends StatelessWidget {
  const _FinalResultCard({
    required this.finalResultLabel,
    required this.referenceLabel,
    required this.relativeErrorLabel,
    required this.voltageUnit,
    required this.result,
    required this.emptyHint,
  });

  final String finalResultLabel;
  final String referenceLabel;
  final String relativeErrorLabel;
  final String voltageUnit;
  final FranckHertzAnalysisResult result;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    final bool hasCompleteResult = result.hasCompleteResult;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: hasCompleteResult
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    finalResultLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ResultBadge(
                        label: finalResultLabel,
                        value:
                            '${_formatVoltage(result.finalExcitationPotential!)} $voltageUnit',
                      ),
                      if (result.referenceVoltage != null)
                        _ResultBadge(
                          label: referenceLabel,
                          value:
                              '${_formatVoltage(result.referenceVoltage!)} $voltageUnit',
                        ),
                      if (result.relativeErrorPercent != null)
                        _ResultBadge(
                          label: relativeErrorLabel,
                          value:
                              '${result.relativeErrorPercent!.toStringAsFixed(2)}%',
                        ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    finalResultLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emptyHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(value),
        ],
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

String _formatVoltage(double value) {
  return value.toStringAsFixed(2);
}

class _CompactNumberField extends StatelessWidget {
  const _CompactNumberField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
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
        hintText: hintText,
      ),
      onChanged: onChanged,
    );
  }
}
