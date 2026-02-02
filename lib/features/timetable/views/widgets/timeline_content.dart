import 'package:flutter/material.dart';

import 'package:onetj/features/timetable/views/layouts/course_layout_delegate.dart';
import 'package:onetj/features/timetable/views/widgets/course_card.dart';
import 'package:onetj/models/timetable_index.dart';

class DayTimelineContent extends StatelessWidget {
  const DayTimelineContent({
    required this.entries,
    required this.slotHeight,
    required this.slotCount,
    required this.roomBuilder,
    required this.teacherBuilder,
    super.key,
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
      delegate: CourseLayoutDelegate(
        entries: entries,
        slotHeight: slotHeight,
        slotCount: slotCount,
      ),
      children: [
        for (int i = 0; i < entries.length; i += 1)
          LayoutId(
            id: courseId(i),
            child: CourseCard(
              entry: entries[i],
              roomBuilder: roomBuilder,
              teacherBuilder: teacherBuilder,
            ),
          ),
      ],
    );
  }
}

class WeekTimelineContent extends StatelessWidget {
  const WeekTimelineContent({
    required this.dayLabels,
    required this.dayColumnWidth,
    required this.slotHeight,
    required this.slotCount,
    required this.entriesForDay,
    required this.roomBuilder,
    required this.teacherBuilder,
    super.key,
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
                          delegate: CourseLayoutDelegate(
                            entries: dayEntries,
                            slotHeight: slotHeight,
                            slotCount: slotCount,
                          ),
                          children: [
                            for (int j = 0; j < dayEntries.length; j += 1)
                              LayoutId(
                                id: courseId(j),
                                child: CourseCard(
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
