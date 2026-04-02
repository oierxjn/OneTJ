import 'dart:io';

import 'package:onetj/app/logging/log_file_info.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AppFileLogSink {
  static final AppFileLogSink instance = AppFileLogSink();

  AppFileLogSink({
    this.prefix = '[OneTJ]',
    this.retainDays = 7,
  }) : assert(retainDays > 0);

  final String prefix;
  final int retainDays;

  Directory? _logDir;
  File? _currentFile;
  String? _currentDateKey;
  bool _initialized = false;
  Future<void>? _initFuture;
  bool _degraded = false;
  Future<void> _writeChain = Future<void>.value();

  /// 初始化日志文件接收器。
  ///
  /// 确保应用程序支持目录存在，并创建日志目录。
  /// 如果初始化过程中发生错误，则不会进行日志文件操作
  Future<void> init() async {
    if (_initialized) {
      return;
    }
    final Future<void>? pending = _initFuture;
    if (pending != null) {
      await pending;
      return;
    }
    final Future<void> task = _doInit();
    _initFuture = task;
    try {
      await task;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _doInit() async {
    if (_initialized) {
      return;
    }
    try {
      final Directory supportDirectory = await getApplicationSupportDirectory();
      final Directory logDir =
          Directory(path.join(supportDirectory.path, 'logs'));
      await logDir.create(recursive: true);
      _logDir = logDir;
      await _rotateIfNeeded(now: DateTime.now());
      await cleanupOldFiles();
      _initialized = true;
    } catch (error) {
      _degrade(error, StackTrace.current);
    }
  }

  Future<String?> currentLogFilePath() async {
    await init();
    return _currentFile?.path;
  }

  Future<Directory?> logDirectory() async {
    await init();
    return _logDir;
  }

  Future<List<AppLogFileInfo>> listLogFiles() async {
    await init();
    if (_degraded) {
      return const <AppLogFileInfo>[];
    }
    final Directory? logDir = _logDir;
    if (logDir == null || !await logDir.exists()) {
      return const <AppLogFileInfo>[];
    }
    final List<FileSystemEntity> entities = await logDir.list().toList();
    final List<AppLogFileInfo> files = <AppLogFileInfo>[];
    for (final FileSystemEntity entity in entities) {
      if (entity is! File) {
        continue;
      }
      final String name = path.basename(entity.path);
      final DateTime? date = _parseLogDate(name);
      if (date == null) {
        continue;
      }
      final FileStat stat = await entity.stat();
      files.add(
        AppLogFileInfo(
          name: name,
          path: entity.path,
          date: date,
          sizeBytes: stat.size,
          isCurrent: _currentDateKey == _formatDateKey(date),
        ),
      );
    }
    files.sort((a, b) {
      final int dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return b.name.compareTo(a.name);
    });
    return files;
  }

  Future<String> readLogFile(String filePath) async {
    await init();
    final File file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Log file not found', filePath);
    }
    return file.readAsString();
  }

  Future<void> writeLine(String line) async {
    _writeChain = _writeChain.then((_) => _writeLineSerial(line));
    await _writeChain;
  }

  /// 清理旧的日志文件。
  ///
  /// 删除日志目录中早于指定保留天数的日志文件。
  /// 如果清理过程中发生错误，则不会进行日志文件操作
  Future<void> cleanupOldFiles() async {
    if (_degraded) {
      return;
    }
    try {
      final Directory? logDir = _logDir;
      if (logDir == null || !await logDir.exists()) {
        return;
      }
      final DateTime threshold = DateTime.now().subtract(
        Duration(days: retainDays),
      );
      final List<FileSystemEntity> entities = await logDir.list().toList();
      for (final FileSystemEntity entity in entities) {
        if (entity is! File) {
          continue;
        }
        final String base = path.basename(entity.path);
        final DateTime? parsedDate = _parseLogDate(base);
        if (parsedDate == null) {
          await entity.delete();
          continue;
        }
        if (parsedDate.isBefore(
            DateTime(threshold.year, threshold.month, threshold.day))) {
          await entity.delete();
        }
      }
    } catch (error) {
      _degrade(error, StackTrace.current);
    }
  }

  Future<void> _writeLineSerial(String line) async {
    if (_degraded) {
      return;
    }
    try {
      await init();
      if (_degraded) {
        return;
      }
      await _rotateIfNeeded(now: DateTime.now());
      final File? file = _currentFile;
      if (file == null) {
        return;
      }
      await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    } catch (error) {
      _degrade(error, StackTrace.current);
    }
  }

  /// 如果日期键不同，则旋转日志文件。
  ///
  /// 检查当前日期键是否与提供的日期键不同。
  /// 如果不同，则创建一个新的日志文件并更新当前日期键。
  Future<void> _rotateIfNeeded({required DateTime now}) async {
    final Directory? logDir = _logDir;
    if (logDir == null) {
      return;
    }
    final String nextDateKey = _formatDateKey(now);
    if (_currentFile != null && _currentDateKey == nextDateKey) {
      return;
    }
    final String filename = '$prefix-$nextDateKey.log';
    _currentFile = File(path.join(logDir.path, filename));
    _currentDateKey = nextDateKey;
  }

  DateTime? _parseLogDate(String baseName) {
    final String expectedPrefix = '$prefix-';
    if (!baseName.startsWith(expectedPrefix) || !baseName.endsWith('.log')) {
      return null;
    }
    final String datePart = baseName.substring(
      expectedPrefix.length,
      baseName.length - 4,
    );
    final List<String> parts = datePart.split('-');
    if (parts.length != 3) {
      return null;
    }
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }

  String _formatDateKey(DateTime time) {
    final String yyyy = time.year.toString().padLeft(4, '0');
    final String mm = time.month.toString().padLeft(2, '0');
    final String dd = time.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  void _degrade(Object error, StackTrace stackTrace) {
    if (_degraded) {
      return;
    }
    _degraded = true;
    stderr.writeln('[ONETJ] file log sink degraded: $error');
    stderr.writeln(stackTrace);
  }
}
