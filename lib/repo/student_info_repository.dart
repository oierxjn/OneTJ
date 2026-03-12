import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:onetj/models/data/student_info_net_data.dart';
import 'package:onetj/repo/base_cached_repository.dart';

class StudentInfoData extends BaseData {
  const StudentInfoData({
    required this.campusCode,
    this.campusName,
    required this.createTime,
    required this.currentGrade,
    required this.deptCode,
    required this.deptName,
    required this.enrolDate,
    required this.expGraduationDate,
    this.isIncumbencyCode,
    this.isIncumbencyName,
    required this.isMembershipCode,
    required this.isMembershipName,
    required this.isOverseasCode,
    required this.isOverseasName,
    required this.leaveSchoolCode,
    required this.leaveSchoolName,
    required this.lengthSchooling,
    this.managementCollege2Code,
    this.managementCollege2Name,
    required this.name,
    this.offSchool,
    required this.politicalStatusCode,
    required this.politicalStatusName,
    required this.registrationStatusCode,
    required this.registrationStatusName,
    required this.schoolCode,
    required this.schoolName,
    required this.secondDeptCode,
    required this.secondDeptName,
    required this.sexCode,
    required this.sexName,
    required this.statusCode,
    required this.statusName,
    required this.teacherId,
    required this.trainingCategoryCode,
    required this.trainingCategoryName,
    required this.trainingLevelCode,
    required this.trainingLevelName,
    required this.updateTime,
    required this.userId,
    required this.userTypeCode,
    required this.userTypeName,
    this.viceTeacherId,
  });

  final String campusCode;
  final String? campusName;
  final String createTime;
  final int currentGrade;
  final String deptCode;
  final String deptName;
  final String enrolDate;
  final String expGraduationDate;
  final String? isIncumbencyCode;
  final String? isIncumbencyName;
  final String isMembershipCode;
  final String isMembershipName;
  final String isOverseasCode;
  final String isOverseasName;
  final String leaveSchoolCode;
  final String leaveSchoolName;
  final String lengthSchooling;
  final String? managementCollege2Code;
  final String? managementCollege2Name;
  final String name;
  final String? offSchool;
  final String politicalStatusCode;
  final String politicalStatusName;
  final String registrationStatusCode;
  final String registrationStatusName;
  final String schoolCode;
  final String schoolName;
  final String secondDeptCode;
  final String secondDeptName;
  final String sexCode;
  final String sexName;
  final String statusCode;
  final String statusName;
  final String teacherId;
  final String trainingCategoryCode;
  final String trainingCategoryName;
  final String trainingLevelCode;
  final String trainingLevelName;
  final String updateTime;
  final String userId;
  final String userTypeCode;
  final String userTypeName;
  final String? viceTeacherId;

  factory StudentInfoData.fromNetData(StudentInfoNetData data) {
    return StudentInfoData(
      campusCode: data.campusCode,
      campusName: data.campusName,
      createTime: data.createTime,
      currentGrade: data.currentGrade,
      deptCode: data.deptCode,
      deptName: data.deptName,
      enrolDate: data.enrolDate,
      expGraduationDate: data.expGraduationDate,
      isIncumbencyCode: data.isIncumbencyCode,
      isIncumbencyName: data.isIncumbencyName,
      isMembershipCode: data.isMembershipCode,
      isMembershipName: data.isMembershipName,
      isOverseasCode: data.isOverseasCode,
      isOverseasName: data.isOverseasName,
      leaveSchoolCode: data.leaveSchoolCode,
      leaveSchoolName: data.leaveSchoolName,
      lengthSchooling: data.lengthSchooling,
      managementCollege2Code: data.managementCollege2Code,
      managementCollege2Name: data.managementCollege2Name,
      name: data.name,
      offSchool: data.offSchool,
      politicalStatusCode: data.politicalStatusCode,
      politicalStatusName: data.politicalStatusName,
      registrationStatusCode: data.registrationStatusCode,
      registrationStatusName: data.registrationStatusName,
      schoolCode: data.schoolCode,
      schoolName: data.schoolName,
      secondDeptCode: data.secondDeptCode,
      secondDeptName: data.secondDeptName,
      sexCode: data.sexCode,
      sexName: data.sexName,
      statusCode: data.statusCode,
      statusName: data.statusName,
      teacherId: data.teacherId,
      trainingCategoryCode: data.trainingCategoryCode,
      trainingCategoryName: data.trainingCategoryName,
      trainingLevelCode: data.trainingLevelCode,
      trainingLevelName: data.trainingLevelName,
      updateTime: data.updateTime,
      userId: data.userId,
      userTypeCode: data.userTypeCode,
      userTypeName: data.userTypeName,
      viceTeacherId: data.viceTeacherId,
    );
  }

  factory StudentInfoData.fromJson(Map<String, dynamic> json) {
    final Object? rawCurrentGrade = json['currentGrade'];
    final int currentGrade = rawCurrentGrade is int
        ? rawCurrentGrade
        : int.parse(rawCurrentGrade as String);
    return StudentInfoData(
      campusCode: json['campusCode'] as String,
      campusName: json['campusName'] as String?,
      createTime: json['createTime'] as String,
      currentGrade: currentGrade,
      deptCode: json['deptCode'] as String,
      deptName: json['deptName'] as String,
      enrolDate: json['enrolDate'] as String,
      expGraduationDate: json['expGraduationDate'] as String,
      isIncumbencyCode: json['isIncumbencyCode'] as String?,
      isIncumbencyName: json['isIncumbencyName'] as String?,
      isMembershipCode: json['isMembershipCode'] as String,
      isMembershipName: json['isMembershipName'] as String,
      isOverseasCode: json['isOverseasCode'] as String,
      isOverseasName: json['isOverseasName'] as String,
      leaveSchoolCode: json['leaveSchoolCode'] as String,
      leaveSchoolName: json['leaveSchoolName'] as String,
      lengthSchooling: json['lengthSchooling'] as String,
      managementCollege2Code: json['managementCollege2Code'] as String?,
      managementCollege2Name: json['managementCollege2Name'] as String?,
      name: json['name'] as String,
      offSchool: json['offSchool'] as String?,
      politicalStatusCode: json['politicalStatusCode'] as String,
      politicalStatusName: json['politicalStatusName'] as String,
      registrationStatusCode: json['registrationStatusCode'] as String,
      registrationStatusName: json['registrationStatusName'] as String,
      schoolCode: json['schoolCode'] as String,
      schoolName: json['schoolName'] as String,
      secondDeptCode: json['secondDeptCode'] as String,
      secondDeptName: json['secondDeptName'] as String,
      sexCode: json['sexCode'] as String,
      sexName: json['sexName'] as String,
      statusCode: json['statusCode'] as String,
      statusName: json['statusName'] as String,
      teacherId: json['teacherId'] as String,
      trainingCategoryCode: json['trainingCategoryCode'] as String,
      trainingCategoryName: json['trainingCategoryName'] as String,
      trainingLevelCode: json['trainingLevelCode'] as String,
      trainingLevelName: json['trainingLevelName'] as String,
      updateTime: json['updateTime'] as String,
      userId: json['userId'] as String,
      userTypeCode: json['userTypeCode'] as String,
      userTypeName: json['userTypeName'] as String,
      viceTeacherId: json['viceTeacherId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'campusCode': campusCode,
      'campusName': campusName,
      'createTime': createTime,
      'currentGrade': currentGrade,
      'deptCode': deptCode,
      'deptName': deptName,
      'enrolDate': enrolDate,
      'expGraduationDate': expGraduationDate,
      'isIncumbencyCode': isIncumbencyCode,
      'isIncumbencyName': isIncumbencyName,
      'isMembershipCode': isMembershipCode,
      'isMembershipName': isMembershipName,
      'isOverseasCode': isOverseasCode,
      'isOverseasName': isOverseasName,
      'leaveSchoolCode': leaveSchoolCode,
      'leaveSchoolName': leaveSchoolName,
      'lengthSchooling': lengthSchooling,
      'managementCollege2Code': managementCollege2Code,
      'managementCollege2Name': managementCollege2Name,
      'name': name,
      'offSchool': offSchool,
      'politicalStatusCode': politicalStatusCode,
      'politicalStatusName': politicalStatusName,
      'registrationStatusCode': registrationStatusCode,
      'registrationStatusName': registrationStatusName,
      'schoolCode': schoolCode,
      'schoolName': schoolName,
      'secondDeptCode': secondDeptCode,
      'secondDeptName': secondDeptName,
      'sexCode': sexCode,
      'sexName': sexName,
      'statusCode': statusCode,
      'statusName': statusName,
      'teacherId': teacherId,
      'trainingCategoryCode': trainingCategoryCode,
      'trainingCategoryName': trainingCategoryName,
      'trainingLevelCode': trainingLevelCode,
      'trainingLevelName': trainingLevelName,
      'updateTime': updateTime,
      'userId': userId,
      'userTypeCode': userTypeCode,
      'userTypeName': userTypeName,
      'viceTeacherId': viceTeacherId,
    };
  }
}

class StudentInfoCacheMeta extends BaseMeta {
  const StudentInfoCacheMeta({
    required super.lastFetchedAtMillis,
    this.versionKey,
  }) : super();

  final String? versionKey;

  factory StudentInfoCacheMeta.fromJson(Map<String, dynamic> json) {
    return StudentInfoCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
      versionKey: json['versionKey'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'lastFetchedAtMillis': lastFetchedAtMillis,
      'versionKey': versionKey,
    };
  }
}

abstract class StudentInfoStorage
    extends CacheStorage<StudentInfoData, StudentInfoCacheMeta> {}

class HiveStudentInfoStorage implements StudentInfoStorage {
  HiveStudentInfoStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'student_info';
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
  Future<StudentInfoData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return StudentInfoData.fromJson(data);
  }

  @override
  Future<void> save(StudentInfoData info) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(info.toJson()));
  }

  @override
  Future<StudentInfoCacheMeta?> readMeta() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return StudentInfoCacheMeta.fromJson(data);
  }

  @override
  Future<void> saveMeta(StudentInfoCacheMeta meta) async {
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

class InMemoryStudentInfoStorage implements StudentInfoStorage {
  StudentInfoData? _cache;
  StudentInfoCacheMeta? _metaCache;

  @override
  Future<StudentInfoData?> read() async => _cache;

  @override
  Future<StudentInfoCacheMeta?> readMeta() async => _metaCache;

  @override
  Future<void> save(StudentInfoData info) async {
    _cache = info;
  }

  @override
  Future<void> saveMeta(StudentInfoCacheMeta meta) async {
    _metaCache = meta;
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _metaCache = null;
  }
}

class StudentInfoRepository extends BaseNetCachedRepository<StudentInfoData,
    StudentInfoCacheMeta, StudentInfoStorage> {
  StudentInfoRepository._({
    required StudentInfoStorage storage,
  }) : super(storage);

  static StudentInfoRepository? _instance;

  static StudentInfoRepository getInstance({
    StudentInfoStorage? storage,
  }) {
    if (_instance != null) {
      return _instance!;
    }
    final StudentInfoRepository repo = StudentInfoRepository._(
      storage: storage ?? HiveStudentInfoStorage(),
    );
    _instance = repo;
    return repo;
  }

  @visibleForTesting
  static void resetInstanceForTest() {
    _instance = null;
  }

  String? _pendingVersionKey;

  @override
  StudentInfoCacheMeta buildMeta(DateTime now) {
    return StudentInfoCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
      versionKey: _pendingVersionKey,
    );
  }

  @override
  bool shouldFetch({
    required DateTime now,
    required Duration ttl,
    required StudentInfoData? cached,
    required StudentInfoCacheMeta? meta,
  }) {
    final bool shouldFetchByBase = super.shouldFetch(
      now: now,
      ttl: ttl,
      cached: cached,
      meta: meta,
    );
    if (shouldFetchByBase) {
      return true;
    }
    final String? versionKey = _pendingVersionKey;
    if (versionKey != null &&
        versionKey.isNotEmpty &&
        meta?.versionKey != versionKey) {
      return true;
    }
    return false;
  }

  Future<StudentInfoData?> getCached({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedData != null) {
      return cachedData;
    }
    return readDataFromStorage();
  }

  Future<StudentInfoCacheMeta?> getCachedMeta({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedMeta != null) {
      return cachedMeta;
    }
    return readMetaFromStorage();
  }

  @override
  Future<StudentInfoData> getOrFetch({
    required DateTime now,
    required Future<StudentInfoData> Function() fetcher,
    String? versionKey,
    Duration ttl = const Duration(days: 7),
  }) async {
    _pendingVersionKey =
        (versionKey != null && versionKey.isNotEmpty) ? versionKey : null;
    try {
      return await super.getOrFetch(
        now: now,
        fetcher: fetcher,
        ttl: ttl,
      );
    } finally {
      _pendingVersionKey = null;
    }
  }
}
