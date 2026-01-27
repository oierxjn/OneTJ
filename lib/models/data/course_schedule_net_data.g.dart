// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_schedule_net_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseScheduleItemNetData _$CourseScheduleItemNetDataFromJson(
        Map<String, dynamic> json) =>
    CourseScheduleItemNetData(
      teachingClassId: (json['teachingClassId'] as num?)?.toInt(),
      classCode: json['classCode'] as String?,
      className: json['className'] as String?,
      campus: json['campus'] as String?,
      courseCode: json['courseCode'] as String?,
      courseName: json['courseName'] as String?,
      assessmentMode: json['assessmentMode'] as String?,
      isExemptionCourse: json['isExemptionCourse'] as String?,
      credits: json['credits'] as num?,
      teacherName: json['teacherName'] as String?,
      classTime: json['classTime'] as String?,
      classRoom: json['classRoom'] as String?,
      classRoomName: json['classRoomName'] as String?,
      classRoomPractice: json['classRoomPractice'] as String?,
      remark: json['remark'] as String?,
      timeTableList: (json['timeTableList'] as List<dynamic>?)
          ?.map((e) =>
              CourseTimeTableItemNetData.fromJson(e as Map<String, dynamic>))
          .toList(),
      compulsory: json['compulsory'] as String?,
      classType: json['classType'] as String?,
      roomCategory: json['roomCategory'] as String?,
      roomLable: json['roomLable'] as String?,
      courseTakeType: (json['courseTakeType'] as num?)?.toInt(),
      teachingWay: json['teachingWay'] as String?,
      cloudCourseType: json['cloudCourseType'] as String?,
      nonpubCloudCourseAddr: json['nonpubCloudCourseAddr'] as String?,
      teachMode: json['teachMode'] as String?,
      campusI18n: json['campusI18n'] as String?,
      assessmentModeI18n: json['assessmentModeI18n'] as String?,
      classRoomI18n: json['classRoomI18n'] as String?,
      teachingWayI18n: json['teachingWayI18n'] as String?,
      teachModeI18n: json['teachModeI18n'] as String?,
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
      'roomLable': instance.roomLable,
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
    CourseTimeTableItemNetData(
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
      timeStart: (json['timeStart'] as num?)?.toInt(),
      timeEnd: (json['timeEnd'] as num?)?.toInt(),
      roomId: json['roomId'] as String?,
      teacherCode: json['teacherCode'] as String?,
      weekNum: json['weekNum'] as String?,
      weekstr: json['weekstr'] as String?,
      teacherName: json['teacherName'] as String?,
      timeAndRoom: json['timeAndRoom'] as String?,
      timeTab: json['timeTab'] as String?,
      className: json['className'] as String?,
      classCode: json['classCode'] as String?,
      courseName: json['courseName'] as String?,
      courseCode: json['courseCode'] as String?,
      teachingClassId: (json['teachingClassId'] as num?)?.toInt(),
      campus: json['campus'] as String?,
      weeks: (json['weeks'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      timeId: json['timeId'] as String?,
      popover: json['popover'] as String?,
      roomCategory: json['roomCategory'] as String?,
      roomLable: json['roomLable'] as String?,
      roomIdI18n: json['roomIdI18n'] as String?,
      campusI18n: json['campusI18n'] as String?,
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
      'roomLable': instance.roomLable,
      'roomIdI18n': instance.roomIdI18n,
      'campusI18n': instance.campusI18n,
    };
