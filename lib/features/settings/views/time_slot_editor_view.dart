import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/settings_validation.dart' as settings_validation;
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/time_slot.dart';

class TimeSlotEditorView extends StatefulWidget {
  const TimeSlotEditorView({
    required this.initialTimeSlotRanges,
    super.key,
  });

  final List<TimePeriodRangeData> initialTimeSlotRanges;

  @override
  State<TimeSlotEditorView> createState() => _TimeSlotEditorViewState();
}

class _TimeSlotEditorViewState extends State<TimeSlotEditorView> {
  late List<TimePeriodRangeData> _draftTimeSlotRanges;
  bool _allowPop = false;
  _ValidationIssue? _lastValidationIssue;

  @override
  void initState() {
    super.initState();
    _draftTimeSlotRanges = _cloneRanges(widget.initialTimeSlotRanges);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AppLocalizations l10n = AppLocalizations.of(context);
    _lastValidationIssue = _validationIssueFor(_draftTimeSlotRanges, l10n);
  }

  /// 深度复制时间槽
  List<TimePeriodRangeData> _cloneRanges(List<TimePeriodRangeData> source) {
    return source
        .map(
          (item) => TimePeriodRangeData(
            startMinutes: item.startMinutes,
            endMinutes: item.endMinutes,
          ),
        )
        .toList(growable: false);
  }

  /// 验证目前的草稿时间槽是否有效
  ///
  /// 返回错误信息和错误对应的索引
  _ValidationIssue? _validationIssue(AppLocalizations l10n) {
    return _validationIssueFor(_draftTimeSlotRanges, l10n);
  }

  _ValidationIssue? _validationIssueFor(
    List<TimePeriodRangeData> ranges,
    AppLocalizations l10n,
  ) {
    if (ranges.isEmpty) {
      return _ValidationIssue(
        message: l10n.settingsTimeSlotsInvalidEmpty,
        invalidIndices: const <int>{},
      );
    }

    final Set<int> invalidIndices = <int>{};
    String? firstMessage;

    for (int i = 0; i < ranges.length; i += 1) {
      final TimePeriodRangeData current = ranges[i];
      final int start = current.startMinutes;
      final int end = current.endMinutes;

      if (start >= end) {
        invalidIndices.add(i);
        firstMessage ??= l10n.settingsTimeSlotsInvalidRange;
      }

      if (i > 0) {
        final TimePeriodRangeData previous = ranges[i - 1];

        if (previous.startMinutes >= start) {
          invalidIndices.add(i - 1);
          invalidIndices.add(i);
          firstMessage ??= l10n.settingsTimeSlotsInvalidOrder;
        }

        if (previous.endMinutes > start) {
          invalidIndices.add(i - 1);
          invalidIndices.add(i);
          firstMessage ??= l10n.settingsTimeSlotsInvalidOverlap;
        }
      }
    }

    if (invalidIndices.isEmpty) {
      return null;
    }

    return _ValidationIssue(
      message: firstMessage ?? l10n.settingsTimeSlotsInvalidOrder,
      invalidIndices: invalidIndices,
    );
  }

  List<TimePeriodRangeData>? _buildResultOrNull(AppLocalizations l10n) {
    final _ValidationIssue? issue = _validationIssue(l10n);
    if (issue != null) {
      setState(() {
        _lastValidationIssue = issue;
      });
      return null;
    }
    return _cloneRanges(_draftTimeSlotRanges);
  }

  void _popWithDraftResult() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<TimePeriodRangeData>? result = _buildResultOrNull(l10n);
    if (result == null) {
      return;
    }
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

  Future<void> _pickTime({
    required int index,
    required bool isStart,
  }) async {
    final TimePeriodRangeData currentRange = _draftTimeSlotRanges[index];
    final int currentMinutes =
        (isStart ? currentRange.startMinutes : currentRange.endMinutes)
            .clamp(0, settings_validation.kDayLastMinute);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (picked == null || !mounted) {
      return;
    }

    final int nextMinutes = picked.hour * 60 + picked.minute;
    final AppLocalizations l10n = AppLocalizations.of(context);

    late final List<TimePeriodRangeData> nextRanges;
    setState(() {
      nextRanges = List<TimePeriodRangeData>.generate(
        _draftTimeSlotRanges.length,
        (int itemIndex) {
          final TimePeriodRangeData item = _draftTimeSlotRanges[itemIndex];
          if (itemIndex != index) {
            return item;
          }
          return TimePeriodRangeData(
            startMinutes: isStart ? nextMinutes : item.startMinutes,
            endMinutes: isStart ? item.endMinutes : nextMinutes,
          );
        },
        growable: false,
      );
      _draftTimeSlotRanges = nextRanges;
      _lastValidationIssue = _validationIssueFor(nextRanges, l10n);
    });
  }

  void _restoreDefaults() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() {
      _draftTimeSlotRanges = _cloneRanges(kDefaultTimeSlotRanges);
      _lastValidationIssue = _validationIssueFor(_draftTimeSlotRanges, l10n);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final _ValidationIssue? issue = _lastValidationIssue;

    return PopScope<List<TimePeriodRangeData>?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (
        bool didPop,
        List<TimePeriodRangeData>? result,
      ) {
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
            if (issue != null) ...[
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
                        issue.message,
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
            for (int i = 0; i < _draftTimeSlotRanges.length; i += 1) ...[
              Card(
                elevation: 0,
                color: issue?.invalidIndices.contains(i) == true
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('S${i + 1}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickTime(
                                index: i,
                                isStart: true,
                              ),
                              icon: const Icon(Icons.login),
                              label: Text(
                                '${l10n.settingsTimeSlotsStartLabel}: '
                                '${TimeSlot.formatMinutes(_draftTimeSlotRanges[i].startMinutes)}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickTime(
                                index: i,
                                isStart: false,
                              ),
                              icon: const Icon(Icons.logout),
                              label: Text(
                                '${l10n.settingsTimeSlotsEndLabel}: '
                                '${TimeSlot.formatMinutes(_draftTimeSlotRanges[i].endMinutes)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

class _ValidationIssue {
  const _ValidationIssue({
    required this.message,
    required this.invalidIndices,
  });

  final String message;
  final Set<int> invalidIndices;
}
