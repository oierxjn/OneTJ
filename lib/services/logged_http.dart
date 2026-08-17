import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:onetj/app/logging/logger.dart';

/// 带网络日志的 HTTP GET。
///
/// 请求与响应会写入网络日志,失败时记录错误日志后 rethrow。
Future<http.Response> loggedHttpGet(
  Uri uri, {
  Map<String, String>? headers,
  String loggerName = 'Http',
}) async {
  AppLogger.logNetworkRequest(method: 'GET', uri: uri);
  final Stopwatch stopwatch = Stopwatch()..start();
  try {
    final http.Response response = await http.get(uri, headers: headers);
    AppLogger.logNetworkResponse(
      method: 'GET',
      uri: uri,
      statusCode: response.statusCode,
      elapsedMs: stopwatch.elapsedMilliseconds,
    );
    return response;
  } catch (error, stackTrace) {
    AppLogger.error(
      'GET request failed',
      loggerName: loggerName,
      error: error,
      stackTrace: stackTrace,
      context: <String, Object?>{
        'method': 'GET',
        'path': uri.path,
        'elapsedMs': stopwatch.elapsedMilliseconds,
      },
    );
    rethrow;
  }
}

/// 带网络日志的 HTTP POST。
///
/// 请求与响应会写入网络日志,失败时记录错误日志后 rethrow。
Future<http.Response> loggedHttpPost(
  Uri uri, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
  String loggerName = 'Http',
}) async {
  AppLogger.logNetworkRequest(method: 'POST', uri: uri);
  final Stopwatch stopwatch = Stopwatch()..start();
  try {
    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    AppLogger.logNetworkResponse(
      method: 'POST',
      uri: uri,
      statusCode: response.statusCode,
      elapsedMs: stopwatch.elapsedMilliseconds,
    );
    return response;
  } catch (error, stackTrace) {
    AppLogger.error(
      'POST request failed',
      loggerName: loggerName,
      error: error,
      stackTrace: stackTrace,
      context: <String, Object?>{
        'method': 'POST',
        'path': uri.path,
        'elapsedMs': stopwatch.elapsedMilliseconds,
      },
    );
    rethrow;
  }
}
