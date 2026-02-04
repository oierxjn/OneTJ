import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/data/course_schedule_net_data.dart';

class CourseTimeTableItemData {
  const CourseTimeTableItemData({
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
  final String? roomLabel;
  final String? roomIdI18n;
  final String? campusI18n;

  factory CourseTimeTableItemData.fromNetData(CourseTimeTableItemNetData data) {
    return CourseTimeTableItemData(
      dayOfWeek: data.dayOfWeek,
      timeStart: data.timeStart,
      timeEnd: data.timeEnd,
      roomId: data.roomId,
      teacherCode: data.teacherCode,
      weekNum: data.weekNum,
      weekstr: data.weekstr,
      teacherName: data.teacherName,
      timeAndRoom: data.timeAndRoom,
      timeTab: data.timeTab,
      className: data.className,
      classCode: data.classCode,
      courseName: data.courseName,
      courseCode: data.courseCode,
      teachingClassId: data.teachingClassId,
      campus: data.campus,
      weeks: data.weeks,
      timeId: data.timeId,
      popover: data.popover,
      roomCategory: data.roomCategory,
      roomLabel: data.roomLabel,
      roomIdI18n: data.roomIdI18n,
      campusI18n: data.campusI18n,
    );
  }

  factory CourseTimeTableItemData.fromJson(Map<String, dynamic> json) {
    final Object? rawWeeks = json['weeks'];
    final List<int>? weeks = rawWeeks is List<dynamic>
        ? rawWeeks.map((item) => item as int).toList()
        : null;
    return CourseTimeTableItemData(
      dayOfWeek: json['dayOfWeek'] as int?,
      timeStart: json['timeStart'] as int?,
      timeEnd: json['timeEnd'] as int?,
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
      teachingClassId: json['teachingClassId'] as int?,
      campus: json['campus'] as String?,
      weeks: weeks,
      timeId: json['timeId'] as String?,
      popover: json['popover'] as String?,
      roomCategory: json['roomCategory'] as String?,
      roomLabel: (json['roomLabel'] ?? json['roomLable']) as String?,
      roomIdI18n: json['roomIdI18n'] as String?,
      campusI18n: json['campusI18n'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'roomId': roomId,
      'teacherCode': teacherCode,
      'weekNum': weekNum,
      'weekstr': weekstr,
      'teacherName': teacherName,
      'timeAndRoom': timeAndRoom,
      'timeTab': timeTab,
      'className': className,
      'classCode': classCode,
      'courseName': courseName,
      'courseCode': courseCode,
      'teachingClassId': teachingClassId,
      'campus': campus,
      'weeks': weeks,
      'timeId': timeId,
      'popover': popover,
      'roomCategory': roomCategory,
      'roomLabel': roomLabel,
      'roomIdI18n': roomIdI18n,
      'campusI18n': campusI18n,
    };
  }
}

class CourseScheduleItemData {
  const CourseScheduleItemData({
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
  final List<CourseTimeTableItemData>? timeTableList;
  final String? compulsory;
  final String? classType;
  final String? roomCategory;
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

  factory CourseScheduleItemData.fromNetData(CourseScheduleItemNetData data) {
    return CourseScheduleItemData(
      teachingClassId: data.teachingClassId,
      classCode: data.classCode,
      className: data.className,
      campus: data.campus,
      courseCode: data.courseCode,
      courseName: data.courseName,
      assessmentMode: data.assessmentMode,
      isExemptionCourse: data.isExemptionCourse,
      credits: data.credits,
      teacherName: data.teacherName,
      classTime: data.classTime,
      classRoom: data.classRoom,
      classRoomName: data.classRoomName,
      classRoomPractice: data.classRoomPractice,
      remark: data.remark,
      timeTableList: data.timeTableList
          ?.map(CourseTimeTableItemData.fromNetData)
          .toList(),
      compulsory: data.compulsory,
      classType: data.classType,
      roomCategory: data.roomCategory,
      roomLabel: data.roomLabel,
      courseTakeType: data.courseTakeType,
      teachingWay: data.teachingWay,
      cloudCourseType: data.cloudCourseType,
      nonpubCloudCourseAddr: data.nonpubCloudCourseAddr,
      teachMode: data.teachMode,
      campusI18n: data.campusI18n,
      assessmentModeI18n: data.assessmentModeI18n,
      classRoomI18n: data.classRoomI18n,
      teachingWayI18n: data.teachingWayI18n,
      teachModeI18n: data.teachModeI18n,
    );
  }

  factory CourseScheduleItemData.fromJson(Map<String, dynamic> json) {
    final Object? rawTimeTableList = json['timeTableList'];
    final List<CourseTimeTableItemData>? timeTableList =
        rawTimeTableList is List<dynamic>
            ? rawTimeTableList
                .map((item) =>
                    CourseTimeTableItemData.fromJson(item as Map<String, dynamic>))
                .toList()
            : null;
    return CourseScheduleItemData(
      teachingClassId: json['teachingClassId'] as int?,
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
      timeTableList: timeTableList,
      compulsory: json['compulsory'] as String?,
      classType: json['classType'] as String?,
      roomCategory: json['roomCategory'] as String?,
      roomLabel: (json['roomLabel'] ?? json['roomLable']) as String?,
      courseTakeType: json['courseTakeType'] as int?,
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
  }

  Map<String, dynamic> toJson() {
    return {
      'teachingClassId': teachingClassId,
      'classCode': classCode,
      'className': className,
      'campus': campus,
      'courseCode': courseCode,
      'courseName': courseName,
      'assessmentMode': assessmentMode,
      'isExemptionCourse': isExemptionCourse,
      'credits': credits,
      'teacherName': teacherName,
      'classTime': classTime,
      'classRoom': classRoom,
      'classRoomName': classRoomName,
      'classRoomPractice': classRoomPractice,
      'remark': remark,
      'timeTableList': timeTableList?.map((item) => item.toJson()).toList(),
      'compulsory': compulsory,
      'classType': classType,
      'roomCategory': roomCategory,
      'roomLabel': roomLabel,
      'courseTakeType': courseTakeType,
      'teachingWay': teachingWay,
      'cloudCourseType': cloudCourseType,
      'nonpubCloudCourseAddr': nonpubCloudCourseAddr,
      'teachMode': teachMode,
      'campusI18n': campusI18n,
      'assessmentModeI18n': assessmentModeI18n,
      'classRoomI18n': classRoomI18n,
      'teachingWayI18n': teachingWayI18n,
      'teachModeI18n': teachModeI18n,
    };
  }
}

class CourseScheduleData {
  const CourseScheduleData({
    required this.items,
  });

  final List<CourseScheduleItemData> items;

  factory CourseScheduleData.fromNetDataList(
    List<CourseScheduleItemNetData> list,
  ) {
    return CourseScheduleData(
      items: list.map(CourseScheduleItemData.fromNetData).toList(),
    );
  }

  factory CourseScheduleData.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    final List<CourseScheduleItemData> items = rawItems is List<dynamic>
        ? rawItems
            .map((item) => CourseScheduleItemData.fromJson(item as Map<String, dynamic>))
            .toList()
        : const [];
    return CourseScheduleData(items: items);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

abstract class CourseScheduleStorage {
  Future<CourseScheduleData?> read();
  Future<void> save(CourseScheduleData data);
  Future<void> clear();
}

class HiveCourseScheduleStorage implements CourseScheduleStorage {
  HiveCourseScheduleStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'course_schedule';
  static const String _key = 'payload';
  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<CourseScheduleData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return CourseScheduleData.fromJson(data);
  }

  @override
  Future<void> save(CourseScheduleData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_key);
  }
}

class InMemoryCourseScheduleStorage implements CourseScheduleStorage {
  CourseScheduleData? _cache;

  @override
  Future<CourseScheduleData?> read() async => _cache;

  @override
  Future<void> save(CourseScheduleData data) async {
    _cache = data;
  }

  @override
  Future<void> clear() async {
    _cache = null;
  }
}

class CourseScheduleRepository {
  CourseScheduleRepository._({required CourseScheduleStorage storage})
      : _storage = storage;

  static CourseScheduleRepository? _instance;

  static CourseScheduleRepository getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    final CourseScheduleRepository repo = CourseScheduleRepository._(
      storage: HiveCourseScheduleStorage(),
    );
    _instance = repo;
    return repo;
  }

  final CourseScheduleStorage _storage;
  CourseScheduleData? _cached;

  Future<CourseScheduleData?> getCourseSchedule({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && _cached != null) {
      return _cached;
    }
    _cached = await _storage.read();
    return _cached;
  }

  Future<void> saveCourseSchedule(CourseScheduleData data) async {
    _cached = data;
    await _storage.save(data);
  }

  Future<void> saveFromNetDataList(
    List<CourseScheduleItemNetData> list,
  ) async {
    await saveCourseSchedule(CourseScheduleData.fromNetDataList(list));
  }

  Future<void> clearCourseSchedule() async {
    _cached = null;
    await _storage.clear();
  }
}
