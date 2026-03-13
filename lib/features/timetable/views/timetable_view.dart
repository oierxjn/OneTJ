import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:onetj/app/logging/logger.dart';

import 'package:onetj/features/timetable/view_models/timetable_view_model.dart';
import 'package:onetj/features/timetable/views/widgets/timetable_timeline_panel.dart';
import 'package:onetj/features/timetable/models/event.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/widgets/course_detail_bottom_sheet.dart';

class TimetableView extends StatefulWidget {
  const TimetableView({super.key});

  @override
  State<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<TimetableView> {
  late final TimetableViewModel _viewModel;
  late final FixedExtentScrollController _dayController;
  late final FixedExtentScrollController _weekController;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = TimetableViewModel();
    _dayController = FixedExtentScrollController(
      initialItem: _viewModel.selectedDay - 1,
    );
    _weekController = FixedExtentScrollController();
    _eventSub = _viewModel.events.listen((event) {
      if (event is ShowSnackBarEvent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
        return;
      }
      if (event is SyncWheelEvent) {
        _syncWheelControllers();
      }
    });
    _viewModel.load();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _dayController.dispose();
    _weekController.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _formatRoom(TimetableEntry entry) {
    return entry.roomIdI18n.isNotEmpty ? entry.roomIdI18n : entry.roomLabel;
  }

  String _formatTeacher(TimetableEntry entry) {
    return entry.teacherName;
  }

  String _formatLastFetchTime(DateTime value) {
    final String year = value.year.toString().padLeft(4, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  Widget _buildLastFetchFooter(BuildContext context, AppLocalizations l10n) {
    final DateTime? lastFetchedAt = _viewModel.lastFetchedAt;
    final String timeText = lastFetchedAt == null
        ? l10n.timetableLastFetchUnknown
        : _formatLastFetchTime(lastFetchedAt);
    final TextStyle? style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Text(
          l10n.timetableLastFetch(timeText),
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
    );
  }

  Future<void> _showCourseDetails(
    TimetableEntry entry,
    TimetableIndex index,
  ) async {
    await showCourseDetailBottomSheet(
      context: context,
      entry: entry,
      index: index,
      timeSlotRanges: _viewModel.timeSlotRanges,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabTimetable),
        actions: [
          AnimatedBuilder(
            animation: _viewModel,
            builder: (context, _) => IconButton(
              icon: const Icon(Icons.location_searching),
              onPressed: _viewModel.isLoading ? null : _viewModel.jumpToToday,
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) => _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    const Duration defaultDuration = Duration(milliseconds: 220);
    final Duration animationDuration =
        disableAnimations ? Duration.zero : defaultDuration;
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.error != null) {
      return Center(
        child: Text(
          l10n.timetableLoadFailed(_viewModel.error.toString()),
        ),
      );
    }
    final TimetableIndex? index = _viewModel.index;
    if (index == null || index.allEntries.isEmpty) {
      return Center(child: Text(l10n.timetableNoData));
    }

    final List<String> dayLabels = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<TimetableDisplayMode>(
            segments: [
              ButtonSegment(
                value: TimetableDisplayMode.day,
                label: Text(l10n.timetableDayView),
              ),
              ButtonSegment(
                value: TimetableDisplayMode.week,
                label: Text(l10n.timetableWeekView),
              ),
            ],
            selected: {_viewModel.mode},
            onSelectionChanged: (selection) {
              _viewModel.setMode(selection.first);
            },
          ),
        ),
        if (_viewModel.availableWeeks.isNotEmpty)
          SizedBox(
            height: 40,
            child: _HorizontalWheel(
              controller: _weekController,
              itemExtent: 90,
              itemCount: _viewModel.availableWeeks.length,
              onSelectedItemChanged: (index) {
                if (index < 0 || index >= _viewModel.availableWeeks.length) {
                  return;
                }
                _viewModel.selectWeek(_viewModel.availableWeeks[index]);
              },
              itemBuilder: (context, index) {
                final int week = _viewModel.availableWeeks[index];
                final bool selected = _viewModel.selectedWeek == week;
                return _WheelItem(
                  label: l10n.weekLabel(week),
                  selected: selected,
                );
              },
            ),
          ),
        _buildAnimatedDayWheel(
          dayLabels: dayLabels,
          duration: animationDuration,
        ),
        Expanded(
          child: TimetableTimelinePanel(
            mode: _viewModel.mode,
            dayLabels: dayLabels,
            timeSlotRanges: _viewModel.timeSlotRanges,
            selectedDay: _viewModel.selectedDay,
            duration: animationDuration,
            disableAnimations: disableAnimations,
            scrollController: _scrollController,
            roomBuilder: _formatRoom,
            teacherBuilder: _formatTeacher,
            entriesForDay: _viewModel.entriesForSelectedWeekDay,
            onCourseTap: (entry) {
              unawaited(_showCourseDetails(entry, index));
            },
          ),
        ),
        _buildLastFetchFooter(context, l10n),
      ],
    );
  }

  /// 同步周数和天数的滚动控制器
  ///
  /// 不推荐在 Build 过程中调用
  void _syncWheelControllers() {
    final int dayIndex = (_viewModel.selectedDay - 1).clamp(0, 6);
    _syncWheelController(_dayController, dayIndex);
    if (_viewModel.availableWeeks.isEmpty) {
      return;
    }
    final int weekIndex = _viewModel.availableWeeks.indexOf(
      _viewModel.selectedWeek ?? _viewModel.availableWeeks.first,
    );
    final int targetIndex = weekIndex < 0 ? 0 : weekIndex;
    _syncWheelController(_weekController, targetIndex);
  }

  void _syncWheelController(
    FixedExtentScrollController controller,
    int targetIndex,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        if (controller.selectedItem != targetIndex) {
          controller.jumpToItem(targetIndex);
        }
        return;
      }
      AppLogger.error("Failed to sync wheel controllers", loggerName: "TimetableView");
    });
  }

  Widget _buildAnimatedDayWheel({
    required List<String> dayLabels,
    required Duration duration,
  }) {
    return _AnimatedDayWheel(
      isExpanded: _viewModel.mode == TimetableDisplayMode.day,
      duration: duration,
      child: SizedBox(
        height: 40,
        child: _HorizontalWheel(
          controller: _dayController,
          itemExtent: 64,
          itemCount: dayLabels.length,
          onSelectedItemChanged: (index) {
            if (index < 0 || index >= dayLabels.length) {
              return;
            }
            _viewModel.selectDay(index + 1);
          },
          itemBuilder: (context, index) {
            final bool selected = _viewModel.selectedDay == index + 1;
            return _WheelItem(
              label: dayLabels[index],
              selected: selected,
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedDayWheel extends StatefulWidget {
  const _AnimatedDayWheel({
    required this.isExpanded,
    required this.duration,
    required this.child,
  });

  final bool isExpanded;
  final Duration duration;
  final Widget child;

  @override
  State<_AnimatedDayWheel> createState() => _AnimatedDayWheelState();
}

class _AnimatedDayWheelState extends State<_AnimatedDayWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.isExpanded ? 1 : 0,
    );
    _sizeFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedDayWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (oldWidget.isExpanded == widget.isExpanded &&
        oldWidget.duration == widget.duration) {
      return;
    }
    if (widget.duration == Duration.zero) {
      _controller.value = widget.isExpanded ? 1 : 0;
      return;
    }
    if (widget.isExpanded) {
      _controller.forward();
      return;
    }
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizeTransition(
        sizeFactor: _sizeFactor,
        axis: Axis.vertical,
        axisAlignment: -1,
        child: IgnorePointer(
          ignoring: !widget.isExpanded,
          child: widget.child,
        ),
      ),
    );
  }
}

class _WheelItem extends StatelessWidget {
  const _WheelItem({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final TextStyle? baseStyle = Theme.of(context).textTheme.bodyMedium;
    final TextStyle? style = selected
        ? baseStyle?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          )
        : baseStyle?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
    return Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: style ?? const TextStyle(),
        child: Text(label),
      ),
    );
  }
}

class _HorizontalWheel extends StatelessWidget {
  const _HorizontalWheel({
    required this.controller,
    required this.itemExtent,
    required this.itemCount,
    required this.onSelectedItemChanged,
    required this.itemBuilder,
  });

  final FixedExtentScrollController controller;
  final double itemExtent;
  final int itemCount;
  final ValueChanged<int> onSelectedItemChanged;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: -1,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: itemExtent,
        perspective: 0.004,
        diameterRatio: 2.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return RotatedBox(
              quarterTurns: 1,
              child: itemBuilder(context, index),
            );
          },
        ),
      ),
    );
  }
}
