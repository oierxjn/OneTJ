import 'dart:async';
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
  Future<CourseScheduleCacheMeta?> readMeta();
  Future<void> save(CourseScheduleData data);
  Future<void> saveMeta(CourseScheduleCacheMeta meta);
  Future<void> clear();
}

class CourseScheduleCacheMeta {
  const CourseScheduleCacheMeta({
    required this.lastFetchedAtMillis,
    this.termKey,
  });

  final int lastFetchedAtMillis;
  final String? termKey;

  factory CourseScheduleCacheMeta.fromJson(Map<String, dynamic> json) {
    return CourseScheduleCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
      termKey: json['termKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastFetchedAtMillis': lastFetchedAtMillis,
      'termKey': termKey,
    };
  }
}

class HiveCourseScheduleStorage implements CourseScheduleStorage {
  HiveCourseScheduleStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'course_schedule';
  static const String _key = 'payload';
  static const String _metaKey = 'meta';
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
  Future<CourseScheduleCacheMeta?> readMeta() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return CourseScheduleCacheMeta.fromJson(data);
  }

  @override
  Future<void> saveMeta(CourseScheduleCacheMeta meta) async {
    final Box<String> box = await _openBox();
    await box.put(_metaKey, jsonEncode(meta.toJson()));
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_key);
    await box.delete(_metaKey);
  }
}

class InMemoryCourseScheduleStorage implements CourseScheduleStorage {
  CourseScheduleData? _cache;
  CourseScheduleCacheMeta? _meta;

  @override
  Future<CourseScheduleData?> read() async => _cache;

  @override
  Future<void> save(CourseScheduleData data) async {
    _cache = data;
  }

  @override
  Future<CourseScheduleCacheMeta?> readMeta() async => _meta;

  @override
  Future<void> saveMeta(CourseScheduleCacheMeta meta) async {
    _meta = meta;
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _meta = null;
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
  CourseScheduleCacheMeta? _cachedMeta;
  Completer<void>? _readyCompleter;
  Future<void>? _pendingPersist;

  Future<CourseScheduleData?> getCourseSchedule({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && _cached != null) {
      return _cached;
    }
    _cached = await _storage.read();
    return _cached;
  }

  Future<CourseScheduleCacheMeta?> getMeta({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && _cachedMeta != null) {
      return _cachedMeta;
    }
    _cachedMeta = await _storage.readMeta();
    return _cachedMeta;
  }

  /// 仅从本地存储加载缓存，不触发网络请求。
  Future<void> warmUp() async {
    try {
      final CourseScheduleData? data = await _storage.read();
      final CourseScheduleCacheMeta? meta = await _storage.readMeta();
      if (data == null && meta == null) {
        return;
      }
      _saveCache(data: data, meta: meta, persist: false);
    } catch (error, stackTrace) {
      _completeLoadError(error, stackTrace);
      rethrow;
    }
  }

  /// 确保缓存数据已加载。
  /// 
  /// 如果缓存数据未加载，则会保持挂起状态，直到数据加载完成或出错。
  Future<void> ensureLoaded() async{
    if (_cached != null && _cachedMeta != null) {
      return;
    }
    if (_readyCompleter != null) {
      return _readyCompleter!.future;
    }
    _readyCompleter = Completer<void>();
    return _readyCompleter!.future;
  }

  void _completeReady() {
    if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
      _readyCompleter!.complete();
    }
  }

  void _completeLoadError(Object error, [StackTrace? stackTrace]) {
    if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
      _readyCompleter!.completeError(error, stackTrace);
    }
    _readyCompleter = null;
  }

  Future<CourseScheduleData> _fetchAndSave({
    required DateTime now,
    required Future<CourseScheduleData> Function() fetcher,
    String? termKey,
  }) async {
    final CourseScheduleData fetched = await fetcher();
    final CourseScheduleCacheMeta meta = CourseScheduleCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
      termKey: termKey,
    );
    _saveCache(data: fetched, meta: meta, persist: true);
    return fetched;
  }

  Future<CourseScheduleData> fetchAndSave({
    required DateTime now,
    required Future<CourseScheduleData> Function() fetcher,
    String? termKey,
  }) {
    return _fetchAndSave(
      now: now,
      fetcher: fetcher,
      termKey: termKey,
    );
  }

  /// 缓存数据到内存或者本地存储。
  /// 
  /// 如果 [persist] 为 `true`，则会额外将数据持久化到本地存储。
  void _saveCache({
    CourseScheduleData? data,
    CourseScheduleCacheMeta? meta,
    required bool persist,
  }) {
    if (data != null) {
      _cached = data;
    }
    if (meta != null) {
      _cachedMeta = meta;
    }
    _completeReady();
    if (!persist || _cached == null || _cachedMeta == null) {
      return;
    }
    _queuePersist(_cached!, _cachedMeta!);
  }

  /// 异步将缓存数据持久化到本地存储。
  /// 
  /// 后续可通过 [flush] 方法等待所有持久化任务完成或处理错误。
  Future<void> _queuePersist(
    CourseScheduleData data,
    CourseScheduleCacheMeta meta,
  ) {
    final Future<void> task = Future.wait([
      _storage.save(data),
      _storage.saveMeta(meta),
    ]).then((_) => null);
    _pendingPersist = (_pendingPersist ?? Future.value()).then((_) => task);
    return _pendingPersist!;
  }

  Future<void> flush() {
    return _pendingPersist ?? Future.value();
  }

  /// 获取课程表数据（推荐）
  /// 
  /// 如果缓存中没有数据，或者缓存数据过期，
  /// 则会从 [fetcher] 中获取数据，并缓存到 [_storage] 中。
  Future<CourseScheduleData> getOrFetch({
    required DateTime now,
    required Future<CourseScheduleData> Function() fetcher,
    String? termKey,
    Duration ttl = const Duration(days: 7),
  }) async {
    final CourseScheduleData? cached = _cached;
    final CourseScheduleCacheMeta? meta = _cachedMeta;
    bool shouldFetch = cached == null;
    if (!shouldFetch) {
      if (termKey != null && termKey.isNotEmpty && meta?.termKey != termKey) {
        shouldFetch = true;
      } else if (meta == null || meta.lastFetchedAtMillis <= 0) {
        shouldFetch = true;
      } else {
        final DateTime lastFetched =
            DateTime.fromMillisecondsSinceEpoch(meta.lastFetchedAtMillis);
        if (now.difference(lastFetched) >= ttl) {
          shouldFetch = true;
        }
      }
    }
    if (!shouldFetch) {
      return cached!;
    }
    return _fetchAndSave(
      now: now,
      termKey: termKey,
      fetcher: fetcher,
    );
  }

  Future<void> saveCourseSchedule(CourseScheduleData data) async {
    _saveCache(data: data, persist: true);
  }

  Future<void> saveFromNetDataList(
    List<CourseScheduleItemNetData> list,
  ) async {
    await saveCourseSchedule(CourseScheduleData.fromNetDataList(list));
  }

  Future<void> clearCourseSchedule() async {
    await flush();
    _pendingPersist = null;
    _cached = null;
    _cachedMeta = null;
    _readyCompleter = null;
    await _storage.clear();
  }

  Future<void> saveMeta(CourseScheduleCacheMeta meta) async {
    _saveCache(meta: meta, persist: true);
  }
}
