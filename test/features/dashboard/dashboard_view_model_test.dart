import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/app_update_info.dart';
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

  group('DashboardViewModel.downloadAndInstallUpdate', () {
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

    test('emits install triggered event when install succeeds', () async {
      final File file = File('fake-installer.exe');
      final TestDashboardAppUpdateService service =
          TestDashboardAppUpdateService(
        onDownloadPackage: (_) async => file,
        onInstallPackage: (_) async => AppUpdateInstallResult.installerStarted,
      );
      final DashboardViewModel viewModel =
          DashboardViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      await viewModel.downloadAndInstallUpdate(updateInfo);
      final UiEvent event = await nextEvent;

      expect(event, isA<AppUpdateInstallTriggeredEvent>());
      viewModel.dispose();
    });

    test('emits permission required event when install needs permission',
        () async {
      final File file = File('fake-installer.apk');
      final TestDashboardAppUpdateService service =
          TestDashboardAppUpdateService(
        onDownloadPackage: (_) async => file,
        onInstallPackage: (_) async =>
            AppUpdateInstallResult.permissionRequired,
      );
      final DashboardViewModel viewModel =
          DashboardViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      await viewModel.downloadAndInstallUpdate(updateInfo);
      final UiEvent event = await nextEvent;

      expect(event, isA<AppUpdateInstallPermissionRequiredEvent>());
      viewModel.dispose();
    });

    test('emits failed event when download or install throws', () async {
      final Object error = Exception('download failed');
      final TestDashboardAppUpdateService service =
          TestDashboardAppUpdateService(
        onDownloadPackage: (_) async => throw error,
      );
      final DashboardViewModel viewModel =
          DashboardViewModel(appUpdateService: service);

      final Future<UiEvent> nextEvent = viewModel.events.first;
      await viewModel.downloadAndInstallUpdate(updateInfo);
      final UiEvent event = await nextEvent;

      expect(event, isA<AppUpdateFailedEvent>());
      expect((event as AppUpdateFailedEvent).error, same(error));
      expect(service.loggedErrors, <Object>[error]);
      viewModel.dispose();
    });
  });
}

typedef SkipVersionHandler = Future<void> Function(String versionTag);
typedef DownloadPackageHandler = Future<File> Function(AppUpdateInfo info);
typedef InstallPackageHandler = Future<AppUpdateInstallResult> Function(
  File file,
);

class TestDashboardAppUpdateService implements AppUpdateService {
  TestDashboardAppUpdateService({
    this.onSkipVersion,
    this.onDownloadPackage,
    this.onInstallPackage,
  });

  final SkipVersionHandler? onSkipVersion;
  final DownloadPackageHandler? onDownloadPackage;
  final InstallPackageHandler? onInstallPackage;
  final List<String> skippedVersions = <String>[];
  final List<Object> loggedErrors = <Object>[];

  @override
  Future<void> skipVersion(String versionTag) async {
    skippedVersions.add(versionTag);
    await onSkipVersion?.call(versionTag);
  }

  @override
  Future<File> downloadPackage(
    AppUpdateInfo info, {
    void Function(int receivedBytes, int? totalBytes)? onProgress,
  }) async {
    return onDownloadPackage?.call(info) ?? File('default-installer.exe');
  }

  @override
  Future<AppUpdateInstallResult> installPackage(File file) async {
    return onInstallPackage?.call(file) ??
        AppUpdateInstallResult.installerStarted;
  }

  @override
  void logUpdateFailure(Object error, StackTrace stackTrace) {
    loggedErrors.add(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
