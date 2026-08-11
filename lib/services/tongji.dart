import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/api_response.dart';
import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/models/data/course_schedule_net_data.dart';
import 'package:onetj/models/data/school_calendar_net_data.dart';
import 'package:onetj/models/data/student_info_net_data.dart';
import 'package:onetj/models/data/undergraduate_score_net_data.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/models/student_info_data.dart';
import 'package:onetj/models/undergraduate_score_data.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/logged_http.dart';

class TongjiApi {
  TongjiApi._([this._authOverride]);

  /// 获取 [TongjiApi] 实例。
  ///
  /// 这是一个单例模式，确保在整个应用程序中只有一个实例。
  /// 传入 [auth] 时会返回一个使用该实例的新对象，便于测试注入。
  factory TongjiApi({AuthTokenProvider? auth}) =>
      auth == null ? _instance : TongjiApi._(auth);

  static final TongjiApi _instance = TongjiApi._();

  final AuthTokenProvider? _authOverride;

  AuthTokenProvider get _auth =>
      _authOverride ?? appLocator<AuthTokenProvider>();

  final String _baseUrl = tongjiApiBaseUrl;

  Future<http.Response> _authorizedGet(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final String accessToken = await _auth.getValidAccessToken();
    final Map<String, String> requestHeaders = <String, String>{
      'Authorization': 'Bearer $accessToken',
      if (headers != null) ...headers,
    };
    try {
      return await loggedHttpGet(uri, headers: requestHeaders);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Authorized GET failed',
        loggerName: 'TongjiApi',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{'path': uri.path},
      );
      throw NetworkException(
        message: 'Request failed',
        uri: uri,
        cause: error,
      );
    }
  }

  Future<T> _authorizedGetData<T>(
    Uri uri, {
    required T Function(Object? data) parseData,
    Map<String, String>? headers,
  }) async {
    final http.Response response = await _authorizedGet(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NetworkException.http(
        statusCode: response.statusCode,
        uri: uri,
        responseBody: response.body,
      );
    }
    final Map<String, dynamic> jsonBody;
    final ApiResponse<T> payload;
    try {
      jsonBody = json.decode(response.body) as Map<String, dynamic>;
      payload = ApiResponse.fromJson(jsonBody, parseData);
    } catch (error, stackTrace) {
      final exception = JSONResolveException(
        message: 'Failed to parse response JSON, origin body: ${response.body}',
        cause: error,
      );
      Error.throwWithStackTrace(exception, stackTrace);
    }
    return payload.data;
  }

  Future<http.Response> _authorizedPost(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final String accessToken = await _auth.getValidAccessToken();
    final Map<String, String> requestHeaders = <String, String>{
      'Authorization': 'Bearer $accessToken',
      if (headers != null) ...headers,
    };
    try {
      return await loggedHttpPost(
        uri,
        headers: requestHeaders,
        body: body,
        encoding: encoding,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Authorized POST failed',
        loggerName: 'TongjiApi',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{'path': uri.path},
      );
      throw NetworkException(
        message: 'Request failed',
        uri: uri,
        cause: error,
      );
    }
  }

  // ignore: unused_element
  Future<T> _authorizedPostData<T>(
    Uri uri, {
    required T Function(Object? data) parseData,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final http.Response response = await _authorizedPost(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NetworkException.http(
        statusCode: response.statusCode,
        uri: uri,
        responseBody: response.body,
      );
    }
    final Map<String, dynamic> jsonBody;
    final ApiResponse<T> payload;
    try {
      jsonBody = json.decode(response.body) as Map<String, dynamic>;
      payload = ApiResponse.fromJson(jsonBody, parseData);
    } catch (error) {
      throw JSONResolveException(
          message: 'Failed to parse response JSON', cause: error);
    }
    return payload.data;
  }

  Future<StudentInfoData> fetchStudentInfo() async {
    final Uri uri = Uri.https(_baseUrl, studentInfoPath);
    final StudentInfoNetData netData =
        await _authorizedGetData<StudentInfoNetData>(
      uri,
      parseData: (Object? data) {
        final List<dynamic> list =
            (data as List<dynamic>?) ?? const <dynamic>[];
        if (list.isEmpty) {
          throw AppException('EMPTY_DATA', 'Student info is empty');
        }
        return StudentInfoNetData.fromJson(list.first as Map<String, dynamic>);
      },
    );
    return StudentInfoData.fromNetData(netData);
  }

  Future<SchoolCalendarData> fetchSchoolCalendarCurrentTerm() async {
    final Uri uri = Uri.https(_baseUrl, currentTermCalendarPath);
    final SchoolCalendarNetData netData =
        await _authorizedGetData<SchoolCalendarNetData>(
      uri,
      parseData: (Object? data) =>
          SchoolCalendarNetData.fromJson(data as Map<String, dynamic>),
    );
    return SchoolCalendarData.fromNetData(netData);
  }

  Future<CourseScheduleData> fetchStudentTimetable() async {
    final Uri uri = Uri.https(_baseUrl, studentTimetablePath);
    final List<CourseScheduleItemNetData> netList =
        await _authorizedGetData<List<CourseScheduleItemNetData>>(
      uri,
      parseData: (Object? data) {
        final List<dynamic> list =
            (data as List<dynamic>?) ?? const <dynamic>[];
        return list
            .map(
              (dynamic item) => CourseScheduleItemNetData.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      },
    );
    return CourseScheduleData.fromNetDataList(netList);
  }

  /// 获取本科生成绩
  ///
  /// [calendarId] 可选,指定查询的学期,默认查询当前学期。-1 返回所有学期。
  Future<UndergraduateScoreData> fetchUndergraduateScore(
      {int? calendarId}) async {
    final Uri uri = Uri.https(
      _baseUrl,
      undergraduateScorePath,
      calendarId == null
          ? null
          : <String, String>{
              'calendarId': calendarId.toString(),
            },
    );
    final UndergraduateScoreNetData netData =
        await _authorizedGetData<UndergraduateScoreNetData>(
      uri,
      parseData: (Object? data) =>
          UndergraduateScoreNetData.fromJson(data as Map<String, dynamic>),
    );
    return UndergraduateScoreData.fromNetData(netData);
  }
}
