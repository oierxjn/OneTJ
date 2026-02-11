// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_schedule_net_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseScheduleItemNetData _$CourseScheduleItemNetDataFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'CourseScheduleItemNetData',
      json,
      ($checkedConvert) {
        final val = CourseScheduleItemNetData(
          teachingClassId:
              $checkedConvert('teachingClassId', (v) => (v as num?)?.toInt()),
          classCode: $checkedConvert('classCode', (v) => v as String?),
          className: $checkedConvert('className', (v) => v as String?),
          campus: $checkedConvert('campus', (v) => v as String?),
          courseCode: $checkedConvert('courseCode', (v) => v as String?),
          courseName: $checkedConvert('courseName', (v) => v as String?),
          assessmentMode:
              $checkedConvert('assessmentMode', (v) => v as String?),
          isExemptionCourse:
              $checkedConvert('isExemptionCourse', (v) => v as String?),
          credits: $checkedConvert('credits', (v) => v as num?),
          teacherName: $checkedConvert('teacherName', (v) => v as String?),
          classTime: $checkedConvert('classTime', (v) => v as String?),
          classRoom: $checkedConvert('classRoom', (v) => v as String?),
          classRoomName: $checkedConvert('classRoomName', (v) => v as String?),
          classRoomPractice:
              $checkedConvert('classRoomPractice', (v) => v as String?),
          remark: $checkedConvert('remark', (v) => v as String?),
          timeTableList: $checkedConvert(
              'timeTableList',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => CourseTimeTableItemNetData.fromJson(
                      e as Map<String, dynamic>))
                  .toList()),
          compulsory: $checkedConvert('compulsory', (v) => v as String?),
          classType: $checkedConvert('classType', (v) => v as String?),
          roomCategory: $checkedConvert('roomCategory', (v) => v as String?),
          roomLabel: $checkedConvert(
            'roomLabel',
            (v) => v as String?,
            readValue: CourseScheduleItemNetData._readRoomLabel,
          ),
          courseTakeType:
              $checkedConvert('courseTakeType', (v) => (v as num?)?.toInt()),
          teachingWay: $checkedConvert('teachingWay', (v) => v as String?),
          cloudCourseType:
              $checkedConvert('cloudCourseType', (v) => v as String?),
          nonpubCloudCourseAddr:
              $checkedConvert('nonpubCloudCourseAddr', (v) => v as String?),
          teachMode: $checkedConvert('teachMode', (v) => v as String?),
          campusI18n: $checkedConvert('campusI18n', (v) => v as String?),
          assessmentModeI18n:
              $checkedConvert('assessmentModeI18n', (v) => v as String?),
          classRoomI18n: $checkedConvert('classRoomI18n', (v) => v as String?),
          teachingWayI18n:
              $checkedConvert('teachingWayI18n', (v) => v as String?),
          teachModeI18n: $checkedConvert('teachModeI18n', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$CourseScheduleItemNetDataToJson(
        CourseScheduleItemNetData instance) =>
    <String, dynamic>{
      'teachingClassId': instance.teachingClassId,
      'classCode': instance.classCode,
      'className': instance.className,
      'campus': instance.campus,
      'courseCode': instance.courseCode,
      'courseName': instance.courseName,
      'assessmentMode': instance.assessmentMode,
      'isExemptionCourse': instance.isExemptionCourse,
      'credits': instance.credits,
      'teacherName': instance.teacherName,
      'classTime': instance.classTime,
      'classRoom': instance.classRoom,
      'classRoomName': instance.classRoomName,
      'classRoomPractice': instance.classRoomPractice,
      'remark': instance.remark,
      'timeTableList': instance.timeTableList?.map((e) => e.toJson()).toList(),
      'compulsory': instance.compulsory,
      'classType': instance.classType,
      'roomCategory': instance.roomCategory,
      'roomLabel': instance.roomLabel,
      'courseTakeType': instance.courseTakeType,
      'teachingWay': instance.teachingWay,
      'cloudCourseType': instance.cloudCourseType,
      'nonpubCloudCourseAddr': instance.nonpubCloudCourseAddr,
      'teachMode': instance.teachMode,
      'campusI18n': instance.campusI18n,
      'assessmentModeI18n': instance.assessmentModeI18n,
      'classRoomI18n': instance.classRoomI18n,
      'teachingWayI18n': instance.teachingWayI18n,
      'teachModeI18n': instance.teachModeI18n,
    };

CourseTimeTableItemNetData _$CourseTimeTableItemNetDataFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'CourseTimeTableItemNetData',
      json,
      ($checkedConvert) {
        final val = CourseTimeTableItemNetData(
          dayOfWeek: $checkedConvert('dayOfWeek', (v) => (v as num?)?.toInt()),
          timeStart: $checkedConvert('timeStart', (v) => (v as num?)?.toInt()),
          timeEnd: $checkedConvert('timeEnd', (v) => (v as num?)?.toInt()),
          roomId: $checkedConvert('roomId', (v) => v as String?),
          teacherCode: $checkedConvert('teacherCode', (v) => v as String?),
          weekNum: $checkedConvert('weekNum', (v) => v as String?),
          weekstr: $checkedConvert('weekstr', (v) => v as String?),
          teacherName: $checkedConvert('teacherName', (v) => v as String?),
          timeAndRoom: $checkedConvert('timeAndRoom', (v) => v as String?),
          timeTab: $checkedConvert('timeTab', (v) => v as String?),
          className: $checkedConvert('className', (v) => v as String?),
          classCode: $checkedConvert('classCode', (v) => v as String?),
          courseName: $checkedConvert('courseName', (v) => v as String?),
          courseCode: $checkedConvert('courseCode', (v) => v as String?),
          teachingClassId:
              $checkedConvert('teachingClassId', (v) => (v as num?)?.toInt()),
          campus: $checkedConvert('campus', (v) => v as String?),
          weeks: $checkedConvert(
              'weeks',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => (e as num).toInt())
                  .toList()),
          timeId: $checkedConvert('timeId', (v) => v as String?),
          popover: $checkedConvert('popover', (v) => v as String?),
          roomCategory: $checkedConvert('roomCategory', (v) => v as String?),
          roomLabel: $checkedConvert(
            'roomLabel',
            (v) => v as String?,
            readValue: CourseTimeTableItemNetData._readRoomLabel,
          ),
          roomIdI18n: $checkedConvert('roomIdI18n', (v) => v as String?),
          campusI18n: $checkedConvert('campusI18n', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$CourseTimeTableItemNetDataToJson(
        CourseTimeTableItemNetData instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'timeStart': instance.timeStart,
      'timeEnd': instance.timeEnd,
      'roomId': instance.roomId,
      'teacherCode': instance.teacherCode,
      'weekNum': instance.weekNum,
      'weekstr': instance.weekstr,
      'teacherName': instance.teacherName,
      'timeAndRoom': instance.timeAndRoom,
      'timeTab': instance.timeTab,
      'className': instance.className,
      'classCode': instance.classCode,
      'courseName': instance.courseName,
      'courseCode': instance.courseCode,
      'teachingClassId': instance.teachingClassId,
      'campus': instance.campus,
      'weeks': instance.weeks,
      'timeId': instance.timeId,
      'popover': instance.popover,
      'roomCategory': instance.roomCategory,
      'roomLabel': instance.roomLabel,
      'roomIdI18n': instance.roomIdI18n,
      'campusI18n': instance.campusI18n,
    };
