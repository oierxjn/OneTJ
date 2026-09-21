import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/settings/view_models/settings_view_model.dart';
import 'package:onetj/models/cet_score_data.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/settings_data.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/user_collection_field.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/theme_repository.dart';

class _FakeCetScoreDataService implements CetScoreDataService {
  @override
  Future<CetScoreData> load() async => throw UnimplementedError();

  @override
  Future<CetScoreData> refresh() async => throw UnimplementedError();

  @override
  Future<void> clearCachedData() async {}
}

/// 记录写入次数并可注入失败的存储装饰器。
class _CountingSettingsStorage implements SettingsStorage {
  _CountingSettingsStorage(this._inner);

  final SettingsStorage _inner;
  int saveCount = 0;
  Object? saveError;

  @override
  Future<SettingsData?> read() => _inner.read();

  @override
  Future<void> save(SettingsData data) async {
    saveCount += 1;
    final Object? error = saveError;
    if (error != null) {
      throw error;
    }
    await _inner.save(data);
  }

  @override
  Future<void> clear() => _inner.clear();
}

void main() {
  late InMemorySettingsStorage storage;
  late _CountingSettingsStorage countingStorage;
  late SettingsRepository settingsRepository;
  late ThemeChangeNotifier themeChangeNotifier;
  late SettingsViewModel viewModel;

  setUp(() {
    storage = InMemorySettingsStorage();
    countingStorage = _CountingSettingsStorage(storage);
    settingsRepository = SettingsRepository(storage: countingStorage);
    themeChangeNotifier = ThemeChangeNotifier(
      repository: ThemeRepository(storage: InMemoryThemeStorage()),
    );
    viewModel = SettingsViewModel(
      settingsRepository: settingsRepository,
      themeChangeNotifier: themeChangeNotifier,
      cetScoreDataService: _FakeCetScoreDataService(),
    );
  });

  tearDown(() {
    viewModel.dispose();
    themeChangeNotifier.dispose();
  });

  Future<SettingsData> readSavedSettings() =>
      settingsRepository.getSettings(refreshFromStorage: true);

  group('设置即改即存', () {
    test('时间段变更后立即写入仓库', () async {
      await viewModel.initialize();
      countingStorage.saveCount = 0;
      const List<TimePeriodRangeData> ranges = <TimePeriodRangeData>[
        TimePeriodRangeData(startMinutes: 480, endMinutes: 555),
      ];

      await viewModel.updateTimeSlotRanges(ranges);

      expect(countingStorage.saveCount, 1);
      final SettingsData saved = await readSavedSettings();
      expect(saved.timeSlotRanges.length, 1);
      expect(saved.timeSlotRanges.first.startMinutes, 480);
      expect(saved.timeSlotRanges.first.endMinutes, 555);
    });

    test('隐私采集字段变更后立即写入仓库', () async {
      await viewModel.initialize();
      const Set<UserCollectionField> fields = <UserCollectionField>{
        UserCollectionField.username,
      };

      await viewModel.updateUserCollectionFields(fields);

      final SettingsData saved = await readSavedSettings();
      expect(saved.userCollectionFields, fields);
    });

    test('桌面课程模式切换后立即写入仓库', () async {
      await viewModel.initialize();

      await viewModel.updateUpcomingMode(DashboardUpcomingMode.thisWeek);

      final SettingsData saved = await readSavedSettings();
      expect(saved.dashboardUpcomingMode, DashboardUpcomingMode.thisWeek);
      expect(saved.dashboardUpcomingCount, kDefaultDashboardUpcomingCount);
    });

    test('数量非法时切换到 count 模式沿用已存数量', () async {
      await viewModel.initialize();
      viewModel.updateDashboardUpcomingCountText('99');

      await viewModel.updateUpcomingMode(DashboardUpcomingMode.count);

      final SettingsData saved = await readSavedSettings();
      expect(saved.dashboardUpcomingMode, DashboardUpcomingMode.count);
      expect(saved.dashboardUpcomingCount, kDefaultDashboardUpcomingCount);
      expect(viewModel.isUpcomingInvalid, isTrue);
    });

    test('快速连续变更串行写入且以最新草稿为准', () async {
      await viewModel.initialize();
      const List<TimePeriodRangeData> first = <TimePeriodRangeData>[
        TimePeriodRangeData(startMinutes: 480, endMinutes: 540),
      ];
      const List<TimePeriodRangeData> second = <TimePeriodRangeData>[
        TimePeriodRangeData(startMinutes: 480, endMinutes: 555),
      ];

      await viewModel.updateTimeSlotRanges(first);
      await viewModel.updateTimeSlotRanges(second);

      expect(countingStorage.saveCount, 2);
      final SettingsData saved = await readSavedSettings();
      expect(saved.timeSlotRanges.first.endMinutes, 555);
    });

    test('最大周数失焦提交写入仓库', () async {
      await viewModel.initialize();

      viewModel.updateMaxWeekText('10');
      await viewModel.commitMaxWeekText();

      final SettingsData saved = await readSavedSettings();
      expect(saved.maxWeek, 10);
      expect(viewModel.isMaxWeekDirty, isFalse);
    });

    test('文本未变化或非法时提交不写入', () async {
      await viewModel.initialize();
      countingStorage.saveCount = 0;

      await viewModel.commitMaxWeekText();
      expect(countingStorage.saveCount, 0);

      viewModel.updateMaxWeekText('0');
      await viewModel.commitMaxWeekText();
      expect(countingStorage.saveCount, 0);

      final SettingsData saved = await readSavedSettings();
      expect(saved.maxWeek, kDefaultMaxWeek);
      expect(viewModel.isMaxWeekInvalid, isTrue);
    });

    test('数量文本失焦提交写入仓库', () async {
      await viewModel.initialize();
      await viewModel.updateUpcomingMode(DashboardUpcomingMode.count);
      countingStorage.saveCount = 0;

      viewModel.updateDashboardUpcomingCountText('5');
      await viewModel.commitDashboardUpcomingCountText();

      expect(countingStorage.saveCount, 1);
      final SettingsData saved = await readSavedSettings();
      expect(saved.dashboardUpcomingCount, 5);
    });

    test('写入失败发出错误事件且已存值保持不变', () async {
      await viewModel.initialize();
      countingStorage.saveError = Exception('disk full');
      viewModel.updateMaxWeekText('10');
      final Future<UiEvent> nextEvent = viewModel.events.first;

      await viewModel.commitMaxWeekText();

      final UiEvent event = await nextEvent;
      expect(event, isA<ShowSnackBarEvent>());
      final SettingsData saved = await readSavedSettings();
      expect(saved.maxWeek, kDefaultMaxWeek);
      expect(viewModel.isMaxWeekDirty, isTrue);
    });

    test('恢复默认后仓库与草稿同步', () async {
      await viewModel.initialize();
      viewModel.updateMaxWeekText('10');
      await viewModel.commitMaxWeekText();

      await viewModel.resetSettings();

      final SettingsData saved = await readSavedSettings();
      expect(saved.maxWeek, kDefaultMaxWeek);
      expect(viewModel.draftMaxWeekText, kDefaultMaxWeek.toString());
      expect(viewModel.isMaxWeekDirty, isFalse);
    });
  });
}
