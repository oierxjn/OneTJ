import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/data/school_calendar_net_data.dart';

class SchoolCalendarItemData {
  const SchoolCalendarItemData({
    required this.id,
    required this.year,
    required this.term,
    required this.beginDay,
    required this.endDay,
    required this.weekNum,
    required this.weekBeginDay,
    required this.createdAt,
    required this.updatedAt,
    required this.deleteFlag,
  });

  final int id;
  final int year;
  final int term;
  final int beginDay;
  final int endDay;
  final int weekNum;
  final int weekBeginDay;
  final String? createdAt;
  final String? updatedAt;
  final int? deleteFlag;

  factory SchoolCalendarItemData.fromNetData(SchoolCalendarItemNetData data) {
    return SchoolCalendarItemData(
      id: data.id,
      year: data.year,
      term: data.term,
      beginDay: data.beginDay,
      endDay: data.endDay,
      weekNum: data.weekNum,
      weekBeginDay: data.weekBeginDay,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deleteFlag: data.deleteFlag,
    );
  }

  factory SchoolCalendarItemData.fromJson(Map<String, dynamic> json) {
    return SchoolCalendarItemData(
      id: json['id'] as int,
      year: json['year'] as int,
      term: json['term'] as int,
      beginDay: json['beginDay'] as int,
      endDay: json['endDay'] as int,
      weekNum: json['weekNum'] as int,
      weekBeginDay: json['weekBeginDay'] as int,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      deleteFlag: json['deleteFlag'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'term': term,
      'beginDay': beginDay,
      'endDay': endDay,
      'weekNum': weekNum,
      'weekBeginDay': weekBeginDay,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deleteFlag': deleteFlag,
    };
  }
}

class SchoolCalendarData {
  const SchoolCalendarData({
    required this.schoolCalendar,
    required this.week,
    required this.simpleName,
    required this.now,
    required this.name,
  });

  final SchoolCalendarItemData schoolCalendar;
  final int week;
  final String simpleName;
  final String now;
  final String name;

  factory SchoolCalendarData.fromNetData(SchoolCalendarNetData data) {
    return SchoolCalendarData(
      schoolCalendar: SchoolCalendarItemData.fromNetData(data.schoolCalendar),
      week: data.week,
      simpleName: data.simpleName,
      now: data.now,
      name: data.name,
    );
  }

  factory SchoolCalendarData.fromJson(Map<String, dynamic> json) {
    return SchoolCalendarData(
      schoolCalendar: SchoolCalendarItemData.fromJson(
        json['schoolCalendar'] as Map<String, dynamic>,
      ),
      week: json['week'] as int,
      simpleName: json['simpleName'] as String,
      now: json['now'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolCalendar': schoolCalendar.toJson(),
      'week': week,
      'simpleName': simpleName,
      'now': now,
      'name': name,
    };
  }
}

abstract class SchoolCalendarStorage {
  Future<SchoolCalendarData?> read();
  Future<void> save(SchoolCalendarData data);
  Future<void> clear();
}

class HiveSchoolCalendarStorage implements SchoolCalendarStorage {
  HiveSchoolCalendarStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'school_calendar';
  static const String _key = 'payload';
  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<SchoolCalendarData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return SchoolCalendarData.fromJson(data);
  }

  @override
  Future<void> save(SchoolCalendarData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_key);
  }
}

class InMemorySchoolCalendarStorage implements SchoolCalendarStorage {
  SchoolCalendarData? _cache;

  @override
  Future<SchoolCalendarData?> read() async => _cache;

  @override
  Future<void> save(SchoolCalendarData data) async {
    _cache = data;
  }

  @override
  Future<void> clear() async {
    _cache = null;
  }
}

class SchoolCalendarRepository {
  SchoolCalendarRepository._({required SchoolCalendarStorage storage}) : _storage = storage;

  static SchoolCalendarRepository? _instance;

  static SchoolCalendarRepository getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    final SchoolCalendarRepository repo = SchoolCalendarRepository._(
      storage: HiveSchoolCalendarStorage(),
    );
    _instance = repo;
    return repo;
  }

  final SchoolCalendarStorage _storage;
  SchoolCalendarData? _cached;

  Future<SchoolCalendarData?> getSchoolCalendar({bool refreshFromStorage = false}) async {
    if (!refreshFromStorage && _cached != null) {
      return _cached;
    }
    _cached = await _storage.read();
    return _cached;
  }

  Future<void> saveSchoolCalendar(SchoolCalendarData data) async {
    _cached = data;
    await _storage.save(data);
  }

  Future<void> saveFromNetData(SchoolCalendarNetData data) async {
    await saveSchoolCalendar(SchoolCalendarData.fromNetData(data));
  }

  Future<void> clearSchoolCalendar() async {
    _cached = null;
    await _storage.clear();
  }
}
