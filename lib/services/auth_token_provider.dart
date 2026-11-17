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

  /// 当前在飞的那一次刷新。
  ///
  /// 服务端按单次轮换 refresh token，用过即作废。多个请求同时发现 access token
  /// 过期时若各自刷新，后到的必然拿到 401，被 [SessionController] 当成登录失效
  /// 把用户踢回登录页。共享同一个 future 可避免重复刷新，后来者复用其结果或异常。
  ///
  /// 去重范围是整个应用：本类以 `registerLazySingleton` 注册，实例字段由所有
  /// 调用方共享。
  Future<String>? _inFlightRefresh;

  /// OAuth 规范中表示授权授予无效的错误码。
  static const String _invalidGrantError = 'invalid_grant';

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
    final ({int statusCode, String body}) effective =
        _unwrapTokenResponse(response);
    if (effective.statusCode >= 200 && effective.statusCode < 300) {
      final Code2TokenData data =
          Code2TokenData.fromJson(json.decode(effective.body));
      await _repository.saveFromCode2Token(data);
      return;
    }
    throw NetworkException.http(
      statusCode: effective.statusCode,
      uri: uri,
      responseBody: effective.body,
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
  ///
  /// 并发调用共用一次刷新，详见 [_inFlightRefresh]。
  Future<String> getValidAccessToken() async {
    final TokenData? token = await _repository.getToken();
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
    return _inFlightRefresh ??= _refreshOnce(token.refreshToken)
        .whenComplete(() => _inFlightRefresh = null);
  }

  /// 判断一次请求使用的 access token 是否仍属于当前会话。
  bool isCurrentAccessToken(String accessToken) {
    return _repository.isCurrentAccessToken(accessToken);
  }

  /// 刷新并写回仓库，供 [_inFlightRefresh] 单飞去重。
  ///
  /// 写回前由 [TokenRepository.saveRefreshedToken] 做 CAS：只有这次刷新基于的
  /// refresh token 仍是仓库当前令牌时才接受结果，否则作废——
  ///
  /// - 重新登录：切换账号时旧账号的令牌会覆盖新令牌，造成数据串号
  /// - 登出：令牌会在 [TokenRepository.clearToken] 之后被写回，下次启动
  ///   [LauncherBootService] 读到它会把用户重新判定为已登录
  ///
  /// 请求本身无法取消，拦截点只能是写回。
  Future<String> _refreshOnce(String refreshTokenUsed) async {
    final Code2TokenData refreshed;
    try {
      refreshed = await _refreshToken(refreshTokenUsed);
    } on NetworkException catch (error) {
      // 只有当前令牌的确定性拒绝才算登录失效；旧刷新不得误伤新登录的会话。
      if (isCredentialFailure(error) &&
          _repository.isCurrentRefreshToken(refreshTokenUsed)) {
        _sessionController?.markUnauthenticated(
          reason: error.statusCode == 401
              ? 'refresh_rejected_401'
              : 'refresh_rejected_invalid_grant',
        );
      }
      rethrow;
    }
    final TokenData token = TokenData.fromCode2TokenData(refreshed);
    if (!await _repository.saveRefreshedToken(
      token,
      refreshTokenUsed: refreshTokenUsed,
    )) {
      // 期间令牌被替换或清除。重新登录时 join 在此的调用者需要可用结果，返回
      // 仓库当前的令牌——那才是用户现在所处的会话。
      final TokenData? current = await _repository.getToken();
      if (current != null && !current.isAccessTokenExpired(skew: _tokenSkew)) {
        return current.accessToken;
      }
      // 会话状态不重复上报：登出路径已由登出编排置为未登录；重新登录时会话
      // 本就有效，这里只表示这一请求拿不到令牌。
      throw AppException('AUTH_EXPIRED', 'Token replaced or cleared');
    }
    return token.accessToken;
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
    final ({int statusCode, String body}) effective =
        _unwrapTokenResponse(response);
    if (effective.statusCode >= 200 && effective.statusCode < 300) {
      return Code2TokenData.fromJson(json.decode(effective.body));
    }
    throw NetworkException.http(
      statusCode: effective.statusCode,
      uri: uri,
      responseBody: effective.body,
    );
  }

  /// 还原 token 端点响应的真实状态码与响应体——纯转换，不携带请求上下文。
  ///
  /// 网关可能把上游错误包在 HTTP 200 里：
  /// `{"error_error":{"http_status_code":400,"http_body":"{\"error\":...}"}}`。
  /// 这里把包装（及未包装的 OAuth 错误体）还原成真实状态码。
  ({int statusCode, String body}) _unwrapTokenResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return (statusCode: response.statusCode, body: response.body);
    }
    final dynamic decoded = json.decode(response.body);
    if (decoded is Map<String, dynamic>) {
      final dynamic wrapped = decoded['error_error'];
      if (wrapped is Map<String, dynamic>) {
        final dynamic embeddedStatus = wrapped['http_status_code'];
        final dynamic embeddedBody = wrapped['http_body'];
        return (
          statusCode: embeddedStatus is int ? embeddedStatus : 400,
          body: embeddedBody is String
              ? embeddedBody
              : json.encode(embeddedBody ?? wrapped),
        );
      }
      // 未包装的 OAuth 错误体（如直接 200 返回 invalid_grant）同样按失败处理。
      final dynamic oauthError = decoded['error'];
      if (oauthError is String && oauthError.isNotEmpty) {
        return (statusCode: 400, body: response.body);
      }
      return (statusCode: response.statusCode, body: response.body);
    }
    throw JSONResolveException(
      message: 'Token endpoint returned non-object JSON',
    );
  }

  /// 是否为确定性凭证失败的唯一出处。
  ///
  /// 网络不可达、5xx 等瞬时错误不算凭证失败——此时凭证大概率仍
  /// 有效，只是无法验证，不应把用户导向「重新登录」。
  static bool isCredentialFailure(Object error) {
    if (error is AppException && error.code == 'AUTH_EXPIRED') {
      return true;
    }
    if (error is NetworkException) {
      if (error.statusCode == 401) {
        return true;
      }
      final String? body = error.responseBody;
      if (body != null && body.isNotEmpty) {
        try {
          final dynamic decoded = json.decode(body);
          return decoded is Map<String, dynamic> &&
              decoded['error'] == _invalidGrantError;
        } on FormatException {
          // 非 JSON 响应体无法证明凭证失效，按瞬时错误处理。
        }
      }
    }
    return false;
  }
}
