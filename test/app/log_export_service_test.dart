import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/logging/file_log_sink.dart';
import 'package:onetj/app/logging/log_export_result.dart';
import 'package:onetj/app/logging/log_export_service.dart';
import 'package:onetj/app/logging/log_file_info.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('log_export_service_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (
      MethodCall methodCall,
    ) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return tempDir.path;
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) {
      await _deleteTempDir(tempDir);
    }
  });

  group('AppLogExportService', () {
    test('exports log file via saveFile target path', () async {
      final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
      final AppLogFileInfo fileInfo = await _createLogFile(
        tempDir: tempDir,
        contents: 'save-file export',
      );
      final String chosenPath = p.join(tempDir.path, 'picked', fileInfo.name);
      final AppLogExportService service = AppLogExportService(
        fileSink: sink,
        filePicker: _FakeLogFilePicker(saveFilePath: chosenPath),
        supportDirectoryProvider: () async => tempDir,
      );

      final AppLogExportResult? result = await service.exportLogFile(fileInfo);

      expect(result, isNotNull);
      expect(result!.method, AppLogExportMethod.saveFile);
      expect(result.path, chosenPath);
      expect(
          await File(result.path).readAsString(), contains('save-file export'));
    });

    test('falls back to directory picker when saveFile is unsupported',
        () async {
      final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
      final AppLogFileInfo fileInfo = await _createLogFile(
        tempDir: tempDir,
        contents: 'directory export',
      );
      final String selectedDirectory = p.join(tempDir.path, 'selected-dir');
      final AppLogExportService service = AppLogExportService(
        fileSink: sink,
        filePicker: _FakeLogFilePicker(
          saveFileError: MissingPluginException('saveFile'),
          directoryPath: selectedDirectory,
        ),
        supportDirectoryProvider: () async => tempDir,
      );

      final AppLogExportResult? result = await service.exportLogFile(fileInfo);

      expect(result, isNotNull);
      expect(result!.method, AppLogExportMethod.directoryPicker);
      expect(result.path, p.join(selectedDirectory, fileInfo.name));
      expect(
          await File(result.path).readAsString(), contains('directory export'));
    });

    test('falls back to app export directory when pickers are unsupported',
        () async {
      final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
      final AppLogFileInfo fileInfo = await _createLogFile(
        tempDir: tempDir,
        contents: 'fallback export',
      );
      final AppLogExportService service = AppLogExportService(
        fileSink: sink,
        filePicker: _FakeLogFilePicker(
          saveFileError: MissingPluginException('saveFile'),
          directoryError: MissingPluginException('getDirectoryPath'),
        ),
        supportDirectoryProvider: () async => tempDir,
      );

      final AppLogExportResult? result = await service.exportLogFile(fileInfo);

      expect(result, isNotNull);
      expect(result!.method, AppLogExportMethod.appFallback);
      expect(
        result.path,
        p.join(tempDir.path, 'exports', 'logs', fileInfo.name),
      );
      expect(
          await File(result.path).readAsString(), contains('fallback export'));
    });

    test('renames destination when target already exists', () async {
      final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
      final AppLogFileInfo fileInfo = await _createLogFile(
        tempDir: tempDir,
        contents: 'renamed export',
      );
      final String chosenPath = p.join(tempDir.path, 'picked', fileInfo.name);
      await Directory(p.dirname(chosenPath)).create(recursive: true);
      await File(chosenPath).writeAsString('existing file');
      final AppLogExportService service = AppLogExportService(
        fileSink: sink,
        filePicker: _FakeLogFilePicker(saveFilePath: chosenPath),
        supportDirectoryProvider: () async => tempDir,
      );

      final AppLogExportResult? result = await service.exportLogFile(fileInfo);

      expect(result, isNotNull);
      expect(result!.path, isNot(chosenPath));
      expect(p.extension(result.path), '.log');
      expect(
          await File(result.path).readAsString(), contains('renamed export'));
      expect(await File(chosenPath).readAsString(), 'existing file');
    });

    test('rejects log files outside log directory', () async {
      final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
      await sink.init();
      final Directory outsideDir = Directory(p.join(tempDir.path, 'outside'));
      await outsideDir.create(recursive: true);
      final String name = '[OneTJ]-${_dateKey(DateTime.now())}.log';
      await File(p.join(outsideDir.path, name)).writeAsString('outside');
      final AppLogExportService service = AppLogExportService(
        fileSink: sink,
        filePicker: _FakeLogFilePicker(
          saveFilePath: p.join(tempDir.path, 'picked', name),
        ),
        supportDirectoryProvider: () async => tempDir,
      );

      expect(
        () => service.exportLogFile(
          AppLogFileInfo(
            name: name,
            path: p.join(outsideDir.path, name),
            date: DateTime.now(),
            sizeBytes: 7,
            isCurrent: false,
          ),
        ),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}

Future<void> _deleteTempDir(Directory directory) async {
  for (int attempt = 0; attempt < 5; attempt += 1) {
    try {
      await directory.delete(recursive: true);
      return;
    } on FileSystemException {
      if (attempt == 4) {
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}

Future<AppLogFileInfo> _createLogFile({
  required Directory tempDir,
  required String contents,
}) async {
  final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
  final Directory logDir = Directory(p.join(tempDir.path, 'logs'));
  await logDir.create(recursive: true);
  final DateTime now = DateTime.now();
  final String name = '[OneTJ]-${_dateKey(now)}.log';
  final File file = File(p.join(logDir.path, name));
  await file.writeAsString(contents);
  await sink.init();
  return AppLogFileInfo(
    name: name,
    path: file.path,
    date: DateTime(now.year, now.month, now.day),
    sizeBytes: contents.length,
    isCurrent: true,
  );
}

String _dateKey(DateTime dateTime) {
  final String yyyy = dateTime.year.toString().padLeft(4, '0');
  final String mm = dateTime.month.toString().padLeft(2, '0');
  final String dd = dateTime.day.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd';
}

class _FakeLogFilePicker implements AppLogFilePicker {
  const _FakeLogFilePicker({
    this.saveFilePath,
    this.directoryPath,
    this.saveFileError,
    this.directoryError,
  });

  final String? saveFilePath;
  final String? directoryPath;
  final Object? saveFileError;
  final Object? directoryError;

  @override
  Future<String?> getDirectoryPath() async {
    if (directoryError != null) {
      throw directoryError!;
    }
    return directoryPath;
  }

  @override
  Future<String?> saveFile({required String fileName}) async {
    if (saveFileError != null) {
      throw saveFileError!;
    }
    return saveFilePath;
  }
}
