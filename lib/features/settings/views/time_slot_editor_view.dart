import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/settings/models/settings_model.dart';
import 'package:onetj/models/time_slot.dart';

class TimeSlotEditorView extends StatefulWidget {
  const TimeSlotEditorView({
    required this.initialTimeSlotStartMinutes,
    super.key,
  });

  final List<int> initialTimeSlotStartMinutes;

  @override
  State<TimeSlotEditorView> createState() => _TimeSlotEditorViewState();
}

class _TimeSlotEditorViewState extends State<TimeSlotEditorView> {
  late List<int> _draftTimeSlots;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    _draftTimeSlots = List<int>.from(widget.initialTimeSlotStartMinutes);
  }

  String? _validationMessage(AppLocalizations l10n) {
    try {
      SettingsModel.validateTimeSlotStartMinutes(_draftTimeSlots);
      return null;
    } catch (_) {
      return l10n.settingsTimeSlotsInvalidOrder;
    }
  }

  bool _isDraftValid() {
    try {
      SettingsModel.validateTimeSlotStartMinutes(_draftTimeSlots);
      return true;
    } catch (_) {
      return false;
    }
  }

  List<int>? _buildResultOrNull() {
    if (!_isDraftValid()) {
      return null;
    }
    return List<int>.from(_draftTimeSlots);
  }

  void _popWithDraftResult() {
    final List<int>? result = _buildResultOrNull();
    if (_allowPop) {
      Navigator.of(context).pop(result);
      return;
    }
    setState(() {
      _allowPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(result);
    });
  }

  Future<void> _pickTime(int index) async {
    final int current = _draftTimeSlots[index];
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: current ~/ 60,
        minute: current % 60,
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _draftTimeSlots[index] = picked.hour * 60 + picked.minute;
    });
  }

  void _restoreDefaults() {
    setState(() {
      _draftTimeSlots = List<int>.from(TimeSlot.defaultStartMinutes);
    });
  }


  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? errorText = _validationMessage(l10n);

    return PopScope<List<int>?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (bool didPop, List<int>? result) {
        if (didPop) {
          return;
        }
        _popWithDraftResult();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsTimeSlotsEditorTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.settingsTimeSlotsEditorHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            for (int i = 0; i < _draftTimeSlots.length; i += 1) ...[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text('S${i + 1}'),
                  subtitle: Text(TimeSlot.formatMinutes(_draftTimeSlots[i])),
                  trailing: const Icon(Icons.schedule),
                  onTap: () => _pickTime(i),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _restoreDefaults,
                    child: Text(l10n.settingsTimeSlotsResetToDefault),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
