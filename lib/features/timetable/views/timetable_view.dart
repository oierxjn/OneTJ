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
  final ScrollController _dayScrollController = ScrollController();

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
    _dayScrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _formatTimeRange(TimetableEntry entry) {
    final int? start = entry.timeStart;
    final int? end = entry.timeEnd;
    if (start != null && end != null) {
      return '$start-$end';
    }
    if (start != null) {
      return '$start';
    }
    return '-';
  }

  String _formatRoom(TimetableEntry entry) {
    return entry.roomIdI18n ?? entry.roomId ?? '-';
  }

  String _formatTeacher(TimetableEntry entry) {
    return entry.teacherName ?? '-';
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
              child: _viewModel.mode == TimetableDisplayMode.day
                  ? _buildDayView(context)
                  : _buildWeekView(context),
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

  Widget _buildDayView(BuildContext context) {
    final List<TimetableEntry> entries =
        _viewModel.entriesForDay(_viewModel.selectedDay);
    if (entries.isEmpty) {
      return const Center(child: Text('No classes today'));
    }
    /**
     * 每个时间槽的高度
     */
    const double slotHeight = 64;
    /**
     * 时间槽的标签宽度
     */
    const double labelWidth = 72;
    final double contentHeight = _timeSlots.length * slotHeight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _dayScrollController,
              child: SizedBox(
                height: contentHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: Column(
                        children: [
                          for (final slot in _timeSlots)
                            Container(
                              height: slotHeight,
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                slot.label,
                                style: Theme.of(context).textTheme.bodySmall,
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
                          for (final entry in entries)
                            _PositionedCourseCard(
                              entry: entry,
                              slotHeight: slotHeight,
                              slotCount: _timeSlots.length,
                              timeRangeBuilder: _formatTimeRange,
                              roomBuilder: _formatRoom,
                              teacherBuilder: _formatTeacher,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 7,
      itemBuilder: (context, i) {
        final int day = i + 1;
        final List<TimetableEntry> entries = _viewModel.entriesForDay(day);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dayLabels[i],
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (entries.isEmpty)
                  const Text('No classes')
                else
                  Column(
                    children: entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Text(
                                  _formatTimeRange(entry),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.courseName ?? 'Unknown course',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
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

class _PositionedCourseCard extends StatelessWidget {
  const _PositionedCourseCard({
    required this.entry,
    required this.slotHeight,
    required this.slotCount,
    required this.timeRangeBuilder,
    required this.roomBuilder,
    required this.teacherBuilder,
  });

  final TimetableEntry entry;
  final double slotHeight;
  final int slotCount;
  final String Function(TimetableEntry) timeRangeBuilder;
  final String Function(TimetableEntry) roomBuilder;
  final String Function(TimetableEntry) teacherBuilder;

  @override
  Widget build(BuildContext context) {
    final int startSlot = _clampSlot(entry.timeStart ?? 1);
    final int endSlot = _clampSlot(entry.timeEnd ?? startSlot);
    final int safeStart = startSlot <= endSlot ? startSlot : endSlot;
    final int safeEnd = startSlot <= endSlot ? endSlot : startSlot;
    final double top = (safeStart - 1) * slotHeight + 6;
    final double height =
        (safeEnd - safeStart + 1) * slotHeight - 12;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: height.clamp(40, double.infinity),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.courseName ?? 'Unknown course',
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                timeRangeBuilder(entry),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                roomBuilder(entry),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                teacherBuilder(entry),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
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
