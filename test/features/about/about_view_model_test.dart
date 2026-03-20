import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/about/view_models/about_view_model.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/services/app_update_service.dart';

void main() {
  group('AboutViewModel.checkForUpdateManually', () {
    test('emits already latest event and resets loading state', () async {
      final Completer<AppUpdateCheckResult> completer =
          Completer<AppUpdateCheckResult>();
      final TestAppUpdateService service = TestAppUpdateService(
        onCheckForUpdate: ({required bool force}) => completer.future,
      );
      final AboutViewModel viewModel = AboutViewModel(appUpdateService: service);

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
      final AboutViewModel viewModel = AboutViewModel(appUpdateService: service);

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
      final AboutViewModel viewModel = AboutViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      await viewModel.checkForUpdateManually();
      final UiEvent event = await nextEvent;

      expect(event, isA<AppUpdateFailedEvent>());
      expect((event as AppUpdateFailedEvent).error, same(error));
      expect(viewModel.isCheckingUpdate, isFalse);
      expect(service.loggedErrors, hasLength(1));
    });
  });

  group('AboutViewModel.downloadAndInstallUpdate', () {
    test('emits install triggered event and resets installing state', () async {
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
      final File file = File('fake-installer.exe');
      final Completer<File> completer = Completer<File>();
      final TestAppUpdateService service = TestAppUpdateService(
        onDownloadPackage: (info) => completer.future,
        onInstallPackage: (downloadedFile) async {
          expect(downloadedFile.path, file.path);
        },
      );
      final AboutViewModel viewModel = AboutViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      final Future<void> action = viewModel.downloadAndInstallUpdate(updateInfo);

      expect(viewModel.isInstallingUpdate, isTrue);

      completer.complete(file);

      final UiEvent event = await nextEvent;
      await action;

      expect(event, isA<AppUpdateInstallTriggeredEvent>());
      expect(viewModel.isInstallingUpdate, isFalse);
    });

    test('emits failed event when install throws', () async {
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
      final Object error = Exception('install failed');
      final TestAppUpdateService service = TestAppUpdateService(
        onDownloadPackage: (info) async => File('fake-installer.exe'),
        onInstallPackage: (downloadedFile) async => throw error,
      );
      final AboutViewModel viewModel = AboutViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      await viewModel.downloadAndInstallUpdate(updateInfo);
      final UiEvent event = await nextEvent;

      expect(event, isA<AppUpdateFailedEvent>());
      expect((event as AppUpdateFailedEvent).error, same(error));
      expect(viewModel.isInstallingUpdate, isFalse);
      expect(service.loggedErrors, hasLength(1));
    });
  });
}

typedef CheckForUpdateHandler =
    Future<AppUpdateCheckResult> Function({required bool force});
typedef DownloadPackageHandler = Future<File> Function(AppUpdateInfo info);
typedef InstallPackageHandler = Future<void> Function(File file);

class TestAppUpdateService implements AppUpdateService {
  TestAppUpdateService({
    this.onCheckForUpdate,
    this.onDownloadPackage,
    this.onInstallPackage,
  });

  final CheckForUpdateHandler? onCheckForUpdate;
  final DownloadPackageHandler? onDownloadPackage;
  final InstallPackageHandler? onInstallPackage;
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
  Future<File> downloadPackage(
    AppUpdateInfo info, {
    void Function(int receivedBytes, int? totalBytes)? onProgress,
  }) async {
    return onDownloadPackage?.call(info) ?? File('default-installer.exe');
  }

  @override
  String formatReleaseNotes(AppUpdateInfo info) {
    return info.releaseNotes;
  }

  @override
  Future<void> installPackage(File file) async {
    await onInstallPackage?.call(file);
  }

  @override
  void logUpdateFailure(Object error, StackTrace stackTrace) {
    loggedErrors.add(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
