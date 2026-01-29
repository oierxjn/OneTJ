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

  @override
  void initState() {
    super.initState();
    _viewModel = TimetableViewModel();
    _viewModel.load();
  }

  @override
  void dispose() {
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
                height: 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final week in _viewModel.availableWeeks)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text('W$week'),
                          selected: _viewModel.selectedWeek == week,
                          onSelected: (_) {
                            _viewModel.selectWeek(week);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            if (_viewModel.mode == TimetableDisplayMode.day)
              SizedBox(
                height: 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (int day = 1; day <= 7; day += 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(_dayLabels[day - 1]),
                          selected: _viewModel.selectedDay == day,
                          onSelected: (_) {
                            _viewModel.selectDay(day);
                          },
                        ),
                      ),
                  ],
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

  Widget _buildDayView(BuildContext context) {
    final List<TimetableEntry> entries =
        _viewModel.entriesForDay(_viewModel.selectedDay);
    if (entries.isEmpty) {
      return const Center(child: Text('No classes today'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final TimetableEntry entry = entries[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.courseName ?? 'Unknown course',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 6),
                    Text(_formatTimeRange(entry)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 6),
                    Text(_formatRoom(entry)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 6),
                    Text(_formatTeacher(entry)),
                  ],
                ),
                if (entry.className != null || entry.classCode != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entry.className ?? entry.classCode ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
