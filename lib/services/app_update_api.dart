import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/app_update_info.dart';

class AppUpdateApi {
  AppUpdateApi();

  static AppUpdateApi? _instance;

  static AppUpdateApi getInstance() {
    return _instance ??= AppUpdateApi();
  }

  Future<AppUpdateCheckResult> checkLatest({
    required String platform,
    String? arch,
    required String currentVersion,
    required String currentBuild,
  }) async {
    final Uri uri = Uri.https(
      appUpdateServiceBaseUrl,
      appUpdateCheckPath,
      <String, String>{
        'platform': platform,
        if (arch != null && arch.isNotEmpty) 'arch': arch,
        'current_version': currentVersion,
        'current_build': currentBuild,
      },
    );
    AppLogger.logNetworkRequest(method: 'GET', uri: uri);
    final Stopwatch stopwatch = Stopwatch()..start();
    http.Response? response;
    try {
      response = await http.get(uri, headers: const <String, String>{
        'Accept': 'application/json',
      });
    } catch (error, stackTrace) {
      AppLogger.error(
        'Update check request failed',
        loggerName: 'AppUpdateApi',
        error: error,
        stackTrace: stackTrace,
      );
      throw NetworkException(
        message: 'Update check request failed',
        uri: uri,
        cause: error,
      );
    } finally {
      AppLogger.logNetworkResponse(
        method: 'GET',
        uri: uri,
        statusCode: response?.statusCode ?? -1,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    }
    final http.Response resolvedResponse = response;
    if (resolvedResponse.statusCode < 200 ||
        resolvedResponse.statusCode >= 300) {
      throw NetworkException.http(
        statusCode: resolvedResponse.statusCode,
        uri: uri,
        responseBody: resolvedResponse.body,
      );
    }

    final Map<String, dynamic> jsonBody;
    try {
      jsonBody = json.decode(resolvedResponse.body) as Map<String, dynamic>;
    } catch (error, stackTrace) {
      final JSONResolveException exception = JSONResolveException(
        message: 'Failed to parse update check response',
        cause: error,
      );
      Error.throwWithStackTrace(exception, stackTrace);
    }

    final Map<String, dynamic> data =
        (jsonBody['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final bool hasUpdate = data['has_update'] as bool? ?? false;
    if (!hasUpdate) {
      return const AppUpdateCheckResult(checked: true, hasUpdate: false);
    }
    final AppUpdateInfo info = AppUpdateInfo.fromJson(data);
    return AppUpdateCheckResult(
      checked: true,
      hasUpdate: true,
      updateInfo: info,
    );
  }
}
