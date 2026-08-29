import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/timetable/application/timetable_data_service.dart';
import 'package:onetj/features/timetable/models/event.dart';
import 'package:onetj/features/timetable/view_models/timetable_view_model.dart';
import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';

void main() {
  setUp(() {
    appLocator.registerSingleton<SettingsRepository>(
      SettingsRepository(storage: InMemorySettingsStorage()),
    );
    appLocator.registerSingleton<SchoolCalendarRepository>(
      SchoolCalendarRepository(storage: InMemorySchoolCalendarStorage()),
    );
    appLocator.registerSingleton<CourseScheduleRepository>(
      CourseScheduleRepository(storage: InMemoryCourseScheduleStorage()),
    );
  });

  tearDown(() async {
    await resetDependencies();
  });

  group('TimetableViewModel.load 滚轮同步时机', () {
    test('仅在加载完成、滚轮可渲染后发出 SyncWheelEvent', () async {
      final TimetableViewModel viewModel = TimetableViewModel(
        dataService: _FakeTimetableDataService(
          index: _buildIndex(entryCount: 1),
        ),
      );

      final List<UiEvent> events = <UiEvent>[];
      final List<bool> loadingAtEmit = <bool>[];
      viewModel.events.listen((UiEvent event) {
        events.add(event);
        loadingAtEmit.add(viewModel.isLoading);
      });

      await viewModel.load();
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      final List<SyncWheelEvent> syncEvents =
          events.whereType<SyncWheelEvent>().toList();
      expect(syncEvents, hasLength(1));
      final int syncIndex = events.indexOf(syncEvents.single);
      expect(syncIndex, isNot(-1));
      expect(loadingAtEmit[syncIndex], isFalse);

      viewModel.dispose();
    });

    test('课表为空时不发出 SyncWheelEvent', () async {
      final TimetableViewModel viewModel = TimetableViewModel(
        dataService: _FakeTimetableDataService(
          index: _buildIndex(entryCount: 0),
        ),
      );

      final List<UiEvent> events = <UiEvent>[];
      viewModel.events.listen(events.add);

      await viewModel.load();
      await pumpEventQueue();

      expect(events.whereType<SyncWheelEvent>(), isEmpty);

      viewModel.dispose();
    });

    test('课表加载失败时不发出 SyncWheelEvent', () async {
      final TimetableViewModel viewModel = TimetableViewModel(
        dataService: _FakeTimetableDataService(
          error: Exception('timetable load failed'),
        ),
      );

      final List<UiEvent> events = <UiEvent>[];
      viewModel.events.listen(events.add);

      await viewModel.load();
      await pumpEventQueue();

      expect(events.whereType<SyncWheelEvent>(), isEmpty);
      expect(events.whereType<ShowSnackBarEvent>(), isNotEmpty);

      viewModel.dispose();
    });
  });
}

TimetableIndex _buildIndex({required int entryCount}) {
  return TimetableIndex(
    byDayOfWeek: const <int, List<TimetableEntry>>{},
    byWeekThenDay: const <int, Map<int, List<TimetableEntry>>>{},
    allEntries: List<TimetableEntry>.generate(entryCount, _buildEntry),
    nonTimetableItems: const <CourseScheduleItemData>[],
    sourceData: const CourseScheduleData(items: <CourseScheduleItemData>[]),
  );
}

TimetableEntry _buildEntry(int index) {
  return TimetableEntry(
    courseName: 'Course $index',
    courseCode: 'C$index',
    classCode: 'CL$index',
    className: 'Class $index',
    teacherName: 'Teacher',
    campus: 'Campus',
    campusI18n: 'Campus',
    roomId: 'R',
    roomIdI18n: 'R',
    roomLabel: 'R',
    dayOfWeek: 1,
    timeStart: 1,
    timeEnd: 1,
    weeks: const <int>[1],
    weekNum: '1',
    teachingClassId: null,
    sourceItemIndex: index,
    sourceTimeTableIndex: 0,
  );
}

class _FakeTimetableDataService extends TimetableDataService {
  _FakeTimetableDataService({this.index, this.error});

  final TimetableIndex? index;
  final Object? error;

  @override
  Future<int> getSchoolCalendarCurrentWeek() async => 5;

  @override
  Future<TimetableIndex> getTimetableIndex() async {
    final Object? thrownError = error;
    if (thrownError != null) {
      throw thrownError;
    }
    return index!;
  }

  @override
  Future<DateTime?> getLastFetchedAt() async => null;
}