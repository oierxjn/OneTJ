import 'dart:io';

import 'package:open_filex/open_filex.dart';

import 'package:onetj/app/logging/log_export_service.dart';
import 'package:onetj/app/logging/log_file_info.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';

typedef AppLogFilesLoader = Future<List<AppLogFileInfo>> Function();
typedef AppLogFileReader = Future<String> Function(AppLogFileInfo fileInfo);
typedef AppLogFileOpener = Future<OpenResult> Function(String path);

class LogViewerUiState {
  const LogViewerUiState({
    required this.loadingFiles,
    required this.loadingContent,
    required this.exporting,
    required this.files,
    required this.selectedFile,
    required this.content,
    required this.filesError,
    required this.contentError,
  });

  final bool loadingFiles;
  final bool loadingContent;
  final bool exporting;
  final List<AppLogFileInfo> files;
  final AppLogFileInfo? selectedFile;
  final String? content;
  final String? filesError;
  final String? contentError;
}

class LogViewerViewModel extends BaseViewModel<UiEvent> {
  LogViewerViewModel({
    AppLogExportService? logExportService,
    AppLogFilesLoader? listLogFiles,
    AppLogFileReader? readLogFile,
    AppLogFileOpener? openFile,
  })  : _logExportService = logExportService ?? AppLogExportService.instance,
        _listLogFiles = listLogFiles ?? AppLogger.listLogFiles,
        _readLogFile = readLogFile ?? AppLogger.readLogFile,
        _openFile = openFile ?? OpenFilex.open;

  final AppLogExportService _logExportService;
  final AppLogFilesLoader _listLogFiles;
  final AppLogFileReader _readLogFile;
  final AppLogFileOpener _openFile;

  int _contentRequestId = 0;
  bool _loadingFiles = true;
  bool _loadingContent = false;
  bool _exporting = false;
  List<AppLogFileInfo> _files = const <AppLogFileInfo>[];
  AppLogFileInfo? _selectedFile;
  String? _content;
  String? _filesError;
  String? _contentError;

  LogViewerUiState get uiState => LogViewerUiState(
        loadingFiles: _loadingFiles,
        loadingContent: _loadingContent,
        exporting: _exporting,
        files: List<AppLogFileInfo>.unmodifiable(_files),
        selectedFile: _selectedFile,
        content: _content,
        filesError: _filesError,
        contentError: _contentError,
      );

  Future<void> initialize() async {
    await reloadFiles();
  }

  Future<void> reloadFiles() async {
    _contentRequestId += 1;
    _loadingFiles = true;
    _filesError = null;
    notifyListeners();
    try {
      final List<AppLogFileInfo> files = await _listLogFiles();
      final AppLogFileInfo? nextSelected = files.isEmpty ? null : files.first;
      _files = files;
      _selectedFile = nextSelected;
      _loadingFiles = false;
      _content = null;
      _contentError = null;
      notifyListeners();
      if (nextSelected != null) {
        await selectFile(nextSelected);
      }
    } catch (error) {
      _loadingFiles = false;
      _files = const <AppLogFileInfo>[];
      _selectedFile = null;
      _filesError = error.toString();
      _content = null;
      _contentError = null;
      notifyListeners();
    }
  }

  Future<void> selectFile(AppLogFileInfo file) async {
    final int requestId = ++_contentRequestId;
    _selectedFile = file;
    _loadingContent = true;
    _contentError = null;
    notifyListeners();
    try {
      final String text = await _readLogFile(file);
      if (requestId != _contentRequestId || isDisposed) {
        return;
      }
      _content = text;
      _loadingContent = false;
      notifyListeners();
    } on FileSystemException catch (error) {
      if (requestId != _contentRequestId || isDisposed) {
        return;
      }
      _content = null;
      _loadingContent = false;
      _contentError = error.message;
      notifyListeners();
    } catch (error) {
      if (requestId != _contentRequestId || isDisposed) {
        return;
      }
      _content = null;
      _loadingContent = false;
      _contentError = error.toString();
      notifyListeners();
    }
  }

  Future<void> exportSelectedFile() async {
    final AppLogFileInfo? selectedFile = _selectedFile;
    if (selectedFile == null || _exporting) {
      return;
    }
    _exporting = true;
    notifyListeners();
    try {
      final result = await _logExportService.exportLogFile(selectedFile);
      if (result == null) {
        AppLogger.info(
          'Log export canceled',
          loggerName: 'LogViewerViewModel',
          context: <String, Object?>{'fileName': selectedFile.name},
        );
        emit(const LogExportCanceledEvent());
        return;
      }
      emit(LogExportSucceededEvent(path: result.path));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Log export failed',
        loggerName: 'LogViewerViewModel',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{'fileName': selectedFile.name},
      );
      emit(LogExportFailedEvent(message: error.toString()));
    } finally {
      _exporting = false;
      notifyListeners();
    }
  }

  Future<void> openExportedFile(String path) async {
    try {
      final OpenResult result = await _openFile(path);
      if (result.type == ResultType.done) {
        emit(LogOpenSucceededEvent(path: path));
        return;
      }
      emit(
        LogOpenFailedEvent(
          message: result.message,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Open exported log file failed',
        loggerName: 'LogViewerViewModel',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{'filePath': path},
      );
      emit(LogOpenFailedEvent(message: error.toString()));
    }
  }
}
