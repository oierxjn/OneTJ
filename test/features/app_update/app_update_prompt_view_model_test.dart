import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/app_update/models/event.dart';
import 'package:onetj/features/app_update/view_models/app_update_prompt_view_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/services/app_update_service.dart';

void main() {
  group('AppUpdatePromptViewModel.skipVersion', () {
    test('returns true and resets state when skip succeeds', () async {
      final TestPromptAppUpdateService service = TestPromptAppUpdateService(
        onSkipVersion: (_) async {},
      );
      final AppUpdatePromptViewModel viewModel = AppUpdatePromptViewModel(
        appUpdateService: service,
      );

      final bool result = await viewModel.skipVersion('v2.4.2');

      expect(result, isTrue);
      expect(viewModel.skipping, isFalse);
      expect(service.skippedVersions, <String>['v2.4.2']);
    });

    test('emits failed event and resets state when skip throws', () async {
      final Object error = Exception('skip failed');
      final TestPromptAppUpdateService service = TestPromptAppUpdateService(
        onSkipVersion: (_) async => throw error,
      );
      final AppUpdatePromptViewModel viewModel = AppUpdatePromptViewModel(
        appUpdateService: service,
      );

      final Future<UiEvent> nextEvent = viewModel.events.first;
      final bool result = await viewModel.skipVersion('v2.4.2');
      final UiEvent event = await nextEvent;

      expect(result, isFalse);
      expect(event, isA<AppUpdateSkipVersionFailedEvent>());
      expect((event as AppUpdateSkipVersionFailedEvent).error, same(error));
      expect(viewModel.skipping, isFalse);
      expect(service.skippedVersions, <String>['v2.4.2']);
    });

    test('ignores repeated skip request while skipping', () async {
      final Completer<void> completer = Completer<void>();
      final TestPromptAppUpdateService service = TestPromptAppUpdateService(
        onSkipVersion: (_) => completer.future,
      );
      final AppUpdatePromptViewModel viewModel = AppUpdatePromptViewModel(
        appUpdateService: service,
      );

      final Future<bool> first = viewModel.skipVersion('v2.4.2');
      await Future<void>.delayed(Duration.zero);
      final Future<bool> second = viewModel.skipVersion('v2.4.2');

      expect(viewModel.skipping, isTrue);
      expect(service.skippedVersions, <String>['v2.4.2']);

      completer.complete();

      expect(await first, isTrue);
      expect(await second, isFalse);
      expect(viewModel.skipping, isFalse);
      expect(service.skippedVersions, <String>['v2.4.2']);
    });
  });
}

typedef SkipVersionHandler = Future<void> Function(String versionTag);

class TestPromptAppUpdateService implements AppUpdateService {
  TestPromptAppUpdateService({
    this.onSkipVersion,
  });

  final SkipVersionHandler? onSkipVersion;
  final List<String> skippedVersions = <String>[];

  @override
  Future<void> skipVersion(String versionTag) async {
    skippedVersions.add(versionTag);
    await onSkipVersion?.call(versionTag);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
