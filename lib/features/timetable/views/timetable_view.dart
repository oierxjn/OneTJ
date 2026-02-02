import 'package:flutter/material.dart';

import 'package:onetj/features/timetable/view_models/timetable_view_model.dart';
import 'package:onetj/models/timetable_index.dart';

class TimetableView extends StatefulWidget {
  const TimetableView({super.key});

  @override
  State<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<TimetableView> {
  static const List<String> _dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  late final TimetableViewModel _viewModel;
  late final FixedExtentScrollController _dayController;
  late final FixedExtentScrollController _weekController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = TimetableViewModel();
    _dayController = FixedExtentScrollController(
      initialItem: _viewModel.selectedDay - 1,
    );
    _weekController = FixedExtentScrollController();
    _viewModel.load();
  }

  @override
  void dispose() {
    _dayController.dispose();
    _weekController.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _formatRoom(TimetableEntry entry) {
    return entry.roomIdI18n.isNotEmpty ? entry.roomIdI18n : entry.roomId;
  }

  String _formatTeacher(TimetableEntry entry) {
    return entry.teacherName;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_viewModel.error != null) {
          return Center(
            child: Text('Failed to load timetable: ${_viewModel.error}'),
          );
        }
        final TimetableIndex? index = _viewModel.index;
        if (index == null || index.allEntries.isEmpty) {
          return const Center(child: Text('No timetable data'));
        }

        _syncWheelControllers();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SegmentedButton<TimetableDisplayMode>(
                segments: const [
                  ButtonSegment(
                    value: TimetableDisplayMode.day,
                    label: Text('Day'),
                  ),
                  ButtonSegment(
                    value: TimetableDisplayMode.week,
                    label: Text('Week'),
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
                height: 56,
                child: _HorizontalWheel(
                  controller: _weekController,
                  itemExtent: 90,
                  itemCount: _viewModel.availableWeeks.length,
                  onSelectedItemChanged: (index) {
                    if (index < 0 ||
                        index >= _viewModel.availableWeeks.length) {
                      return;
                    }
                    _viewModel.selectWeek(_viewModel.availableWeeks[index]);
                  },
                  itemBuilder: (context, index) {
                    final int week = _viewModel.availableWeeks[index];
                    final bool selected =
                        _viewModel.selectedWeek == week;
                    return _WheelItem(
                      label: 'Week $week',
                      selected: selected,
                    );
                  },
                ),
              ),
            if (_viewModel.mode == TimetableDisplayMode.day)
              SizedBox(
                height: 56,
                child: _HorizontalWheel(
                  controller: _dayController,
                  itemExtent: 64,
                  itemCount: _dayLabels.length,
                  onSelectedItemChanged: (index) {
                    if (index < 0 || index >= _dayLabels.length) {
                      return;
                    }
                    _viewModel.selectDay(index + 1);
                  },
                  itemBuilder: (context, index) {
                    final bool selected =
                        _viewModel.selectedDay == index + 1;
                    return _WheelItem(
                      label: _dayLabels[index],
                      selected: selected,
                    );
                  },
                ),
              ),
            Expanded(
              child: _buildTimetableView(context, mode: _viewModel.mode),
            ),
          ],
        );
      },
    );
  }

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
    if (controller.hasClients) {
      if (controller.selectedItem != targetIndex) {
        controller.jumpToItem(targetIndex);
      }
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !controller.hasClients) {
        return;
      }
      if (controller.selectedItem != targetIndex) {
        controller.jumpToItem(targetIndex);
      }
    });
  }

  double _weekHeaderHeight(BuildContext context) {
    final TextStyle style =
        Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    const double padding = 8;
    final TextPainter painter = TextPainter(
      text: TextSpan(text: 'Mon', style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.height + padding;
  }

  Widget _buildTimetableView(
    BuildContext context, {
    required TimetableDisplayMode mode,
  }) {
    const double slotHeight = 64;
    const double preferredLabelWidth = 72;
    const double minLabelWidth = 35;
    final double headerHeight =
        mode == TimetableDisplayMode.week ? _weekHeaderHeight(context) : 0;
    final double contentHeight =
        _timeSlots.length * slotHeight + headerHeight;

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
            final double neededLabelWidth =
                availableWidth - minCardWidth * 7;
            labelWidth = neededLabelWidth.clamp(minLabelWidth, preferredLabelWidth);
            dayColumnWidth =
                ((availableWidth - labelWidth) / 7).clamp(0, maxCardWidth);
          }
          final bool isNarrowLabel = labelWidth <= minLabelWidth + 0.1;
          final TextStyle? labelStyle = isNarrowLabel
              ? Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 11)
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
                        if (headerHeight > 0) SizedBox(height: headerHeight),
                        for (final slot in _timeSlots)
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
                              if (headerHeight > 0) SizedBox(height: headerHeight),
                              for (int i = 0; i < _timeSlots.length; i += 1)
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
                        if (mode == TimetableDisplayMode.day)
                          Positioned.fill(
                            child: _DayTimelineContent(
                              entries: _viewModel.entriesForSelectedWeekDay(
                                _viewModel.selectedDay,
                              ),
                              slotHeight: slotHeight,
                              slotCount: _timeSlots.length,
                              roomBuilder: _formatRoom,
                              teacherBuilder: _formatTeacher,
                            ),
                          )
                        else if (mode == TimetableDisplayMode.week)
                          Positioned.fill(
                            child: _WeekTimelineContent(
                              dayLabels: _dayLabels,
                              dayColumnWidth: dayColumnWidth,
                              slotHeight: slotHeight,
                              slotCount: _timeSlots.length,
                              entriesForDay: (day) =>
                                  _viewModel.entriesForSelectedWeekDay(day),
                              roomBuilder: _formatRoom,
                              teacherBuilder: _formatTeacher,
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
  }
}
class _DayTimelineContent extends StatelessWidget {
  const _DayTimelineContent({
    required this.entries,
    required this.slotHeight,
    required this.slotCount,
    required this.roomBuilder,
    required this.teacherBuilder,
  });

  final List<TimetableEntry> entries;
  final double slotHeight;
  final int slotCount;
  final String Function(TimetableEntry) roomBuilder;
  final String Function(TimetableEntry) teacherBuilder;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No classes today'));
    }
    return CustomMultiChildLayout(
      delegate: _CourseLayoutDelegate(
        entries: entries,
        slotHeight: slotHeight,
        slotCount: slotCount,
      ),
      children: [
        for (int i = 0; i < entries.length; i += 1)
          LayoutId(
            id: _courseId(i),
            child: _CourseCard(
              entry: entries[i],
              roomBuilder: roomBuilder,
              teacherBuilder: teacherBuilder,
            ),
          ),
      ],
    );
  }
}

class _WeekTimelineContent extends StatelessWidget {
  const _WeekTimelineContent({
    required this.dayLabels,
    required this.dayColumnWidth,
    required this.slotHeight,
    required this.slotCount,
    required this.entriesForDay,
    required this.roomBuilder,
    required this.teacherBuilder,
  });

  final List<String> dayLabels;
  final double dayColumnWidth;
  final double slotHeight;
  final int slotCount;
  final List<TimetableEntry> Function(int day) entriesForDay;
  final String Function(TimetableEntry) roomBuilder;
  final String Function(TimetableEntry) teacherBuilder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < dayLabels.length; i += 1)
            Builder(
              builder: (context) {
                final List<TimetableEntry> dayEntries =
                    entriesForDay(i + 1);
                return SizedBox(
                  width: dayColumnWidth,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          dayLabels[i],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: CustomMultiChildLayout(
                          delegate: _CourseLayoutDelegate(
                            entries: dayEntries,
                            slotHeight: slotHeight,
                            slotCount: slotCount,
                          ),
                          children: [
                            for (int j = 0; j < dayEntries.length; j += 1)
                              LayoutId(
                                id: _courseId(j),
                                child: _CourseCard(
                                  entry: dayEntries[j],
                                  roomBuilder: roomBuilder,
                                  teacherBuilder: teacherBuilder,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
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

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.entry,
    required this.roomBuilder,
    required this.teacherBuilder,
  });

  final TimetableEntry entry;
  final String Function(TimetableEntry) roomBuilder;
  final String Function(TimetableEntry) teacherBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double cardWidth = constraints.maxWidth;
          final double pad = cardWidth <= 92 ? 2 : (cardWidth <= 120 ? 6 : 10);
          final TextStyle titleStyle =
              Theme.of(context).textTheme.titleSmall ?? const TextStyle();
          final TextStyle bodyStyle =
              Theme.of(context).textTheme.bodySmall ?? const TextStyle();
          const double gap = 4;
          final String titleText = entry.courseName.isNotEmpty
              ? entry.courseName
              : 'Unknown course';
          final String roomText = roomBuilder(entry);
          final String teacherText = teacherBuilder(entry);
          final String classCodeText = entry.classCode;

          final double scrollHeight =
              (constraints.maxHeight - pad * 2).clamp(0, double.infinity);

          return Padding(
            padding: EdgeInsets.all(pad),
            child: SizedBox(
              height: scrollHeight,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: titleStyle,
                    ),
                    if (roomText.isNotEmpty) ...[
                      const SizedBox(height: gap),
                      Text(
                        roomText,
                        style: bodyStyle,
                      ),
                    ],
                    if (teacherText.isNotEmpty) ...[
                      const SizedBox(height: gap),
                      Text(
                        teacherText,
                        style: bodyStyle,
                      ),
                    ],
                    if (classCodeText.isNotEmpty) ...[
                      const SizedBox(height: gap),
                      Text(
                        classCodeText,
                        style: bodyStyle,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CourseLayoutDelegate extends MultiChildLayoutDelegate {
  _CourseLayoutDelegate({
    required this.entries,
    required this.slotHeight,
    required this.slotCount,
  });

  final List<TimetableEntry> entries;
  final double slotHeight;
  final int slotCount;

  @override
  void performLayout(Size size) {
    for (int i = 0; i < entries.length; i += 1) {
      final TimetableEntry entry = entries[i];
      final Object id = _courseId(i);
      if (!hasChild(id)) {
        continue;
      }
      final int startSlot = _clampSlot(entry.timeStart);
      final int endSlot = _clampSlot(entry.timeEnd);
      final double top = (startSlot - 1) * slotHeight + 6;
      final double height =
          (endSlot - startSlot + 1) * slotHeight - 12;
      final double cardHeight = height.clamp(40, double.infinity);

      layoutChild(
        id,
        BoxConstraints.tightFor(
          width: size.width,
          height: cardHeight,
        ),
      );
      positionChild(id, Offset(0, top));
    }
  }

  @override
  bool shouldRelayout(covariant _CourseLayoutDelegate oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.slotHeight != slotHeight ||
        oldDelegate.slotCount != slotCount;
  }

  int _clampSlot(int slot) {
    if (slot < 1) {
      return 1;
    }
    if (slot > slotCount) {
      return slotCount;
    }
    return slot;
  }
}

Object _courseId(int index) => 'course_$index';

class _TimeSlot {
  const _TimeSlot(this.label);

  final String label;
}

const List<_TimeSlot> _timeSlots = [
  _TimeSlot('08:00'),
  _TimeSlot('08:55'),
  _TimeSlot('10:00'),
  _TimeSlot('10:55'),
  _TimeSlot('13:30'),
  _TimeSlot('14:25'),
  _TimeSlot('15:30'),
  _TimeSlot('16:25'),
  _TimeSlot('18:30'),
  _TimeSlot('19:25'),
];

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
