import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/timetable/models/course_detail_field_mapper.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/time_slot.dart';
import 'package:onetj/models/timetable_index.dart';

Future<void> showCourseDetailBottomSheet({
  required BuildContext context,
  required TimetableEntry entry,
  required TimetableIndex index,
  required List<TimePeriodRangeData> timeSlotRanges,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext sheetContext) => CourseDetailBottomSheet(
      entry: entry,
      index: index,
      timeSlotRanges: timeSlotRanges,
    ),
  );
}

class CourseDetailBottomSheet extends StatelessWidget {
  const CourseDetailBottomSheet({
    required this.entry,
    required this.index,
    required this.timeSlotRanges,
    super.key,
  });

  final TimetableEntry entry;
  final TimetableIndex index;
  final List<TimePeriodRangeData> timeSlotRanges;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String title = entry.courseName.isNotEmpty
        ? entry.courseName
        : l10n.courseDetailUnknownCourse;
    final List<_DetailField> basicFields = _buildBasicFields(l10n);
    final List<CourseDetailField> extraFields = mapCourseDetailExtraFields(
      entry: entry,
      index: index,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            l10n.courseDetailSectionBasic,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (final _DetailField field in basicFields)
            _DetailRow(label: field.label, value: field.value),
          if (extraFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.courseDetailSectionExtra,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final CourseDetailField item in extraFields)
              _DetailRow(label: item.key, value: item.value),
          ],
        ],
      ),
    );
  }

  List<_DetailField> _buildBasicFields(AppLocalizations l10n) {
    final List<_DetailField> fields = <_DetailField>[
      _DetailField(
        label: l10n.courseDetailFieldCourseCode,
        value: entry.courseCode,
      ),
      _DetailField(
        label: l10n.courseDetailFieldClassCode,
        value: entry.classCode,
      ),
      _DetailField(
        label: l10n.courseDetailFieldClassName,
        value: entry.className,
      ),
      _DetailField(
        label: l10n.courseDetailFieldTeacher,
        value: entry.teacherName,
      ),
      _DetailField(
        label: l10n.courseDetailFieldDay,
        value: _weekdayLabel(l10n, entry.dayOfWeek),
      ),
      _DetailField(
        label: l10n.courseDetailFieldTime,
        value: _formatTimeRange(entry, timeSlotRanges),
      ),
      _DetailField(
        label: l10n.courseDetailFieldPeriods,
        value: '${entry.timeStart}-${entry.timeEnd}',
      ),
      _DetailField(
        label: l10n.courseDetailFieldWeeks,
        value: _formatWeeks(entry),
      ),
      _DetailField(
        label: l10n.courseDetailFieldWeekNum,
        value: entry.weekNum,
      ),
      _DetailField(
        label: l10n.courseDetailFieldRoom,
        value: _formatRoom(entry),
      ),
      _DetailField(
        label: l10n.courseDetailFieldCampus,
        value: _formatCampus(entry),
      ),
      _DetailField(
        label: l10n.courseDetailFieldTeachingClassId,
        value: entry.teachingClassId?.toString() ?? '',
      ),
    ];
    return fields.where((f) => f.value.trim().isNotEmpty).toList();
  }
}

class _DetailField {
  const _DetailField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.bodySmall;
    final TextStyle? valueStyle = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: labelStyle?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

String _formatRoom(TimetableEntry entry) {
  if (entry.roomIdI18n.isNotEmpty) {
    return entry.roomIdI18n;
  }
  if (entry.roomLabel.isNotEmpty) {
    return entry.roomLabel;
  }
  return entry.roomId;
}

String _formatCampus(TimetableEntry entry) {
  if (entry.campusI18n.isNotEmpty) {
    return entry.campusI18n;
  }
  return entry.campus;
}

String _formatWeeks(TimetableEntry entry) {
  if (entry.weeks.isEmpty) {
    return '';
  }
  return entry.weeks.join(', ');
}

String _weekdayLabel(AppLocalizations l10n, int dayOfWeek) {
  switch (dayOfWeek) {
    case 1:
      return l10n.weekdayMon;
    case 2:
      return l10n.weekdayTue;
    case 3:
      return l10n.weekdayWed;
    case 4:
      return l10n.weekdayThu;
    case 5:
      return l10n.weekdayFri;
    case 6:
      return l10n.weekdaySat;
    case 7:
      return l10n.weekdaySun;
    default:
      return '';
  }
}

String _formatTimeRange(
  TimetableEntry entry,
  List<TimePeriodRangeData> ranges,
) {
  final String start = _slotStartLabel(entry.timeStart, ranges);
  final String end = _slotEndLabel(entry.timeEnd, ranges);
  if (start.isEmpty && end.isEmpty) {
    return '${entry.timeStart}-${entry.timeEnd}';
  }
  if (start.isEmpty) {
    return '${entry.timeStart}-$end';
  }
  if (end.isEmpty) {
    return '$start-${entry.timeEnd}';
  }
  return '$start-$end';
}

String _slotStartLabel(int slot, List<TimePeriodRangeData> ranges) {
  final int index = slot - 1;
  if (index < 0 || index >= ranges.length) {
    return '';
  }
  return TimeSlot.formatMinutes(ranges[index].startMinutes);
}

String _slotEndLabel(int slot, List<TimePeriodRangeData> ranges) {
  final int index = slot - 1;
  if (index < 0 || index >= ranges.length) {
    return '';
  }
  return TimeSlot.formatMinutes(ranges[index].endMinutes);
}
