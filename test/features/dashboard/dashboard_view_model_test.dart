import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/services/app_update_service.dart';

void main() {
  setUp(() {
    SettingsRepository.resetForTesting();
  });

  group('DashboardViewModel.skipUpdateVersion', () {
    test('returns true when skip version succeeds', () async {
      final TestDashboardAppUpdateService service =
          TestDashboardAppUpdateService(
        onSkipVersion: (_) async {},
      );
      final DashboardViewModel viewModel =
          DashboardViewModel(appUpdateService: service);

      final bool result = await viewModel.skipUpdateVersion('v2.3.0');

      expect(result, isTrue);
      expect(service.skippedVersions, <String>['v2.3.0']);
      viewModel.dispose();
    });

    test('returns false and emits failed event when skip version throws',
        () async {
      final Object error = Exception('hive write failed');
      final TestDashboardAppUpdateService service =
          TestDashboardAppUpdateService(
        onSkipVersion: (_) async => throw error,
      );
      final DashboardViewModel viewModel =
          DashboardViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      final bool result = await viewModel.skipUpdateVersion('v2.3.0');
      final UiEvent event = await nextEvent;

      expect(result, isFalse);
      expect(event, isA<AppUpdateFailedEvent>());
      expect((event as AppUpdateFailedEvent).error, same(error));
      expect(service.loggedErrors, <Object>[error]);
      viewModel.dispose();
    });
  });
}

typedef SkipVersionHandler = Future<void> Function(String versionTag);

class TestDashboardAppUpdateService implements AppUpdateService {
  TestDashboardAppUpdateService({
    this.onSkipVersion,
  });

  final SkipVersionHandler? onSkipVersion;
  final List<String> skippedVersions = <String>[];
  final List<Object> loggedErrors = <Object>[];

  @override
  Future<void> skipVersion(String versionTag) async {
    skippedVersions.add(versionTag);
    await onSkipVersion?.call(versionTag);
  }

  @override
  void logUpdateFailure(Object error, StackTrace stackTrace) {
    loggedErrors.add(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
