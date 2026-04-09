import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/logging/log_export_result.dart';
import 'package:onetj/app/logging/log_export_service.dart';
import 'package:onetj/app/logging/log_file_info.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/view_models/log_viewer_view_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:open_filex/open_filex.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogViewerViewModel', () {
    test('initialize loads files and first file content', () async {
      final AppLogFileInfo first = _logFile('2026-04-08');
      final AppLogFileInfo second = _logFile('2026-04-07');
      final LogViewerViewModel viewModel = LogViewerViewModel(
        listLogFiles: () async => <AppLogFileInfo>[first, second],
        readLogFile: (file) async => 'content:${file.name}',
        logExportService: _FakeLogExportService(),
      );

      await viewModel.initialize();

      final LogViewerUiState state = viewModel.uiState;
      expect(state.loadingFiles, isFalse);
      expect(state.loadingContent, isFalse);
      expect(state.files, hasLength(2));
      expect(state.selectedFile, same(first));
      expect(state.content, 'content:${first.name}');
      expect(state.filesError, isNull);
      expect(state.contentError, isNull);
    });

    test('selectFile keeps latest request result', () async {
      final AppLogFileInfo first = _logFile('2026-04-08');
      final AppLogFileInfo second = _logFile('2026-04-07');
      final Completer<String> firstRead = Completer<String>();
      int firstReadCount = 0;
      final LogViewerViewModel viewModel = LogViewerViewModel(
        listLogFiles: () async => <AppLogFileInfo>[first, second],
        readLogFile: (file) {
          if (file == first) {
            firstReadCount += 1;
            if (firstReadCount == 1) {
              return Future<String>.value('initial-first-content');
            }
            return firstRead.future;
          }
          return Future<String>.value('second-content');
        },
        logExportService: _FakeLogExportService(),
      );

      await viewModel.initialize();
      await viewModel.selectFile(second);
      firstRead.complete('stale-first-content');
      await Future<void>.delayed(Duration.zero);

      final LogViewerUiState state = viewModel.uiState;
      expect(state.selectedFile, same(second));
      expect(state.content, 'second-content');
    });

    test('exportSelectedFile emits success event', () async {
      final AppLogFileInfo first = _logFile('2026-04-08');
      final LogViewerViewModel viewModel = LogViewerViewModel(
        listLogFiles: () async => <AppLogFileInfo>[first],
        readLogFile: (_) async => 'content',
        logExportService: _FakeLogExportService(
          result: const AppLogExportResult(
            path: 'C:\\logs\\[OneTJ]-2026-04-08.log',
            method: AppLogExportMethod.saveFile,
          ),
        ),
      );
      await viewModel.initialize();
      final Future<UiEvent> eventFuture = viewModel.events.first;
      await viewModel.exportSelectedFile();

      final LogExportSucceededEvent event =
          await eventFuture as LogExportSucceededEvent;

      expect(event.path, 'C:\\logs\\[OneTJ]-2026-04-08.log');
    });

    test('exportSelectedFile emits canceled event', () async {
      final LogViewerViewModel viewModel = LogViewerViewModel(
        listLogFiles: () async => <AppLogFileInfo>[_logFile('2026-04-08')],
        readLogFile: (_) async => 'content',
        logExportService: _FakeLogExportService(result: null),
      );
      await viewModel.initialize();
      final Future<UiEvent> eventFuture = viewModel.events.first;
      await viewModel.exportSelectedFile();

      expect(await eventFuture, isA<LogExportCanceledEvent>());
    });

    test('exportSelectedFile emits failed event', () async {
      final LogViewerViewModel viewModel = LogViewerViewModel(
        listLogFiles: () async => <AppLogFileInfo>[_logFile('2026-04-08')],
        readLogFile: (_) async => 'content',
        logExportService: _FakeLogExportService(error: StateError('boom')),
      );
      await viewModel.initialize();
      final Future<UiEvent> eventFuture = viewModel.events.first;
      await viewModel.exportSelectedFile();

      final LogExportFailedEvent event =
          await eventFuture as LogExportFailedEvent;
      expect(event.message, contains('boom'));
    });

    test('openExportedFile emits success event', () async {
      final LogViewerViewModel viewModel = LogViewerViewModel(
        listLogFiles: () async => <AppLogFileInfo>[_logFile('2026-04-08')],
        readLogFile: (_) async => 'content',
        logExportService: _FakeLogExportService(),
        openFile: (_) async => OpenResult(
          type: ResultType.done,
          message: 'done',
        ),
      );

      final Future<UiEvent> eventFuture = viewModel.events.first;
      await viewModel.openExportedFile('C:\\logs\\[OneTJ]-2026-04-08.log');

      final LogOpenSucceededEvent event =
          await eventFuture as LogOpenSucceededEvent;
      expect(event.path, 'C:\\logs\\[OneTJ]-2026-04-08.log');
    });

    test('openExportedFile emits failed event for non-done result', () async {
      final LogViewerViewModel viewModel = LogViewerViewModel(
        listLogFiles: () async => <AppLogFileInfo>[_logFile('2026-04-08')],
        readLogFile: (_) async => 'content',
        logExportService: _FakeLogExportService(),
        openFile: (_) async => OpenResult(
          type: ResultType.noAppToOpen,
          message: 'no app',
        ),
      );

      final Future<UiEvent> eventFuture = viewModel.events.first;
      await viewModel.openExportedFile('C:\\logs\\[OneTJ]-2026-04-08.log');

      final LogOpenFailedEvent event = await eventFuture as LogOpenFailedEvent;
      expect(event.message, 'no app');
    });

    test('openExportedFile emits failed event for exception', () async {
      final LogViewerViewModel viewModel = LogViewerViewModel(
        listLogFiles: () async => <AppLogFileInfo>[_logFile('2026-04-08')],
        readLogFile: (_) async => 'content',
        logExportService: _FakeLogExportService(),
        openFile: (_) => Future<OpenResult>.error(StateError('open boom')),
      );

      final Future<UiEvent> eventFuture = viewModel.events.first;
      await viewModel.openExportedFile('C:\\logs\\[OneTJ]-2026-04-08.log');

      final LogOpenFailedEvent event = await eventFuture as LogOpenFailedEvent;
      expect(event.message, contains('open boom'));
    });
  });
}

AppLogFileInfo _logFile(String dateKey) {
  final DateTime date = DateTime.parse(dateKey);
  return AppLogFileInfo(
    name: '[OneTJ]-$dateKey.log',
    path: 'C:\\logs\\[OneTJ]-$dateKey.log',
    date: date,
    sizeBytes: 128,
    isCurrent: true,
  );
}

class _FakeLogExportService extends AppLogExportService {
  _FakeLogExportService({
    this.result,
    this.error,
  });

  final AppLogExportResult? result;
  final Object? error;

  @override
  Future<AppLogExportResult?> exportLogFile(AppLogFileInfo fileInfo) async {
    if (error != null) {
      throw error!;
    }
    return result;
  }
}
