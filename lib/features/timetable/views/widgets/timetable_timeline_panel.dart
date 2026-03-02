import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/timetable/view_models/timetable_view_model.dart';
import 'package:onetj/features/timetable/views/widgets/timeline_content.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/time_slot.dart';
import 'package:onetj/models/timetable_index.dart';

class TimetableTimelinePanel extends StatelessWidget {
  const TimetableTimelinePanel({
    required this.mode,
    required this.dayLabels,
    required this.timeSlotRanges,
    required this.selectedDay,
    required this.duration,
    required this.disableAnimations,
    required this.scrollController,
    required this.roomBuilder,
    required this.teacherBuilder,
    required this.entriesForDay,
    super.key,
  });

  final TimetableDisplayMode mode;
  final List<String> dayLabels;
  final List<TimePeriodRangeData> timeSlotRanges;
  final int selectedDay;
  final Duration duration;
  final bool disableAnimations;
  final ScrollController scrollController;
  final String Function(TimetableEntry) roomBuilder;
  final String Function(TimetableEntry) teacherBuilder;
  final List<TimetableEntry> Function(int day) entriesForDay;

  @override
  Widget build(BuildContext context) {
    const double slotHeight = 64;
    final List<_TimeSlot> timeSlots = _buildTimeSlots(timeSlotRanges);
    final double targetHeaderHeight =
        mode == TimetableDisplayMode.week ? _weekHeaderHeight(context) : 0;

    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: mode == TimetableDisplayMode.week
          ? Curves.easeOutCubic
          : Curves.easeInCubic,
      tween: Tween<double>(begin: 0, end: targetHeaderHeight),
      builder: (context, animatedHeaderHeight, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 12, 4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final _TimelineLayoutMetrics layoutMetrics = _computeTimelineMetrics(
                context,
                maxWidth: constraints.maxWidth,
                timeSlotsCount: timeSlots.length,
                slotHeight: slotHeight,
                animatedHeaderHeight: animatedHeaderHeight,
              );
              return SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  height: layoutMetrics.contentHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimelineTimeLabels(
                        width: layoutMetrics.labelWidth,
                        headerHeight: animatedHeaderHeight,
                        slotHeight: slotHeight,
                        timeSlots: timeSlots,
                        labelStyle: layoutMetrics.labelStyle,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TimelineGridAndContent(
                          headerHeight: animatedHeaderHeight,
                          slotHeight: slotHeight,
                          timeSlotsCount: timeSlots.length,
                          mode: mode,
                          dayLabels: dayLabels,
                          selectedDay: selectedDay,
                          dayColumnWidth: layoutMetrics.dayColumnWidth,
                          entriesForDay: entriesForDay,
                          roomBuilder: roomBuilder,
                          teacherBuilder: teacherBuilder,
                          duration: duration,
                          disableAnimations: disableAnimations,
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

  _TimelineLayoutMetrics _computeTimelineMetrics(
    BuildContext context, {
    required double maxWidth,
    required int timeSlotsCount,
    required double slotHeight,
    required double animatedHeaderHeight,
  }) {
    const double preferredLabelWidth = 72;
    const double minLabelWidth = 35;
    const double minCardWidth = 92;
    const double maxCardWidth = double.infinity;
    final double availableWidth = (maxWidth - 8).clamp(0, double.infinity);

    double labelWidth = preferredLabelWidth;
    double dayColumnWidth =
        ((availableWidth - labelWidth) / 7).clamp(0, maxCardWidth);

    if (dayColumnWidth < minCardWidth) {
      final double neededLabelWidth = availableWidth - minCardWidth * 7;
      labelWidth = neededLabelWidth.clamp(minLabelWidth, preferredLabelWidth);
      dayColumnWidth = ((availableWidth - labelWidth) / 7).clamp(0, maxCardWidth);
    }

    final bool isNarrowLabel = labelWidth <= minLabelWidth + 0.1;
    final TextStyle? labelStyle = isNarrowLabel
        ? Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)
        : Theme.of(context).textTheme.bodySmall;

    return _TimelineLayoutMetrics(
      labelWidth: labelWidth,
      dayColumnWidth: dayColumnWidth,
      labelStyle: labelStyle,
      contentHeight: timeSlotsCount * slotHeight + animatedHeaderHeight,
    );
  }
}

class _TimelineLayoutMetrics {
  const _TimelineLayoutMetrics({
    required this.labelWidth,
    required this.dayColumnWidth,
    required this.labelStyle,
    required this.contentHeight,
  });

  final double labelWidth;
  final double dayColumnWidth;
  final TextStyle? labelStyle;
  final double contentHeight;
}

class _TimelineTimeLabels extends StatelessWidget {
  const _TimelineTimeLabels({
    required this.width,
    required this.headerHeight,
    required this.slotHeight,
    required this.timeSlots,
    required this.labelStyle,
  });

  final double width;
  final double headerHeight;
  final double slotHeight;
  final List<_TimeSlot> timeSlots;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(height: headerHeight),
          for (final slot in timeSlots)
            SizedBox(
              height: slotHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(slot.startLabel, style: labelStyle),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(slot.endLabel, style: labelStyle),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineGridAndContent extends StatelessWidget {
  const _TimelineGridAndContent({
    required this.headerHeight,
    required this.slotHeight,
    required this.timeSlotsCount,
    required this.mode,
    required this.dayLabels,
    required this.selectedDay,
    required this.dayColumnWidth,
    required this.entriesForDay,
    required this.roomBuilder,
    required this.teacherBuilder,
    required this.duration,
    required this.disableAnimations,
  });

  final double headerHeight;
  final double slotHeight;
  final int timeSlotsCount;
  final TimetableDisplayMode mode;
  final List<String> dayLabels;
  final int selectedDay;
  final double dayColumnWidth;
  final List<TimetableEntry> Function(int day) entriesForDay;
  final String Function(TimetableEntry) roomBuilder;
  final String Function(TimetableEntry) teacherBuilder;
  final Duration duration;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              SizedBox(height: headerHeight),
              for (int i = 0; i < timeSlotsCount; i += 1)
                Container(
                  height: slotHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned.fill(
          child: _ModeContentSwitcher(
            mode: mode,
            duration: duration,
            disableAnimations: disableAnimations,
            dayChild: KeyedSubtree(
              key: const ValueKey<String>('day-content'),
              child: DayTimelineContent(
                entries: entriesForDay(selectedDay),
                slotHeight: slotHeight,
                slotCount: timeSlotsCount,
                roomBuilder: roomBuilder,
                teacherBuilder: teacherBuilder,
              ),
            ),
            weekChild: KeyedSubtree(
              key: const ValueKey<String>('week-content'),
              child: WeekTimelineContent(
                dayLabels: dayLabels,
                dayColumnWidth: dayColumnWidth,
                slotHeight: slotHeight,
                slotCount: timeSlotsCount,
                entriesForDay: entriesForDay,
                roomBuilder: roomBuilder,
                teacherBuilder: teacherBuilder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeContentSwitcher extends StatelessWidget {
  const _ModeContentSwitcher({
    required this.mode,
    required this.duration,
    required this.disableAnimations,
    required this.dayChild,
    required this.weekChild,
  });

  final TimetableDisplayMode mode;
  final Duration duration;
  final bool disableAnimations;
  final Widget dayChild;
  final Widget weekChild;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
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
      child: mode == TimetableDisplayMode.day ? dayChild : weekChild,
    );
  }
}

class _TimeSlot {
  const _TimeSlot({
    required this.startLabel,
    required this.endLabel,
  });

  final String startLabel;
  final String endLabel;
}

List<_TimeSlot> _buildTimeSlots(List<TimePeriodRangeData> ranges) {
  return ranges
      .map(
        (range) => _TimeSlot(
          startLabel: TimeSlot.formatMinutes(range.startMinutes),
          endLabel: TimeSlot.formatMinutes(range.endMinutes),
        ),
      )
      .toList();
}
