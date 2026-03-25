import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:onetj/app/constant/app_version_constant.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/repo/app_update_state_repository.dart';
import 'package:onetj/services/app_update_api.dart';

enum AppUpdateInstallResult {
  installerStarted,
  permissionRequired,
}

class AppUpdateService {
  AppUpdateService({
    AppUpdateApi? api,
    AppUpdateStateRepository? repository,
  })  : _api = api ?? AppUpdateApi(),
        _repository = repository ?? AppUpdateStateRepository.getInstance();

  static AppUpdateService? _instance;
  static AppUpdateService getInstance() {
    return _instance ??= AppUpdateService();
  }

  final AppUpdateApi _api;
  final AppUpdateStateRepository _repository;
  static const MethodChannel _installChannel =
      MethodChannel('onetj/app_update');

  static const Duration _defaultThrottleWindow = Duration(hours: 24);

  /// 检查更新
  ///
  /// [force] 是否强制检查更新
  /// [throttleWindow] 节流窗口(强制更新时无效)
  ///
  /// return:
  ///
  /// [AppUpdateCheckResult] 更新检查结果
  Future<AppUpdateCheckResult> checkForUpdate({
    bool force = false,
    Duration throttleWindow = _defaultThrottleWindow,
  }) async {
    final DateTime now = DateTime.now();
    final AppUpdateStateData state =
        await _repository.getState(refreshFromStorage: true);
    if (!force && _isThrottled(state.lastCheckedAt, now, throttleWindow)) {
      return const AppUpdateCheckResult(
        checked: false,
        hasUpdate: false,
        throttled: true,
      );
    }
    final AppUpdateCheckResult result = await _api.checkLatest(
      platform: _resolveCurrentPlatform(),
      arch: _resolveCurrentArch(),
      currentVersion: _resolveCurrentVersion(),
      currentBuild: _resolveCurrentBuild(),
    );
    await _repository.markCheckedAt(now);
    if (!result.hasUpdate) {
      return result;
    }
    final AppUpdateInfo info = result.updateInfo!;
    if (!force && state.skippedVersionTag == info.versionTag) {
      return const AppUpdateCheckResult(
        checked: true,
        hasUpdate: false,
      );
    }
    return result;
  }

  Future<void> skipVersion(String versionTag) async {
    await _repository.skipVersion(versionTag);
  }

  Future<void> clearSkippedVersion() async {
    await _repository.clearSkippedVersion();
  }

  /// 是否被节流
  ///
  /// [lastCheckedAt] 上次检查时间
  /// [now] 当前时间
  /// [window] 节流窗口
  bool _isThrottled(DateTime? lastCheckedAt, DateTime now, Duration window) {
    if (lastCheckedAt == null) {
      return false;
    }
    return now.difference(lastCheckedAt) < window;
  }

  /// 下载更新包
  ///
  /// [info] 更新信息
  /// [onProgress] 下载进度回调
  Future<File> downloadPackage(
    AppUpdateInfo info, {
    void Function(int receivedBytes, int? totalBytes)? onProgress,
  }) async {
    final Uri uri = Uri.parse(info.downloadUrl);
    final http.Client client = http.Client();
    try {
      final http.Request request = http.Request('GET', uri);
      final http.StreamedResponse response = await client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NetworkException.http(statusCode: response.statusCode, uri: uri);
      }
      final Directory dir = await getTemporaryDirectory();
      final String basename = _resolveDownloadFileName(uri, info);
      final File file = File(p.join(dir.path, basename));
      if (await file.exists()) {
        await file.delete();
      }
      final IOSink sink = file.openWrite();
      int received = 0;
      await for (final List<int> chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, response.contentLength);
      }
      await sink.flush();
      await sink.close();
      await _verifySha256(
        file: file,
        expectedSha256: info.sha256,
      );
      await _repository.savePendingInstall(
        filePath: file.path,
        versionTag: info.versionTag,
        sha256: info.sha256,
      );
      return file;
    } finally {
      client.close();
    }
  }

  /// 构造文件名
  ///
  /// 格式：`onetj_update_${platform}_${versionTag}`
  String _resolveDownloadFileName(Uri uri, AppUpdateInfo info) {
    final String fromPath = p.basename(uri.path);
    if (fromPath.isNotEmpty && fromPath != '/') {
      return fromPath;
    }
    final String platform = _resolveCurrentPlatform();
    return 'onetj_update_${platform}_${info.versionTag}';
  }

  /// 验证文件哈希
  ///
  /// [file] 文件
  /// [expectedSha256] 预期的 SHA256 哈希
  ///
  /// throw:
  ///
  /// [AppException] 哈希不匹配
  Future<void> _verifySha256({
    required File file,
    required String expectedSha256,
  }) async {
    if (expectedSha256.isEmpty) {
      return;
    }
    final Digest digest = await sha256.bind(file.openRead()).first;
    final String actual = digest.toString().toLowerCase();
    if (actual != expectedSha256.toLowerCase()) {
      throw AppException(
        'UPDATE_PACKAGE_HASH_MISMATCH',
        'Downloaded update package hash mismatch',
        cause: 'expected=$expectedSha256 actual=$actual',
      );
    }
  }

  /// 安装更新包
  ///
  /// [file] 更新包文件
  ///
  /// throw:
  ///
  /// [AppException] 安装失败
  Future<AppUpdateInstallResult> installPackage(File file) async {
    if (Platform.isWindows) {
      await Process.start(
        file.path,
        const <String>[],
        mode: ProcessStartMode.detached,
      );
      return AppUpdateInstallResult.installerStarted;
    }
    if (Platform.isAndroid) {
      final AppUpdateInstallResult result = await _installAndroidPackage(file);
      await _repository.markPendingAwaitingInstallPermission(
        result == AppUpdateInstallResult.permissionRequired,
      );
      return result;
    }
    throw AppException(
      'UPDATE_PLATFORM_UNSUPPORTED',
      'Current platform does not support in-app install',
      cause: _resolveCurrentPlatform(),
    );
  }

  String _resolveCurrentPlatform() {
    if (Platform.isWindows) {
      return 'windows';
    }
    if (Platform.isAndroid) {
      return 'android';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    if (Platform.isMacOS) {
      return 'macos';
    }
    if (Platform.isLinux) {
      return 'linux';
    }
    return 'unknown';
  }

  String? _resolveCurrentArch() {
    if (!Platform.isWindows) {
      return null;
    }
    final String envArch =
        (Platform.environment['PROCESSOR_ARCHITECTURE'] ?? '').toLowerCase();
    if (envArch.contains('64')) {
      return 'x64';
    }
    if (envArch.contains('86')) {
      return 'x86';
    }
    if (envArch.contains('arm')) {
      return 'arm64';
    }
    return 'x64';
  }

  String _resolveCurrentVersion() => oneTJAppVersion;

  String _resolveCurrentBuild() => oneTJAppBuildNumber;

  /// 尝试恢复待安装的更新
  Future<void> resumePendingInstall() async {
    if (!Platform.isAndroid) {
      return;
    }
    final AppUpdateStateData state =
        await _repository.getState(refreshFromStorage: true);
    if (!state.pendingAwaitingInstallPermission) {
      return;
    }
    final String? filePath = state.pendingFilePath;
    if (filePath == null || filePath.isEmpty) {
      await _repository.clearPendingInstall();
      return;
    }
    final File file = File(filePath);
    if (!await file.exists()) {
      await _repository.clearPendingInstall();
      return;
    }
    try {
      await _verifySha256(
        file: file,
        expectedSha256: state.pendingSha256 ?? '',
      );
    } catch (error, stackTrace) {
      await _repository.clearPendingInstall();
      AppLogger.warning(
        'Pending update package verification failed',
        loggerName: 'AppUpdateService',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{
          'filePath': file.path,
          'versionTag': state.pendingVersionTag,
        },
      );
      return;
    }
    if (!await _canInstallAndroidPackages()) {
      return;
    }
    final AppUpdateInstallResult result = await _installAndroidPackage(file);
    await _repository.markPendingAwaitingInstallPermission(
      result == AppUpdateInstallResult.permissionRequired,
    );
  }

  String formatReleaseNotes(AppUpdateInfo info) {
    final String notes = info.releaseNotes.trim();
    if (notes.isEmpty) {
      return '';
    }
    try {
      final Object? decoded = jsonDecode(notes);
      if (decoded is List) {
        return decoded.whereType<String>().join('\n');
      }
    } catch (_) {
      // Keep raw text fallback.
    }
    return notes;
  }

  Future<bool> _canInstallAndroidPackages() async {
    try {
      return await _installChannel.invokeMethod<bool>('canInstallPackages') ??
          false;
    } on PlatformException catch (error) {
      throw AppException(
        error.code,
        error.message ?? 'Failed to query Android install permission',
        cause: error.details,
      );
    }
  }

  Future<AppUpdateInstallResult> _installAndroidPackage(File file) async {
    try {
      final Map<Object?, Object?>? result =
          await _installChannel.invokeMethod<Map<Object?, Object?>>(
        'installApk',
        <String, Object?>{
          'filePath': file.path,
        },
      );
      final Object? status = result?['status'];
      switch (status) {
        case 'installer_started':
          return AppUpdateInstallResult.installerStarted;
        case 'permission_required':
          return AppUpdateInstallResult.permissionRequired;
        default:
          throw AppException(
            'UPDATE_PACKAGE_OPEN_FAILED',
            'Failed to start Android package installer',
            cause: result,
          );
      }
    } on PlatformException catch (error) {
      throw AppException(
        error.code,
        error.message ?? 'Failed to start Android package installer',
        cause: error.details,
      );
    }
  }

  void logUpdateFailure(Object error, StackTrace stackTrace) {
    AppLogger.warning(
      'App update workflow failed',
      loggerName: 'AppUpdateService',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
