import 'package:flutter_test/flutter_test.dart';

import 'dart:async';

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

  group('TimetableViewModel.refresh 强制刷新', () {
    test('成功后更新索引、lastFetchedAt 并发出 SyncWheelEvent', () async {
      final Completer<void> gate = Completer<void>();
      final _FakeTimetableDataService dataService = _FakeTimetableDataService(
        index: _buildIndex(entryCount: 1),
        refreshIndex: _buildIndex(entryCount: 2),
        refreshGate: gate,
        lastFetchedAt: DateTime(2026, 9, 19, 12),
      );
      final TimetableViewModel viewModel = TimetableViewModel(
        dataService: dataService,
      );

      final List<UiEvent> events = <UiEvent>[];
      viewModel.events.listen(events.add);
      await viewModel.load();
      // 事件经广播流异步投递，先排空 load 阶段的事件再清空列表。
      await pumpEventQueue();
      events.clear();

      final Future<bool> refreshing = viewModel.refresh();
      expect(viewModel.isRefreshing, isTrue);
      gate.complete();
      final bool success = await refreshing;
      await pumpEventQueue();

      expect(success, isTrue);
      expect(viewModel.isRefreshing, isFalse);
      expect(viewModel.index!.allEntries, hasLength(2));
      expect(viewModel.lastFetchedAt, DateTime(2026, 9, 19, 12));
      expect(events.whereType<SyncWheelEvent>(), hasLength(1));
      // 选中周在刷新后仍然有效则保留
      viewModel.selectWeek(3);
      final Completer<void> gate2 = Completer<void>();
      dataService.refreshGate = gate2;
      final Future<bool> refreshing2 = viewModel.refresh();
      gate2.complete();
      await refreshing2;
      expect(viewModel.selectedWeek, 3);

      viewModel.dispose();
    });

    test('失败时保留旧索引并通过 SnackBar 提示', () async {
      final TimetableViewModel viewModel = TimetableViewModel(
        dataService: _FakeTimetableDataService(
          index: _buildIndex(entryCount: 1),
          refreshError: Exception('refresh boom'),
        ),
      );

      final List<UiEvent> events = <UiEvent>[];
      viewModel.events.listen(events.add);
      await viewModel.load();
      await pumpEventQueue();
      events.clear();

      final bool success = await viewModel.refresh();
      await pumpEventQueue();

      expect(success, isFalse);
      expect(viewModel.isRefreshing, isFalse);
      expect(viewModel.index!.allEntries, hasLength(1));
      expect(events.whereType<ShowSnackBarEvent>(), hasLength(1));
      expect(events.whereType<SyncWheelEvent>(), isEmpty);

      viewModel.dispose();
    });

    test('刷新进行中重复调用为 no-op', () async {
      final Completer<void> gate = Completer<void>();
      final _FakeTimetableDataService dataService = _FakeTimetableDataService(
        index: _buildIndex(entryCount: 1),
        refreshIndex: _buildIndex(entryCount: 2),
        refreshGate: gate,
      );
      final TimetableViewModel viewModel = TimetableViewModel(
        dataService: dataService,
      );
      await viewModel.load();

      final Future<bool> first = viewModel.refresh();
      final bool second = await viewModel.refresh();
      expect(second, isFalse);
      expect(dataService.refreshCallCount, 1);

      gate.complete();
      expect(await first, isTrue);
      expect(dataService.refreshCallCount, 1);

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
  _FakeTimetableDataService({
    this.index,
    this.error,
    this.refreshIndex,
    this.refreshError,
    Completer<void>? refreshGate,
    this.lastFetchedAt,
  }) : _refreshGate = refreshGate;

  final TimetableIndex? index;
  final Object? error;
  final TimetableIndex? refreshIndex;
  final Object? refreshError;
  DateTime? lastFetchedAt;

  Completer<void>? _refreshGate;
  // ignore: avoid_setters_without_getters
  set refreshGate(Completer<void>? value) => _refreshGate = value;
  int refreshCallCount = 0;

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
  Future<TimetableIndex> refreshTimetableIndex() async {
    refreshCallCount += 1;
    final Completer<void>? gate = _refreshGate;
    if (gate != null) {
      await gate.future;
    }
    final Object? thrownError = refreshError;
    if (thrownError != null) {
      throw thrownError;
    }
    return refreshIndex ?? index!;
  }

  @override
  Future<DateTime?> getLastFetchedAt() async => lastFetchedAt;
}
