import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/api_response.dart';
import 'package:onetj/models/data/code2token.dart';
import 'package:onetj/models/data/course_schedule_net_data.dart';
import 'package:onetj/models/data/school_calendar_net_data.dart';
import 'package:onetj/models/data/student_info_net_data.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';

class TongjiApi {
  TongjiApi._();

  /// 获取 [TongjiApi] 实例。
  /// 
  /// 这是一个单例模式，确保在整个应用程序中只有一个实例。
  factory TongjiApi() => _instance;

  static final TongjiApi _instance = TongjiApi._();

  final String _baseUrl = tongjiApiBaseUrl;
  static const Duration _tokenSkew = Duration(seconds: 30);

  final Logger _logger = Logger('TongjiApi');

  /// Exchange auth code for token.
  ///
  /// Saves the token into [TokenRepository] on success.
  Future<void> code2token(String code) async {
    final Uri uri = Uri.https(_baseUrl, code2tokenPath);
    final response = await http.post(
      uri,
      body: {
        'grant_type': 'authorization_code',
        'client_id': tongjiClientID,
        'code': code,
        'redirect_uri': oneTJredirectUri,
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Code2TokenData data = Code2TokenData.fromJson(json.decode(response.body));
      final TokenRepository repo = TokenRepository.getInstance();
      await repo.saveFromCode2Token(data);
      return;
    }
    throw NetworkException.http(
      statusCode: response.statusCode,
      uri: uri,
      responseBody: response.body,
    );
  }

  /// Token刷新
  /// 
  /// 返回刷新后的 [Code2TokenData]。不进行存储。
  Future<Code2TokenData> refreshToken(String refreshToken) async {
    final Uri uri = Uri.https(_baseUrl, code2tokenPath);
    final response = await http.post(
      uri,
      body: {
        'grant_type': 'refresh_token',
        'client_id': tongjiClientID,
        'refresh_token': refreshToken,
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Code2TokenData.fromJson(json.decode(response.body));
    }
    throw NetworkException.http(
      statusCode: response.statusCode,
      uri: uri,
      responseBody: response.body,
    );
  }

  Future<http.Response> _authorizedGet(Uri uri, {Map<String, String>? headers}) async {
    final String accessToken = await _getValidAccessToken();
    final Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $accessToken',
      if (headers != null) ...headers,
    };
    try {
      return await http.get(uri, headers: requestHeaders);
    } catch (error) {
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
    } catch (error) {
      throw JSONResolveException(message: 'Failed to parse response JSON, origin body: ${response.body}', cause: error);
    }
    return payload.data;
  }

  Future<http.Response> _authorizedPost(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final String accessToken = await _getValidAccessToken();
    final Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $accessToken',
      if (headers != null) ...headers,
    };
    try {
      return await http.post(uri, headers: requestHeaders, body: body, encoding: encoding);
    } catch (error) {
      throw NetworkException(
        message: 'Request failed',
        uri: uri,
        cause: error,
      );
    }
  }

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
      throw JSONResolveException(message: 'Failed to parse response JSON', cause: error);
    }
    return payload.data;
  }

  Future<String> _getValidAccessToken() async {
    final TokenRepository repo = TokenRepository.getInstance();
    final TokenData? token = await repo.getToken(refreshFromStorage: true); 
    if (token == null) {
      throw AppException('AUTH_REQUIRED', 'Missing access token');
    }
    if (!token.isAccessTokenExpired(skew: _tokenSkew)) {
      return token.accessToken;
    }
    if (token.isRefreshTokenExpired(skew: _tokenSkew)) {
      throw AppException('AUTH_EXPIRED', 'Refresh token expired');
    }
    final Code2TokenData refreshed = await refreshToken(token.refreshToken);
    await repo.saveFromCode2Token(refreshed);
    return refreshed.accessToken;
  }

  Future<StudentInfoData> fetchStudentInfo() async {
    final Uri uri = Uri.https(_baseUrl, studentInfoPath);
    final StudentInfoNetData netData = await _authorizedGetData<StudentInfoNetData>(
      uri,
      parseData: (data) {
        final List<dynamic> list = (data as List<dynamic>?) ?? const [];
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
    final SchoolCalendarNetData netData = await _authorizedGetData<SchoolCalendarNetData>(
      uri,
      parseData: (data) => SchoolCalendarNetData.fromJson(data as Map<String, dynamic>),
    );
    return SchoolCalendarData.fromNetData(netData);
  }

  Future<CourseScheduleData> fetchStudentTimetable() async {
    final Uri uri = Uri.https(_baseUrl, studentTimetablePath);
    final List<CourseScheduleItemNetData> netList =
        await _authorizedGetData<List<CourseScheduleItemNetData>>(
      uri,
      parseData: (data) {
        final List<dynamic> list = (data as List<dynamic>?) ?? const [];
        return list
            .map((item) => CourseScheduleItemNetData.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
    return CourseScheduleData.fromNetDataList(netList);
  }
}
