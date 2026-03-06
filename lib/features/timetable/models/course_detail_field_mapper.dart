import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/repo/course_schedule_repository.dart';

class CourseDetailField {
  const CourseDetailField({
    required this.key,
    required this.value,
  });

  final String key;
  final String value;
}

const Set<String> _basicKeys = <String>{
  'courseName',
  'courseCode',
  'classCode',
  'className',
  'teacherName',
  'campus',
  'campusI18n',
  'roomId',
  'roomIdI18n',
  'roomLabel',
  'dayOfWeek',
  'timeStart',
  'timeEnd',
  'weeks',
  'weekNum',
  'teachingClassId',
};

List<CourseDetailField> mapCourseDetailExtraFields({
  required TimetableEntry entry,
  required TimetableIndex index,
}) {
  final List<CourseScheduleItemData> items = index.sourceData.items;
  if (entry.sourceItemIndex < 0 || entry.sourceItemIndex >= items.length) {
    return const <CourseDetailField>[];
  }

  final CourseScheduleItemData item = items[entry.sourceItemIndex];
  final List<CourseTimeTableItemData>? timeTableList = item.timeTableList;
  CourseTimeTableItemData? timeItem;
  if (timeTableList != null &&
      entry.sourceTimeTableIndex >= 0 &&
      entry.sourceTimeTableIndex < timeTableList.length) {
    timeItem = timeTableList[entry.sourceTimeTableIndex];
  }

  final Map<String, String> fields = <String, String>{};

  _putIfNotEmpty(fields, 'assessmentMode', item.assessmentMode);
  _putIfNotEmpty(fields, 'isExemptionCourse', item.isExemptionCourse);
  _putIfNotEmpty(fields, 'credits', item.credits);
  _putIfNotEmpty(fields, 'classTime', item.classTime);
  _putIfNotEmpty(fields, 'classRoom', item.classRoom);
  _putIfNotEmpty(fields, 'classRoomName', item.classRoomName);
  _putIfNotEmpty(fields, 'classRoomPractice', item.classRoomPractice);
  _putIfNotEmpty(fields, 'remark', item.remark);
  _putIfNotEmpty(fields, 'compulsory', item.compulsory);
  _putIfNotEmpty(fields, 'classType', item.classType);
  _putIfNotEmpty(fields, 'roomCategory', item.roomCategory);
  _putIfNotEmpty(fields, 'courseTakeType', item.courseTakeType);
  _putIfNotEmpty(fields, 'teachingWay', item.teachingWay);
  _putIfNotEmpty(fields, 'cloudCourseType', item.cloudCourseType);
  _putIfNotEmpty(fields, 'nonpubCloudCourseAddr', item.nonpubCloudCourseAddr);
  _putIfNotEmpty(fields, 'teachMode', item.teachMode);
  _putIfNotEmpty(fields, 'assessmentModeI18n', item.assessmentModeI18n);
  _putIfNotEmpty(fields, 'classRoomI18n', item.classRoomI18n);
  _putIfNotEmpty(fields, 'teachingWayI18n', item.teachingWayI18n);
  _putIfNotEmpty(fields, 'teachModeI18n', item.teachModeI18n);

  if (timeItem != null) {
    _putIfNotEmpty(fields, 'teacherCode', timeItem.teacherCode);
    _putIfNotEmpty(fields, 'weekstr', timeItem.weekstr);
    _putIfNotEmpty(fields, 'timeAndRoom', timeItem.timeAndRoom);
    _putIfNotEmpty(fields, 'timeTab', timeItem.timeTab);
    _putIfNotEmpty(fields, 'timeId', timeItem.timeId);
    _putIfNotEmpty(fields, 'popover', timeItem.popover);
    _putIfNotEmpty(fields, 'roomCategory', timeItem.roomCategory);
  }

  final List<MapEntry<String, String>> sorted = fields.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return sorted
      .map((entry) => CourseDetailField(key: entry.key, value: entry.value))
      .toList(growable: false);
}

void _putIfNotEmpty(
  Map<String, String> target,
  String key,
  Object? rawValue,
) {
  if (_basicKeys.contains(key) || rawValue == null) {
    return;
  }
  final String value;
  if (rawValue is List) {
    value = rawValue.join(',');
  } else {
    value = rawValue.toString();
  }
  if (value.trim().isEmpty) {
    return;
  }
  target[key] = value;
}
