import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/logging/file_log_sink.dart';
import 'package:onetj/app/logging/log_file_info.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('file_log_sink_test_');
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
      await tempDir.delete(recursive: true);
    }
  });

  group('AppFileLogSink', () {
    test('listLogFiles returns all retained log files in descending order',
        () async {
      final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
      final Directory logDir = Directory(p.join(tempDir.path, 'logs'));
      await logDir.create(recursive: true);
      final DateTime now = DateTime.now();
      final DateTime yesterday = now.subtract(const Duration(days: 1));
      await File(
        p.join(logDir.path, '[OneTJ]-${_dateKey(yesterday)}.log'),
      ).writeAsString('yesterday');
      await File(
        p.join(logDir.path, '[OneTJ]-${_dateKey(now)}.log'),
      ).writeAsString('today');
      await File(
        p.join(logDir.path, 'random-file.txt'),
      ).writeAsString('ignored');

      await sink.init();
      final files = await sink.listLogFiles();

      expect(files, hasLength(2));
      expect(files.first.name, '[OneTJ]-${_dateKey(now)}.log');
      expect(files.first.isCurrent, isTrue);
      expect(files.first.sizeBytes, greaterThan(0));
      expect(files.last.name, '[OneTJ]-${_dateKey(yesterday)}.log');
      expect(files.last.isCurrent, isFalse);
    });

    test('readLogFile returns file content for selected log file', () async {
      final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
      final Directory logDir = Directory(p.join(tempDir.path, 'logs'));
      await logDir.create(recursive: true);
      final File file = File(
        p.join(logDir.path, '[OneTJ]-${_dateKey(DateTime.now())}.log'),
      );
      await file.writeAsString('line 1\nline 2\n');

      await sink.init();
      final files = await sink.listLogFiles();
      final content = await sink.readLogFile(files.single);

      expect(content, 'line 1\nline 2\n');
    });

    test('readLogFile rejects invalid log file names', () async {
      final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
      final Directory logDir = Directory(p.join(tempDir.path, 'logs'));
      await logDir.create(recursive: true);

      await sink.init();

      expect(
        () => sink.readLogFile(
          AppLogFileInfo(
            name: 'not-a-log.txt',
            path: p.join(logDir.path, 'not-a-log.txt'),
            date: DateTime.now(),
            sizeBytes: 0,
            isCurrent: false,
          ),
        ),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('readLogFile rejects paths outside the log directory', () async {
      final AppFileLogSink sink = AppFileLogSink(prefix: '[OneTJ]');
      final Directory logDir = Directory(p.join(tempDir.path, 'logs'));
      await logDir.create(recursive: true);
      final Directory outsideDir = Directory(p.join(tempDir.path, 'outside'));
      await outsideDir.create(recursive: true);
      final String name = '[OneTJ]-${_dateKey(DateTime.now())}.log';
      await File(p.join(outsideDir.path, name)).writeAsString('outside');

      await sink.init();

      expect(
        () => sink.readLogFile(
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

String _dateKey(DateTime dateTime) {
  final String yyyy = dateTime.year.toString().padLeft(4, '0');
  final String mm = dateTime.month.toString().padLeft(2, '0');
  final String dd = dateTime.day.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd';
}
