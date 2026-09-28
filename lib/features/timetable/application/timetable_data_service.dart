import 'package:onetj/services/tongji.dart';

import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/services/timetable_index_builder.dart';
import 'package:onetj/services/term_key_resolver.dart';
import 'package:onetj/models/timetable_index.dart';

/// 课表页所需的取数与周数能力，便于视图模型注入测试替身。
abstract interface class TimetableDataSource {
  Future<int> getSchoolCalendarCurrentWeek();
  Future<TimetableIndex> getTimetableIndex();
  Future<TimetableIndex> refreshTimetableIndex();
  Future<DateTime?> getLastFetchedAt();
}

class TimetableDataService implements TimetableDataSource {
  TimetableDataService({
    required TongjiApi api,
    required CourseScheduleRepository scheduleRepository,
    required SchoolCalendarRepository calendarRepository,
    required TermKeyResolver termKeyResolver,
    TimetableIndexBuilder indexBuilder = const TimetableIndexBuilder(),
  })  : _api = api,
        _indexBuilder = indexBuilder,
        _scheduleRepository = scheduleRepository,
        _calendarRepository = calendarRepository,
        _termKeyResolver = termKeyResolver;

  final TongjiApi _api;
  final TimetableIndexBuilder _indexBuilder;
  final CourseScheduleRepository _scheduleRepository;
  final SchoolCalendarRepository _calendarRepository;
  final TermKeyResolver _termKeyResolver;

  /// 获取当前周数
  ///
  /// 如果获取失败，抛出错误
  @override
  Future<int> getSchoolCalendarCurrentWeek() async {
    await _calendarRepository.warmUp();
    final SchoolCalendarData data = await _calendarRepository.getOrFetch(
      now: DateTime.now(),
      fetcher: _api.fetchSchoolCalendarCurrentTerm,
    );
    return data.week;
  }

  /// 获取课表索引
  ///
  /// 如果本地数据库没有数据，从服务器获取并保存
  @override
  Future<TimetableIndex> getTimetableIndex() async {
    final DateTime now = DateTime.now();
    await _scheduleRepository.warmUp();
    final String? termKey = await _termKeyResolver.resolveCurrentTermKey(
      now: now,
      fetchSchoolCalendar: _api.fetchSchoolCalendarCurrentTerm,
    );
    final CourseScheduleData data = await _scheduleRepository.getOrFetch(
      now: now,
      termKey: termKey,
      fetcher: _api.fetchStudentTimetable,
    );
    return _indexBuilder.buildIndex(data);
  }

  /// 强制刷新课表索引
  ///
  /// 绕过缓存 TTL 直接从服务器拉取课表，成功后写回缓存。
  /// 学期标识仍由 [TermKeyResolver] 解析，换学期时缓存自动失效。
  @override
  Future<TimetableIndex> refreshTimetableIndex() async {
    final DateTime now = DateTime.now();
    await _scheduleRepository.warmUp();
    final String? termKey = await _termKeyResolver.resolveCurrentTermKey(
      now: now,
      fetchSchoolCalendar: _api.fetchSchoolCalendarCurrentTerm,
    );
    final CourseScheduleData data = await _scheduleRepository.refresh(
      now: now,
      termKey: termKey,
      fetcher: _api.fetchStudentTimetable,
    );
    return _indexBuilder.buildIndex(data);
  }

  @override
  Future<DateTime?> getLastFetchedAt() async {
    final CourseScheduleCacheMeta? meta =
        await _scheduleRepository.getCachedMeta(refreshFromStorage: false);
    if (meta == null || meta.lastFetchedAtMillis <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(meta.lastFetchedAtMillis)
        .toLocal();
  }
}
