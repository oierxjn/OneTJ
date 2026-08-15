import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/student_exam_data.dart';
import 'package:onetj/repo/base_cached_repository.dart';

abstract class StudentExamStorage
    extends CacheStorage<StudentExamData, StudentExamCacheMeta> {}

class StudentExamCacheMeta extends BaseMeta {
  const StudentExamCacheMeta({required super.lastFetchedAtMillis}) : super();

  factory StudentExamCacheMeta.fromJson(Map<String, dynamic> json) {
    return StudentExamCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'lastFetchedAtMillis': lastFetchedAtMillis};
  }
}

class HiveStudentExamStorage implements StudentExamStorage {
  HiveStudentExamStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'student_exams';
  static const String _dataKey = 'payload';
  static const String _metaKey = 'meta';

  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<StudentExamData?> read() async {
    final String? raw = (await _openBox()).get(_dataKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return StudentExamData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(StudentExamData data) async {
    await (await _openBox()).put(_dataKey, jsonEncode(data.toJson()));
  }

  @override
  Future<StudentExamCacheMeta?> readMeta() async {
    final String? raw = (await _openBox()).get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return StudentExamCacheMeta.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveMeta(StudentExamCacheMeta meta) async {
    await (await _openBox()).put(_metaKey, jsonEncode(meta.toJson()));
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_dataKey);
    await box.delete(_metaKey);
  }
}

class InMemoryStudentExamStorage implements StudentExamStorage {
  StudentExamData? _data;
  StudentExamCacheMeta? _meta;

  @override
  Future<StudentExamData?> read() async => _data;

  @override
  Future<void> save(StudentExamData data) async {
    _data = data;
  }

  @override
  Future<StudentExamCacheMeta?> readMeta() async => _meta;

  @override
  Future<void> saveMeta(StudentExamCacheMeta meta) async {
    _meta = meta;
  }

  @override
  Future<void> clear() async {
    _data = null;
    _meta = null;
  }
}

class StudentExamRepository extends BaseNetCachedRepository<StudentExamData,
    StudentExamCacheMeta, StudentExamStorage> {
  StudentExamRepository({StudentExamStorage? storage})
      : super(storage ?? HiveStudentExamStorage());

  @override
  StudentExamCacheMeta buildMeta(
    DateTime now,
    StudentExamData data, {
    String? requestKey,
  }) {
    return StudentExamCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
    );
  }

  Future<StudentExamData?> getCached({bool refreshFromStorage = false}) async {
    if (!refreshFromStorage && cachedData != null) {
      return cachedData;
    }
    return readDataFromStorage();
  }

  Future<StudentExamCacheMeta?> getCachedMeta({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && cachedMeta != null) {
      return cachedMeta;
    }
    return readMetaFromStorage();
  }
}
