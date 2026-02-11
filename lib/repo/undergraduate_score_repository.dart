import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/data/undergraduate_score_net_data.dart';

class UndergraduateScoreCreditInfoData {
  const UndergraduateScoreCreditInfoData({
    this.id,
    this.year,
    this.term,
    this.calName,
    this.calendarId,
    this.studentId,
    this.studentName,
    this.courseNum,
    this.courseCode,
    this.courseName,
    this.scoreName,
    this.scoreRecordType,
    this.scoreExamType,
    this.score,
    this.gradePoint,
    this.isPass,
    this.isPassName,
    this.scoreNatureName,
    this.scoreExamTypeI18n,
    this.courseNature,
    this.courseLabel,
    this.courseLabName,
    this.courseType,
    this.credit,
    this.couresType,
    this.examMode,
    this.publicCoursesType,
    this.publicCoursesName,
    this.updateTime,
    this.createdPerson,
    this.createdTime,
    this.importUserCode,
    this.keepField,
    this.oldData,
    this.scoreLabel,
    this.realAgainExamScore,
    this.teachingClassId,
    this.scoreSourrce,
  });

  final int? id;
  final String? year;
  final int? term;
  final String? calName;
  final int? calendarId;
  final String? studentId;
  final String? studentName;
  final String? courseNum;
  final String? courseCode;
  final String? courseName;
  final String? scoreName;
  final int? scoreRecordType;
  final int? scoreExamType;
  final String? score;
  final int? gradePoint;
  final int? isPass;
  final String? isPassName;
  final String? scoreNatureName;
  final String? scoreExamTypeI18n;
  final String? courseNature;
  final String? courseLabel;
  final String? courseLabName;
  final String? courseType;
  final int? credit;
  final String? couresType;
  final String? examMode;
  final String? publicCoursesType;
  final String? publicCoursesName;
  final String? updateTime;
  final String? createdPerson;
  final String? createdTime;
  final String? importUserCode;
  final String? keepField;
  final int? oldData;
  final String? scoreLabel;
  final String? realAgainExamScore;
  final String? teachingClassId;
  final int? scoreSourrce;

  factory UndergraduateScoreCreditInfoData.fromNetData(
    UndergraduateScoreCreditInfoNetData data,
  ) {
    return UndergraduateScoreCreditInfoData(
      id: data.id,
      year: data.year,
      term: data.term,
      calName: data.calName,
      calendarId: data.calendarId,
      studentId: data.studentId,
      studentName: data.studentName,
      courseNum: data.courseNum,
      courseCode: data.courseCode,
      courseName: data.courseName,
      scoreName: data.scoreName,
      scoreRecordType: data.scoreRecordType,
      scoreExamType: data.scoreExamType,
      score: data.score,
      gradePoint: data.gradePoint,
      isPass: data.isPass,
      isPassName: data.isPassName,
      scoreNatureName: data.scoreNatureName,
      scoreExamTypeI18n: data.scoreExamTypeI18n,
      courseNature: data.courseNature,
      courseLabel: data.courseLabel,
      courseLabName: data.courseLabName,
      courseType: data.courseType,
      credit: data.credit,
      couresType: data.couresType,
      examMode: data.examMode,
      publicCoursesType: data.publicCoursesType,
      publicCoursesName: data.publicCoursesName,
      updateTime: data.updateTime,
      createdPerson: data.createdPerson,
      createdTime: data.createdTime,
      importUserCode: data.importUserCode,
      keepField: data.keepField,
      oldData: data.oldData,
      scoreLabel: data.scoreLabel,
      realAgainExamScore: data.realAgainExamScore,
      teachingClassId: data.teachingClassId,
      scoreSourrce: data.scoreSourrce,
    );
  }

  factory UndergraduateScoreCreditInfoData.fromJson(Map<String, dynamic> json) {
    return UndergraduateScoreCreditInfoData(
      id: json['id'] as int?,
      year: json['year'] as String?,
      term: json['term'] as int?,
      calName: json['calName'] as String?,
      calendarId: json['calendarId'] as int?,
      studentId: json['studentId'] as String?,
      studentName: json['studentName'] as String?,
      courseNum: json['courseNum'] as String?,
      courseCode: json['courseCode'] as String?,
      courseName: json['courseName'] as String?,
      scoreName: json['scoreName'] as String?,
      scoreRecordType: json['scoreRecordType'] as int?,
      scoreExamType: json['scoreExamType'] as int?,
      score: json['score'] as String?,
      gradePoint: json['gradePoint'] as int?,
      isPass: json['isPass'] as int?,
      isPassName: json['isPassName'] as String?,
      scoreNatureName: json['scoreNatureName'] as String?,
      scoreExamTypeI18n: json['scoreExamTypeI18n'] as String?,
      courseNature: json['courseNature'] as String?,
      courseLabel: json['courseLabel'] as String?,
      courseLabName: json['courseLabName'] as String?,
      courseType: json['courseType'] as String?,
      credit: json['credit'] as int?,
      couresType: json['couresType'] as String?,
      examMode: json['examMode'] as String?,
      publicCoursesType: json['publicCoursesType'] as String?,
      publicCoursesName: json['publicCoursesName'] as String?,
      updateTime: json['updateTime'] as String?,
      createdPerson: json['createdPerson'] as String?,
      createdTime: json['createdTime'] as String?,
      importUserCode: json['importUserCode'] as String?,
      keepField: json['keepField'] as String?,
      oldData: json['oldData'] as int?,
      scoreLabel: json['scoreLabel'] as String?,
      realAgainExamScore: json['realAgainExamScore'] as String?,
      teachingClassId: json['teachingClassId'] as String?,
      scoreSourrce: json['scoreSourrce'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'term': term,
      'calName': calName,
      'calendarId': calendarId,
      'studentId': studentId,
      'studentName': studentName,
      'courseNum': courseNum,
      'courseCode': courseCode,
      'courseName': courseName,
      'scoreName': scoreName,
      'scoreRecordType': scoreRecordType,
      'scoreExamType': scoreExamType,
      'score': score,
      'gradePoint': gradePoint,
      'isPass': isPass,
      'isPassName': isPassName,
      'scoreNatureName': scoreNatureName,
      'scoreExamTypeI18n': scoreExamTypeI18n,
      'courseNature': courseNature,
      'courseLabel': courseLabel,
      'courseLabName': courseLabName,
      'courseType': courseType,
      'credit': credit,
      'couresType': couresType,
      'examMode': examMode,
      'publicCoursesType': publicCoursesType,
      'publicCoursesName': publicCoursesName,
      'updateTime': updateTime,
      'createdPerson': createdPerson,
      'createdTime': createdTime,
      'importUserCode': importUserCode,
      'keepField': keepField,
      'oldData': oldData,
      'scoreLabel': scoreLabel,
      'realAgainExamScore': realAgainExamScore,
      'teachingClassId': teachingClassId,
      'scoreSourrce': scoreSourrce,
    };
  }
}

class UndergraduateScoreTermData {
  const UndergraduateScoreTermData({
    this.termcode,
    this.termName,
    this.calName,
    this.averagePoint,
    this.creditInfo,
  });

  final String? termcode;
  final String? termName;
  final String? calName;
  final String? averagePoint;
  final List<UndergraduateScoreCreditInfoData>? creditInfo;

  factory UndergraduateScoreTermData.fromNetData(
    UndergraduateScoreTermNetData data,
  ) {
    return UndergraduateScoreTermData(
      termcode: data.termcode,
      termName: data.termName,
      calName: data.calName,
      averagePoint: data.averagePoint,
      creditInfo: data.creditInfo
          ?.map(UndergraduateScoreCreditInfoData.fromNetData)
          .toList(),
    );
  }

  factory UndergraduateScoreTermData.fromJson(Map<String, dynamic> json) {
    final Object? rawCreditInfo = json['creditInfo'];
    final List<UndergraduateScoreCreditInfoData>? creditInfo =
        rawCreditInfo is List<dynamic>
            ? rawCreditInfo
                .map((item) => UndergraduateScoreCreditInfoData.fromJson(
                      item as Map<String, dynamic>,
                    ))
                .toList()
            : null;
    return UndergraduateScoreTermData(
      termcode: json['termcode'] as String?,
      termName: json['termName'] as String?,
      calName: json['calName'] as String?,
      averagePoint: json['averagePoint'] as String?,
      creditInfo: creditInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'termcode': termcode,
      'termName': termName,
      'calName': calName,
      'averagePoint': averagePoint,
      'creditInfo': creditInfo?.map((item) => item.toJson()).toList(),
    };
  }
}

class UndergraduateScoreData {
  const UndergraduateScoreData({
    this.totalGradePoint,
    this.actualCredit,
    this.failingCredits,
    this.failingCourseCount,
    this.term,
  });

  final String? totalGradePoint;
  final String? actualCredit;
  final String? failingCredits;
  final String? failingCourseCount;
  final List<UndergraduateScoreTermData>? term;

  factory UndergraduateScoreData.fromNetData(UndergraduateScoreNetData data) {
    return UndergraduateScoreData(
      totalGradePoint: data.totalGradePoint,
      actualCredit: data.actualCredit,
      failingCredits: data.failingCredits,
      failingCourseCount: data.failingCourseCount,
      term: data.term?.map(UndergraduateScoreTermData.fromNetData).toList(),
    );
  }

  factory UndergraduateScoreData.fromJson(Map<String, dynamic> json) {
    final Object? rawTerms = json['term'];
    final List<UndergraduateScoreTermData>? term = rawTerms is List<dynamic>
        ? rawTerms
            .map((item) =>
                UndergraduateScoreTermData.fromJson(item as Map<String, dynamic>))
            .toList()
        : null;
    return UndergraduateScoreData(
      totalGradePoint: json['totalGradePoint'] as String?,
      actualCredit: json['actualCredit'] as String?,
      failingCredits: json['failingCredits'] as String?,
      failingCourseCount: json['failingCourseCount'] as String?,
      term: term,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGradePoint': totalGradePoint,
      'actualCredit': actualCredit,
      'failingCredits': failingCredits,
      'failingCourseCount': failingCourseCount,
      'term': term?.map((item) => item.toJson()).toList(),
    };
  }
}

abstract class UndergraduateScoreStorage {
  Future<UndergraduateScoreData?> read();
  Future<UndergraduateScoreCacheMeta?> readMeta();
  Future<void> save(UndergraduateScoreData data);
  Future<void> saveMeta(UndergraduateScoreCacheMeta meta);
  Future<void> clear();
}

class UndergraduateScoreCacheMeta {
  const UndergraduateScoreCacheMeta({
    required this.lastFetchedAtMillis,
    this.versionKey,
  });

  final int lastFetchedAtMillis;
  final String? versionKey;

  factory UndergraduateScoreCacheMeta.fromJson(Map<String, dynamic> json) {
    return UndergraduateScoreCacheMeta(
      lastFetchedAtMillis: json['lastFetchedAtMillis'] as int? ?? 0,
      versionKey: json['versionKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastFetchedAtMillis': lastFetchedAtMillis,
      'versionKey': versionKey,
    };
  }
}

class HiveUndergraduateScoreStorage implements UndergraduateScoreStorage {
  HiveUndergraduateScoreStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'undergraduate_score';
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
  Future<UndergraduateScoreData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return UndergraduateScoreData.fromJson(data);
  }

  @override
  Future<void> save(UndergraduateScoreData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
  }

  @override
  Future<UndergraduateScoreCacheMeta?> readMeta() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_metaKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return UndergraduateScoreCacheMeta.fromJson(data);
  }

  @override
  Future<void> saveMeta(UndergraduateScoreCacheMeta meta) async {
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

class InMemoryUndergraduateScoreStorage implements UndergraduateScoreStorage {
  UndergraduateScoreData? _cache;
  UndergraduateScoreCacheMeta? _meta;

  @override
  Future<UndergraduateScoreData?> read() async => _cache;

  @override
  Future<void> save(UndergraduateScoreData data) async {
    _cache = data;
  }

  @override
  Future<UndergraduateScoreCacheMeta?> readMeta() async => _meta;

  @override
  Future<void> saveMeta(UndergraduateScoreCacheMeta meta) async {
    _meta = meta;
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _meta = null;
  }
}

class UndergraduateScoreRepository {
  UndergraduateScoreRepository._({required UndergraduateScoreStorage storage})
      : _storage = storage;

  static UndergraduateScoreRepository? _instance;

  static UndergraduateScoreRepository getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    final UndergraduateScoreRepository repo = UndergraduateScoreRepository._(
      storage: HiveUndergraduateScoreStorage(),
    );
    _instance = repo;
    return repo;
  }

  final UndergraduateScoreStorage _storage;
  UndergraduateScoreData? _cached;
  UndergraduateScoreCacheMeta? _cachedMeta;
  Completer<void>? _readyCompleter;
  Future<void>? _pendingPersist;

  Future<UndergraduateScoreData?> getUndergraduateScore({
    bool refreshFromStorage = false,
  }) async {
    if (!refreshFromStorage && _cached != null) {
      return _cached;
    }
    _cached = await _storage.read();
    return _cached;
  }

  /// 从本地缓存预热数据
  Future<void> warmUp() async {
    try {
      final UndergraduateScoreData? data = await _storage.read();
      final UndergraduateScoreCacheMeta? meta = await _storage.readMeta();
      if (data == null && meta == null) {
        return;
      }
      _saveCache(data: data, meta: meta, persist: false);
    } catch (error, stackTrace) {
      _completeLoadError(error, stackTrace);
      rethrow;
    }
  }

  /// Waits until cache is ready
  Future<void> ensureLoaded() async {
    if (_cached != null && _cachedMeta != null) {
      return;
    }
    if (_readyCompleter != null) {
      return _readyCompleter!.future;
    }
    _readyCompleter = Completer<void>();
    return _readyCompleter!.future;
  }

  Future<UndergraduateScoreData> fetchAndSave({
    required DateTime now,
    required Future<UndergraduateScoreData> Function() fetcher,
    String? versionKey,
  }) async {
    final UndergraduateScoreData fetched = await fetcher();
    final UndergraduateScoreCacheMeta meta = UndergraduateScoreCacheMeta(
      lastFetchedAtMillis: now.millisecondsSinceEpoch,
      versionKey: versionKey,
    );
    _saveCache(data: fetched, meta: meta, persist: true);
    return fetched;
  }

  /// Returns cached data if valid, otherwise fetches and persists fresh data.
  Future<UndergraduateScoreData> getOrFetch({
    required DateTime now,
    required Future<UndergraduateScoreData> Function() fetcher,
    String? versionKey,
    Duration ttl = const Duration(days: 7),
  }) async {
    final UndergraduateScoreData? cached = _cached;
    final UndergraduateScoreCacheMeta? meta = _cachedMeta;
    bool shouldFetch = cached == null;
    if (!shouldFetch) {
      if (versionKey != null && versionKey.isNotEmpty && meta?.versionKey != versionKey) {
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
    return fetchAndSave(
      now: now,
      versionKey: versionKey,
      fetcher: fetcher,
    );
  }

  Future<void> saveUndergraduateScore(UndergraduateScoreData data) async {
    _saveCache(data: data, persist: true);
  }

  Future<void> saveMeta(UndergraduateScoreCacheMeta meta) async {
    _saveCache(meta: meta, persist: true);
  }

  Future<void> flush() {
    return _pendingPersist ?? Future.value();
  }

  Future<void> clearUndergraduateScore() async {
    await flush();
    _pendingPersist = null;
    _cached = null;
    _cachedMeta = null;
    _readyCompleter = null;
    await _storage.clear();
  }

  /// 调用此方法后将会触发[ensureLoaded]的完成
  void _saveCache({
    UndergraduateScoreData? data,
    UndergraduateScoreCacheMeta? meta,
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

  Future<void> _queuePersist(
    UndergraduateScoreData data,
    UndergraduateScoreCacheMeta meta,
  ) {
    final Future<void> task = Future.wait([
      _storage.save(data),
      _storage.saveMeta(meta),
    ]).then((_) => null);
    _pendingPersist = (_pendingPersist ?? Future.value()).then((_) => task);
    return _pendingPersist!;
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
}
