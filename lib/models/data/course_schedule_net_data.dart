import 'package:json_annotation/json_annotation.dart';

part 'course_schedule_net_data.g.dart';

@JsonSerializable(explicitToJson: true, checked: true)
class CourseScheduleItemNetData {
  final int? teachingClassId;
  final String? classCode;
  final String? className;
  final String? campus;
  final String? courseCode;
  final String? courseName;
  final String? assessmentMode;
  final String? isExemptionCourse;
  final num? credits;
  final String? teacherName;
  final String? classTime;
  final String? classRoom;
  final String? classRoomName;
  final String? classRoomPractice;
  final String? remark;
  final List<CourseTimeTableItemNetData>? timeTableList;
  final String? compulsory;
  final String? classType;
  final String? roomCategory;
  @JsonKey(readValue: _readRoomLabel)
  final String? roomLabel;
  final int? courseTakeType;
  final String? teachingWay;
  final String? cloudCourseType;
  final String? nonpubCloudCourseAddr;
  final String? teachMode;
  final String? campusI18n;
  final String? assessmentModeI18n;
  final String? classRoomI18n;
  final String? teachingWayI18n;
  final String? teachModeI18n;

  const CourseScheduleItemNetData({
    this.teachingClassId,
    this.classCode,
    this.className,
    this.campus,
    this.courseCode,
    this.courseName,
    this.assessmentMode,
    this.isExemptionCourse,
    this.credits,
    this.teacherName,
    this.classTime,
    this.classRoom,
    this.classRoomName,
    this.classRoomPractice,
    this.remark,
    this.timeTableList,
    this.compulsory,
    this.classType,
    this.roomCategory,
    this.roomLabel,
    this.courseTakeType,
    this.teachingWay,
    this.cloudCourseType,
    this.nonpubCloudCourseAddr,
    this.teachMode,
    this.campusI18n,
    this.assessmentModeI18n,
    this.classRoomI18n,
    this.teachingWayI18n,
    this.teachModeI18n,
  });

  factory CourseScheduleItemNetData.fromJson(Map<String, dynamic> json) =>
      _$CourseScheduleItemNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$CourseScheduleItemNetDataToJson(this);

  static Object? _readRoomLabel(Map<dynamic, dynamic> json, String key) {
    return json['roomLabel'] ?? json['roomLable'];
  }
}

@JsonSerializable(checked: true)
class CourseTimeTableItemNetData {
  final int? dayOfWeek;
  final int? timeStart;
  final int? timeEnd;
  final String? roomId;
  final String? teacherCode;
  final String? weekNum;
  final String? weekstr;
  final String? teacherName;
  final String? timeAndRoom;
  final String? timeTab;
  final String? className;
  final String? classCode;
  final String? courseName;
  final String? courseCode;
  final int? teachingClassId;
  final String? campus;
  final List<int>? weeks;
  final String? timeId;
  final String? popover;
  final String? roomCategory;
  @JsonKey(readValue: _readRoomLabel)
  final String? roomLabel;
  final String? roomIdI18n;
  final String? campusI18n;

  const CourseTimeTableItemNetData({
    this.dayOfWeek,
    this.timeStart,
    this.timeEnd,
    this.roomId,
    this.teacherCode,
    this.weekNum,
    this.weekstr,
    this.teacherName,
    this.timeAndRoom,
    this.timeTab,
    this.className,
    this.classCode,
    this.courseName,
    this.courseCode,
    this.teachingClassId,
    this.campus,
    this.weeks,
    this.timeId,
    this.popover,
    this.roomCategory,
    this.roomLabel,
    this.roomIdI18n,
    this.campusI18n,
  });

  factory CourseTimeTableItemNetData.fromJson(Map<String, dynamic> json) =>
      _$CourseTimeTableItemNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$CourseTimeTableItemNetDataToJson(this);

  static Object? _readRoomLabel(Map<dynamic, dynamic> json, String key) {
    return json['roomLabel'] ?? json['roomLable'];
  }
}
