import 'package:flutter/material.dart';

import 'package:onetj/models/timetable_index.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.entry,
    required this.roomBuilder,
    required this.teacherBuilder,
    super.key,
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
