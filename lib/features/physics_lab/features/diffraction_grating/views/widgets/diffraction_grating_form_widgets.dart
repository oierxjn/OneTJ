part of '../diffraction_grating_view.dart';

class _MeasurementRowCard extends StatelessWidget {
  const _MeasurementRowCard({
    required this.title,
    required this.controllers,
    required this.labels,
    required this.onChanged,
    required this.result,
    this.showPrimaryBadge = true,
  });

  final String title;
  final List<_AngleFieldControllers> controllers;
  final List<String> labels;
  final void Function(int readingIndex, String value) onChanged;
  final _MeasurementRowCardResult? result;
  final bool showPrimaryBadge;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controllers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 60,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _AngleInputField(
                controllers: controllers[index],
                labelTex: labels[index],
                onChanged: (String value) => onChanged(index, value),
              );
            },
          ),
          if (result != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (showPrimaryBadge)
                  _SummaryBadge(
                    label: PhysicsLabFormula.inline(
                      tex: result!.primaryFormulaTex,
                    ),
                    value: result!.primaryValueText,
                  ),
                if (result!.secondaryLabelText != null &&
                    result!.secondaryValueText != null)
                  _SummaryBadge(
                    label: Text(result!.secondaryLabelText!),
                    value: result!.secondaryValueText!,
                  ),
                _SummaryBadge(
                  label: Text(
                    l10n.physicsLabDiffractionGratingDifferenceOneLabel,
                  ),
                  value: _formatDegreeText(
                    result!.firstDifferenceDegrees,
                  ),
                ),
                _SummaryBadge(
                  label: Text(
                    l10n.physicsLabDiffractionGratingDifferenceTwoLabel,
                  ),
                  value: _formatDegreeText(
                    result!.secondDifferenceDegrees,
                  ),
                ),
                _SummaryBadge(
                  label: Text(l10n.physicsLabDiffractionGratingGammaLabel),
                  value: _formatDegreeText(result!.gammaDegrees),
                ),
                _SummaryBadge(
                  label: Text(l10n.physicsLabDiffractionGratingSinGammaLabel),
                  value: result!.sinGamma.toStringAsFixed(4),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MeasurementRowCardResult {
  const _MeasurementRowCardResult({
    required this.firstDifferenceDegrees,
    required this.secondDifferenceDegrees,
    required this.gammaDegrees,
    required this.sinGamma,
    required this.primaryFormulaTex,
    required this.primaryValueText,
    this.secondaryLabelText,
    this.secondaryValueText,
  });

  final double firstDifferenceDegrees;
  final double secondDifferenceDegrees;
  final double gammaDegrees;
  final double sinGamma;
  final String primaryFormulaTex;
  final String primaryValueText;
  final String? secondaryLabelText;
  final String? secondaryValueText;
}

class _AngleFieldControllers {
  _AngleFieldControllers({
    required String degreeText,
    required String minuteText,
  })  : degreeController = TextEditingController(text: degreeText),
        minuteController = TextEditingController(text: minuteText);

  factory _AngleFieldControllers.fromCombinedText(String text) {
    final List<String> parts = _splitAngleParts(text);
    return _AngleFieldControllers(
      degreeText: parts[0],
      minuteText: parts[1],
    );
  }

  final TextEditingController degreeController;
  final TextEditingController minuteController;

  String get combinedText {
    final String degree = degreeController.text.trim();
    final String minute = minuteController.text.trim();
    if (degree.isEmpty || minute.isEmpty) {
      return '';
    }
    return '$degree $minute';
  }

  void setCombinedText(String text) {
    final List<String> parts = _splitAngleParts(text);
    degreeController.text = parts[0];
    minuteController.text = parts[1];
  }

  void clear() {
    degreeController.clear();
    minuteController.clear();
  }

  void dispose() {
    degreeController.dispose();
    minuteController.dispose();
  }
}

List<String> _splitAngleParts(String text) {
  final String normalized = text
      .trim()
      .replaceAll(_degreeSymbol, ' ')
      .replaceAll("'", ' ')
      .replaceAll('"', ' ')
      .replaceAll('′', ' ')
      .replaceAll('″', ' ')
      .replaceAll(':', ' ')
      .replaceAll('：', ' ');
  final List<String> parts = normalized
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return const <String>['', ''];
  }
  if (parts.length == 1) {
    return <String>[parts[0], ''];
  }
  return <String>[parts[0], parts[1]];
}

String _formatDegreeText(double value) {
  return DiffractionGratingAngle.formatDegrees(
    value,
    degreeSymbol: _degreeSymbol,
  );
}

class _AngleInputField extends StatefulWidget {
  const _AngleInputField({
    required this.controllers,
    required this.labelTex,
    required this.onChanged,
  });

  final _AngleFieldControllers controllers;
  final String labelTex;
  final ValueChanged<String> onChanged;

  @override
  State<_AngleInputField> createState() => _AngleInputFieldState();
}

class _AngleInputFieldState extends State<_AngleInputField> {
  late final FocusNode _degreeFocusNode;
  late final FocusNode _minuteFocusNode;

  @override
  void initState() {
    super.initState();
    _degreeFocusNode = FocusNode()..addListener(_handleFocusChanged);
    _minuteFocusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _degreeFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _minuteFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isFocused =
        _degreeFocusNode.hasFocus || _minuteFocusNode.hasFocus;
    final bool isEmpty =
        widget.controllers.degreeController.text.trim().isEmpty &&
            widget.controllers.minuteController.text.trim().isEmpty;
    return InputDecorator(
      isFocused: isFocused,
      isEmpty: isEmpty,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isDense: true,
        label: PhysicsLabFormula.inline(
          tex: widget.labelTex,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AnglePartField(
              controller: widget.controllers.degreeController,
              focusNode: _degreeFocusNode,
              hintText: l10n.physicsLabDiffractionGratingDegreeHint,
              onChanged: (_) =>
                  widget.onChanged(widget.controllers.combinedText),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _degreeSymbol,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _AnglePartField(
              controller: widget.controllers.minuteController,
              focusNode: _minuteFocusNode,
              hintText: l10n.physicsLabDiffractionGratingMinuteHint,
              onChanged: (_) =>
                  widget.onChanged(widget.controllers.combinedText),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '\'',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AnglePartField extends StatelessWidget {
  const _AnglePartField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      ),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      onChanged: onChanged,
    );
  }
}

class _NumericTextField extends StatelessWidget {
  const _NumericTextField({
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
        signed: false,
      ),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
      ],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isDense: true,
        labelText: label,
        suffixText: unit,
      ),
      onChanged: onChanged,
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({
    required this.label,
    required this.value,
  });

  final Widget label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.labelMedium,
            child: label,
          ),
          const SizedBox(height: 1),
          Text(value),
        ],
      ),
    );
  }
}

class _ReadOnlySummaryTile extends StatelessWidget {
  const _ReadOnlySummaryTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
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
        padding: const EdgeInsets.all(12),
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
        Expanded(child: label),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
