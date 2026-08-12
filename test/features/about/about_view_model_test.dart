import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/about/view_models/about_view_model.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/services/app_update_service.dart';

void main() {
  group('AboutViewModel.checkForUpdateManually', () {
    test('emits already latest event and resets loading state', () async {
      final Completer<AppUpdateCheckResult> completer =
          Completer<AppUpdateCheckResult>();
      final TestAppUpdateService service = TestAppUpdateService(
        onCheckForUpdate: ({required bool force}) => completer.future,
      );
      final AboutViewModel viewModel =
          AboutViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      final Future<void> action = viewModel.checkForUpdateManually();

      expect(viewModel.isCheckingUpdate, isTrue);

      completer.complete(
        const AppUpdateCheckResult(
          checked: true,
          hasUpdate: false,
        ),
      );

      final UiEvent event = await nextEvent;
      await action;

      expect(event, isA<AppUpdateAlreadyLatestEvent>());
      expect(viewModel.isCheckingUpdate, isFalse);
    });

    test('emits update available event for manual check', () async {
      const AppUpdateInfo updateInfo = AppUpdateInfo(
        latestVersion: '2.3.0',
        latestBuild: 12,
        releaseNotes: 'notes',
        publishedAt: null,
        mandatory: false,
        downloadUrl: 'https://example.com/onetj.exe',
        sha256: '',
        fileSize: null,
        minSupportedVersion: null,
      );
      final TestAppUpdateService service = TestAppUpdateService(
        onCheckForUpdate: ({required bool force}) async =>
            const AppUpdateCheckResult(
          checked: true,
          hasUpdate: true,
          updateInfo: updateInfo,
        ),
      );
      final AboutViewModel viewModel =
          AboutViewModel(appUpdateService: service);

      final UiEvent eventFuture = await (() async {
        final Future<UiEvent> nextEvent = viewModel.events.first;
        await viewModel.checkForUpdateManually();
        return await nextEvent;
      })();

      expect(eventFuture, isA<AppUpdateAvailableEvent>());
      final AppUpdateAvailableEvent event =
          eventFuture as AppUpdateAvailableEvent;
      expect(event.updateInfo, same(updateInfo));
      expect(event.fromManualCheck, isTrue);
      expect(viewModel.isCheckingUpdate, isFalse);
    });

    test('emits failed event when manual check throws', () async {
      final Object error = Exception('network failed');
      final TestAppUpdateService service = TestAppUpdateService(
        onCheckForUpdate: ({required bool force}) async => throw error,
      );
      final AboutViewModel viewModel =
          AboutViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      await viewModel.checkForUpdateManually();
      final UiEvent event = await nextEvent;

      expect(event, isA<AppUpdateFailedEvent>());
      expect((event as AppUpdateFailedEvent).error, same(error));
      expect(viewModel.isCheckingUpdate, isFalse);
      expect(service.loggedErrors, hasLength(1));
    });
  });
}

typedef CheckForUpdateHandler = Future<AppUpdateCheckResult> Function(
    {required bool force});

class TestAppUpdateService implements AppUpdateService {
  TestAppUpdateService({
    this.onCheckForUpdate,
  });

  final CheckForUpdateHandler? onCheckForUpdate;
  final List<Object> loggedErrors = <Object>[];

  @override
  Future<AppUpdateCheckResult> checkForUpdate({
    bool force = false,
    Duration throttleWindow = const Duration(hours: 24),
  }) async {
    return onCheckForUpdate?.call(force: force) ??
        const AppUpdateCheckResult(checked: true, hasUpdate: false);
  }

  @override
  String formatReleaseNotes(AppUpdateInfo info) {
    return info.releaseNotes;
  }

  @override
  void logUpdateFailure(Object error, StackTrace stackTrace) {
    loggedErrors.add(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
