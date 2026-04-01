import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/app_update/models/event.dart';
import 'package:onetj/features/app_update/view_models/app_update_migration_view_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/services/external_launcher_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppUpdateMigrationViewModel.downloadNow', () {
    test('emits failed event when external launch fails', () async {
      final TestExternalLauncherService launcher = TestExternalLauncherService(
        onOpenExternalUrl: (_) async => ExternalUrlLaunchResult.failed,
      );
      final AppUpdateMigrationViewModel viewModel =
          AppUpdateMigrationViewModel(
        externalLauncherService: launcher,
      );

      final Future<UiEvent> nextEvent = viewModel.events.first;
      await viewModel.downloadNow('https://example.com/update.apk');
      final UiEvent event = await nextEvent;

      expect(event, isA<AppUpdateMigrationDownloadOpenFailedEvent>());
      expect(
        (event as AppUpdateMigrationDownloadOpenFailedEvent).url,
        'https://example.com/update.apk',
      );
      expect(viewModel.opening, isFalse);
      expect(launcher.openCount, 1);
    });

    test('ignores repeated download request while opening', () async {
      final Completer<ExternalUrlLaunchResult> completer =
          Completer<ExternalUrlLaunchResult>();
      final TestExternalLauncherService launcher = TestExternalLauncherService(
        onOpenExternalUrl: (_) => completer.future,
      );
      final AppUpdateMigrationViewModel viewModel =
          AppUpdateMigrationViewModel(
        externalLauncherService: launcher,
      );

      final Future<void> first = viewModel.downloadNow(
        'https://example.com/update.apk',
      );
      await Future<void>.delayed(Duration.zero);
      final Future<void> second = viewModel.downloadNow(
        'https://example.com/update.apk',
      );

      expect(viewModel.opening, isTrue);
      expect(launcher.openCount, 1);

      completer.complete(ExternalUrlLaunchResult.launched);
      await Future.wait(<Future<void>>[first, second]);

      expect(viewModel.opening, isFalse);
      expect(launcher.openCount, 1);
    });
  });

  group('AppUpdateMigrationViewModel.copyLink', () {
    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('emits copied event when clipboard write succeeds', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          return null;
        }
        return null;
      });
      final AppUpdateMigrationViewModel viewModel =
          AppUpdateMigrationViewModel();

      final Future<UiEvent> nextEvent = viewModel.events.first;
      await viewModel.copyLink('https://example.com/update.apk');
      final UiEvent event = await nextEvent;

      expect(event, isA<AppUpdateMigrationLinkCopiedEvent>());
      expect(viewModel.copying, isFalse);
    });

    test('emits copy failed event when clipboard write throws', () async {
      final PlatformException error = PlatformException(code: 'clipboard-failed');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          throw error;
        }
        return null;
      });
      final AppUpdateMigrationViewModel viewModel =
          AppUpdateMigrationViewModel();

      final Future<UiEvent> nextEvent = viewModel.events.first;
      await viewModel.copyLink('https://example.com/update.apk');
      final UiEvent event = await nextEvent;

      expect(event, isA<AppUpdateMigrationLinkCopyFailedEvent>());
      expect((event as AppUpdateMigrationLinkCopyFailedEvent).error, same(error));
      expect(viewModel.copying, isFalse);
    });
  });
}

typedef OpenExternalUrlHandler = Future<ExternalUrlLaunchResult> Function(
  String url,
);

class TestExternalLauncherService extends ExternalLauncherService {
  TestExternalLauncherService({
    this.onOpenExternalUrl,
  });

  final OpenExternalUrlHandler? onOpenExternalUrl;
  int openCount = 0;

  @override
  Future<ExternalUrlLaunchResult> openExternalUrl(String url) async {
    openCount += 1;
    return await onOpenExternalUrl?.call(url) ??
        ExternalUrlLaunchResult.launched;
  }
}
