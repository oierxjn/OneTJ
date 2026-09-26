import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/repo/school_calendar_repository.dart';

class TermKeyResolver {
  TermKeyResolver({
    required SchoolCalendarRepository calendarRepository,
    required CourseScheduleRepository scheduleRepository,
  })  : _calendarRepository = calendarRepository,
        _scheduleRepository = scheduleRepository;

  final SchoolCalendarRepository _calendarRepository;
  final CourseScheduleRepository _scheduleRepository;

  Future<String?> resolveCurrentTermKey({
    required DateTime now,
    required Future<SchoolCalendarData> Function() fetchSchoolCalendar,
  }) async {
    try {
      await _calendarRepository.warmUp();
      final SchoolCalendarData calendar = await _calendarRepository.getOrFetch(
        now: now,
        fetcher: fetchSchoolCalendar,
      );
      return formatTermKey(calendar);
    } catch (_) {
      await _scheduleRepository.warmUp();
      final CourseScheduleCacheMeta? meta =
          await _scheduleRepository.getCachedMeta(refreshFromStorage: false);
      return meta?.termKey;
    }
  }

  static String formatTermKey(SchoolCalendarData calendar) {
    return '${calendar.schoolCalendar.year}-${calendar.schoolCalendar.term}';
  }
}
