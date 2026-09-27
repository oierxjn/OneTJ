import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/models/data/code2token.dart';
import 'package:onetj/models/token_data.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/logged_http.dart';

/// 发起一次表单 POST 的可注入入口，默认走带日志的 [loggedHttpPost]。
typedef AuthHttpPost = Future<http.Response> Function(
  Uri uri, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
  String loggerName,
});

/// 负责认证令牌的生命周期管理:授权码交换、过期检查与刷新。
class AuthTokenProvider {
  AuthTokenProvider({
    required TokenRepository repository,
    SessionController? sessionController,
    AuthHttpPost? httpPost,
  })  : _repository = repository,
        _sessionController = sessionController,
        _httpPost = httpPost ?? _defaultHttpPost;

  static Future<http.Response> _defaultHttpPost(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    String loggerName = 'Http',
  }) {
    return loggedHttpPost(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
      loggerName: loggerName,
    );
  }

  final TokenRepository _repository;

  /// 令牌失效时用于把会话状态同步给路由守卫。
  ///
  /// 可选：单元测试与不关心导航的调用方可以不注入。
  final SessionController? _sessionController;

  /// HTTP 入口，注入用于测试刷新被拒等网络路径。
  final AuthHttpPost _httpPost;

  final String _baseUrl = tongjiApiBaseUrl;
  static const Duration _tokenSkew = Duration(seconds: 30);

  /// 用授权码交换 token,成功后写入 [TokenRepository]。
  Future<void> exchangeCode(String code) async {
    final Uri uri = Uri.https(_baseUrl, code2tokenPath);
    final http.Response response = await _httpPost(
      uri,
      loggerName: 'AuthTokenProvider',
      body: <String, String>{
        'grant_type': 'authorization_code',
        'client_id': tongjiClientID,
        'code': code,
        'redirect_uri': oneTJredirectUri,
      },
      headers: const <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Code2TokenData data =
          Code2TokenData.fromJson(json.decode(response.body));
      await _repository.saveFromCode2Token(data);
      return;
    }
    throw NetworkException.http(
      statusCode: response.statusCode,
      uri: uri,
      responseBody: response.body,
    );
  }

  /// 返回一个有效的 access token。
  ///
  /// access token 过期时会用 refresh token 刷新,并写回 [TokenRepository]。
  /// 没有 token 时抛出 `AppException('AUTH_REQUIRED')`;
  /// refresh token 也过期时抛出 `AppException('AUTH_EXPIRED')`。
  ///
  /// 后两种情况会同时把 [SessionController] 标记为未登录，使路由守卫把用户
  /// 送回登录页；`AUTH_REQUIRED` 在启动引导期间不会触发跳转（状态仍为 unknown）。
  Future<String> getValidAccessToken() async {
    final TokenData? token =
        await _repository.getToken(refreshFromStorage: true);
    if (token == null) {
      _sessionController?.markUnauthenticated(reason: 'missing_token');
      throw AppException('AUTH_REQUIRED', 'Missing access token');
    }
    if (!token.isAccessTokenExpired(skew: _tokenSkew)) {
      return token.accessToken;
    }
    if (token.isRefreshTokenExpired(skew: _tokenSkew)) {
      _sessionController?.markUnauthenticated(reason: 'refresh_token_expired');
      throw AppException('AUTH_EXPIRED', 'Refresh token expired');
    }
    final Code2TokenData refreshed;
    try {
      refreshed = await _refreshToken(token.refreshToken);
    } on NetworkException catch (error) {
      // 本地看 refresh token 未过期，但服务端明确拒绝（401，例如令牌被吊销）。
      // 这是确定的认证失败，上报未登录；其余状态码与网络故障不上报，避免
      // 瞬时抖动把用户误登出。
      if (error.statusCode == 401) {
        _sessionController?.markUnauthenticated(reason: 'refresh_rejected_401');
      }
      rethrow;
    }
    await _repository.saveFromCode2Token(refreshed);
    return refreshed.accessToken;
  }

  /// 用 refresh token 刷新 token,返回新的 [Code2TokenData],不写存储。
  Future<Code2TokenData> _refreshToken(String refreshToken) async {
    final Uri uri = Uri.https(_baseUrl, code2tokenPath);
    final http.Response response = await _httpPost(
      uri,
      loggerName: 'AuthTokenProvider',
      body: <String, String>{
        'grant_type': 'refresh_token',
        'client_id': tongjiClientID,
        'refresh_token': refreshToken,
      },
      headers: const <String, String>{
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
}
