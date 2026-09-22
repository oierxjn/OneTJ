import 'dart:io';

import 'package:file_picker/file_picker.dart' as standard_picker;
import 'package:file_picker_ohos/file_picker_ohos.dart' as ohos_picker;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:onetj/app/logging/file_log_sink.dart';
import 'package:onetj/app/logging/log_export_result.dart';
import 'package:onetj/app/logging/log_file_info.dart';
import 'package:onetj/app/logging/logger.dart';

typedef AppSupportDirectoryProvider = Future<Directory> Function();

abstract class AppLogFilePicker {
  Future<String?> saveFile({required String fileName});

  Future<String?> getDirectoryPath();
}

class AppPlatformLogFilePicker implements AppLogFilePicker {
  const AppPlatformLogFilePicker({String? operatingSystem})
      : _operatingSystem = operatingSystem;

  /// 测试注入用；为 null 时按真实运行平台判断。
  final String? _operatingSystem;

  /// 是否为 Android/iOS。
  ///
  /// 这两个平台使用标准 `file_picker`；其余平台（OpenHarmony 与桌面端）
  /// 使用 `file_picker_ohos`。
  bool get _isAndroidOrIos {
    if (_operatingSystem != null) {
      return _operatingSystem == 'android' || _operatingSystem == 'ios';
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Future<String?> saveFile({required String fileName}) async {
    if (_isAndroidOrIos) {
      // 标准 file_picker 在 Android/iOS 上 saveFile 必须传入 bytes 并自行写入文件，
      // 与本服务“先选路径、再复制文件”的模型不一致；这里声明不支持，
      // 让 AppLogExportService 回退到目录选择器。
      throw UnsupportedError(
        'saveFile is unsupported on Android/iOS; use getDirectoryPath',
      );
    }
    return ohos_picker.FilePicker.platform.saveFile(
      fileName: fileName,
      type: ohos_picker.FileType.custom,
      allowedExtensions: const <String>['log'],
    );
  }

  @override
  Future<String?> getDirectoryPath() {
    if (_isAndroidOrIos) {
      return standard_picker.FilePicker.getDirectoryPath();
    }
    return ohos_picker.FilePicker.platform.getDirectoryPath();
  }
}

class AppLogExportService {
  AppLogExportService({
    AppFileLogSink? fileSink,
    AppLogFilePicker? filePicker,
    AppSupportDirectoryProvider? supportDirectoryProvider,
  })  : _fileSink = fileSink ?? AppFileLogSink.instance,
        _filePicker = filePicker ?? const AppPlatformLogFilePicker(),
        _supportDirectoryProvider =
            supportDirectoryProvider ?? getApplicationSupportDirectory;

  static final AppLogExportService instance = AppLogExportService();

  final AppFileLogSink _fileSink;
  final AppLogFilePicker _filePicker;
  final AppSupportDirectoryProvider _supportDirectoryProvider;

  /// 导出日志文件
  ///
  /// 可能抛出FilePicker的未知异常
  Future<AppLogExportResult?> exportLogFile(AppLogFileInfo fileInfo) async {
    AppLogger.info(
      'Log export started',
      loggerName: 'LogExportService',
      context: <String, Object?>{'fileName': fileInfo.name},
    );
    final File sourceFile = await _fileSink.resolveLogFile(fileInfo);

    final _PickerSelection saveSelection = await _trySaveFile(fileInfo.name);
    if (saveSelection.status == _PickerAttemptStatus.canceled) {
      return null;
    }
    if (saveSelection.path != null) {
      return _copyToDestination(
        sourceFile: sourceFile,
        requestedPath: saveSelection.path!,
        method: AppLogExportMethod.saveFile,
      );
    }
    // Not supported之后的处理
    final _PickerSelection directorySelection = await _tryPickDirectory();
    if (directorySelection.status == _PickerAttemptStatus.canceled) {
      return null;
    }
    if (directorySelection.path != null) {
      return _copyToDestination(
        sourceFile: sourceFile,
        requestedPath: path.join(directorySelection.path!, fileInfo.name),
        method: AppLogExportMethod.directoryPicker,
      );
    }

    final Directory supportDirectory = await _supportDirectoryProvider();
    final Directory exportDirectory =
        Directory(path.join(supportDirectory.path, 'exports', 'logs'));
    await exportDirectory.create(recursive: true);
    return _copyToDestination(
      sourceFile: sourceFile,
      requestedPath: path.join(exportDirectory.path, fileInfo.name),
      method: AppLogExportMethod.appFallback,
    );
  }

  /// 尝试使用文件保存器返回选择的文件路径
  Future<_PickerSelection> _trySaveFile(String fileName) async {
    try {
      final String? selectedPath =
          await _filePicker.saveFile(fileName: fileName);
      if (selectedPath == null || selectedPath.trim().isEmpty) {
        return const _PickerSelection.canceled();
      }
      return _PickerSelection.selected(selectedPath);
    } catch (error, stackTrace) {
      if (_isPickerUnsupported(error)) {
        AppLogger.warning(
          'Save file picker unavailable, fallback to directory picker',
          loggerName: 'LogExportService',
          error: error,
          stackTrace: stackTrace,
        );
        return const _PickerSelection.unsupported();
      }
      rethrow;
    }
  }

  /// 尝试使用目录选择器返回选择的目录路径
  Future<_PickerSelection> _tryPickDirectory() async {
    try {
      final String? selectedPath = await _filePicker.getDirectoryPath();
      if (selectedPath == null || selectedPath.trim().isEmpty) {
        return const _PickerSelection.canceled();
      }
      return _PickerSelection.selected(selectedPath);
    } catch (error, stackTrace) {
      if (_isPickerUnsupported(error)) {
        AppLogger.warning(
          'Directory picker unavailable, fallback to app export directory',
          loggerName: 'LogExportService',
          error: error,
          stackTrace: stackTrace,
        );
        return const _PickerSelection.unsupported();
      }
      rethrow;
    }
  }

  Future<AppLogExportResult> _copyToDestination({
    required File sourceFile,
    required String requestedPath,
    required AppLogExportMethod method,
  }) async {
    final String targetPath = await _resolveExportPath(
      sourcePath: sourceFile.path,
      requestedPath: requestedPath,
    );
    final File targetFile = File(targetPath);
    await targetFile.parent.create(recursive: true);
    await sourceFile.copy(targetPath);
    AppLogger.info(
      'Log export finished',
      loggerName: 'LogExportService',
      context: <String, Object?>{
        'sourcePath': sourceFile.path,
        'targetPath': targetPath,
        'method': method.name,
      },
    );
    return AppLogExportResult(path: targetPath, method: method);
  }

  Future<String> _resolveExportPath({
    required String sourcePath,
    required String requestedPath,
  }) async {
    String nextPath = _normalizeExtension(
      requestedPath: requestedPath,
      sourcePath: sourcePath,
    );
    final String normalizedSource = path.normalize(sourcePath);
    final String normalizedRequested = path.normalize(nextPath);
    if (normalizedRequested != normalizedSource &&
        !await File(nextPath).exists()) {
      return nextPath;
    }

    final String directory = path.dirname(nextPath);
    final String basename = path.basenameWithoutExtension(nextPath);
    final String extension = path.extension(nextPath);
    // 防重名后缀只保留时间（HH-mm-ss-SSS）：源日志文件名已含日期，
    // 再拼接日期既冗余，又容易被误读为“日期叠日期”。
    final String timestamp = DateFormat('HH-mm-ss-SSS').format(DateTime.now());
    return path.join(directory, '$basename-$timestamp$extension');
  }

  String _normalizeExtension({
    required String requestedPath,
    required String sourcePath,
  }) {
    if (path.extension(requestedPath).isNotEmpty) {
      return requestedPath;
    }
    return '$requestedPath${path.extension(sourcePath)}';
  }

  bool _isPickerUnsupported(Object error) {
    if (error is MissingPluginException ||
        error is UnsupportedError ||
        error is UnimplementedError) {
      return true;
    }
    if (error is PlatformException) {
      final String code = error.code.toLowerCase();
      final String message = (error.message ?? '').toLowerCase();
      return code.contains('unimplemented') ||
          code.contains('unsupported') ||
          message.contains('unimplemented') ||
          message.contains('unsupported');
    }
    return false;
  }
}

enum _PickerAttemptStatus {
  selected,
  canceled,
  unsupported,
}

/// 文件选择器尝试结果
class _PickerSelection {
  const _PickerSelection.selected(String this.path)
      : status = _PickerAttemptStatus.selected;

  const _PickerSelection.canceled()
      : status = _PickerAttemptStatus.canceled,
        path = null;

  const _PickerSelection.unsupported()
      : status = _PickerAttemptStatus.unsupported,
        path = null;

  final _PickerAttemptStatus status;
  final String? path;
}
