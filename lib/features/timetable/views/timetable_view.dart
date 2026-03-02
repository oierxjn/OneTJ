import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/timetable/view_models/timetable_view_model.dart';
import 'package:onetj/features/timetable/views/widgets/timeline_content.dart';
import 'package:onetj/features/timetable/models/event.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/models/time_slot.dart';

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
          child: _buildTimetableView(
            context,
            mode: _viewModel.mode,
            dayLabels: dayLabels,
            duration: animationDuration,
            disableAnimations: disableAnimations,
          ),
        ),
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
      // TODO 日志记录未同步的情况
    });
  }

  double _weekHeaderHeight(BuildContext context) {
    final TextStyle style =
        Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    final String dayLabel = AppLocalizations.of(context).weekdayMon;
    const double padding = 8;
    final TextPainter painter = TextPainter(
      text: TextSpan(text: dayLabel, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.height + padding;
  }

  Widget _buildTimetableView(
    BuildContext context, {
    required TimetableDisplayMode mode,
    required List<String> dayLabels,
    required Duration duration,
    required bool disableAnimations,
  }) {
    const double slotHeight = 64;
    const double preferredLabelWidth = 72;
    const double minLabelWidth = 35;
    final List<_TimeSlot> timeSlots = _buildTimeSlots(_viewModel.timeSlotRanges);
    final double targetHeaderHeight =
        mode == TimetableDisplayMode.week ? _weekHeaderHeight(context) : 0;

    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: mode == TimetableDisplayMode.week
          ? Curves.easeOutCubic
          : Curves.easeInCubic,
      tween: Tween<double>(begin: 0, end: targetHeaderHeight),
      builder: (context, animatedHeaderHeight, _) {
        final double contentHeight =
            timeSlots.length * slotHeight + animatedHeaderHeight;
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 12, 4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth =
                  (constraints.maxWidth - 8).clamp(0, double.infinity);
              final double minCardWidth = 92;
              final double maxCardWidth = double.infinity;
              double labelWidth = preferredLabelWidth;
              double dayColumnWidth =
                  ((availableWidth - labelWidth) / 7).clamp(0, maxCardWidth);

              if (dayColumnWidth < minCardWidth) {
                final double neededLabelWidth = availableWidth - minCardWidth * 7;
                labelWidth =
                    neededLabelWidth.clamp(minLabelWidth, preferredLabelWidth);
                dayColumnWidth =
                    ((availableWidth - labelWidth) / 7).clamp(0, maxCardWidth);
              }
              final bool isNarrowLabel = labelWidth <= minLabelWidth + 0.1;
              final TextStyle? labelStyle = isNarrowLabel
                  ? Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)
                  : Theme.of(context).textTheme.bodySmall;

              return SingleChildScrollView(
                controller: _scrollController,
                child: SizedBox(
                  height: contentHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Column(
                          children: [
                            SizedBox(height: animatedHeaderHeight),
                            for (final slot in timeSlots)
                              Container(
                                height: slotHeight,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  slot.label,
                                  style: labelStyle,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Column(
                                children: [
                                  SizedBox(height: animatedHeaderHeight),
                                  for (int i = 0; i < timeSlots.length; i += 1)
                                    Container(
                                      height: slotHeight,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Positioned.fill(
                              child: AnimatedSwitcher(
                                duration: duration,
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeOut,
                                transitionBuilder: (child, animation) {
                                  if (disableAnimations) {
                                    return child;
                                  }
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                layoutBuilder: (currentChild, previousChildren) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ...previousChildren,
                                      if (currentChild != null) currentChild,
                                    ],
                                  );
                                },
                                child: mode == TimetableDisplayMode.day
                                    ? KeyedSubtree(
                                        key: const ValueKey<String>('day-content'),
                                        child: DayTimelineContent(
                                          entries:
                                              _viewModel.entriesForSelectedWeekDay(
                                            _viewModel.selectedDay,
                                          ),
                                          slotHeight: slotHeight,
                                          slotCount: timeSlots.length,
                                          roomBuilder: _formatRoom,
                                          teacherBuilder: _formatTeacher,
                                        ),
                                      )
                                    : KeyedSubtree(
                                        key: const ValueKey<String>('week-content'),
                                        child: WeekTimelineContent(
                                          dayLabels: dayLabels,
                                          dayColumnWidth: dayColumnWidth,
                                          slotHeight: slotHeight,
                                          slotCount: timeSlots.length,
                                          entriesForDay: (day) =>
                                              _viewModel.entriesForSelectedWeekDay(
                                            day,
                                          ),
                                          roomBuilder: _formatRoom,
                                          teacherBuilder: _formatTeacher,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
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

class _TimeSlot {
  const _TimeSlot(this.label);

  final String label;
}

List<_TimeSlot> _buildTimeSlots(List<TimePeriodRangeData> ranges) {
  return ranges
      .map((range) => _TimeSlot(TimeSlot.formatMinutes(range.startMinutes)))
      .toList();
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
