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

  /// 当前在飞的那一次刷新，同一时刻至多一个。
  ///
  /// 去重范围是整个应用：本类以 `registerLazySingleton` 注册，这个实例字段
  /// 因此被所有调用方共享。
  ///
  /// 服务端按单次轮换 refresh token：一旦某个 refresh token 被用过就立即作废。
  /// 多个请求同时发现 access token 过期时若各自发一次刷新，后到的请求必然拿到
  /// 401，并被 [SessionController] 当成「登录失效」把用户踢回登录页。这里用
  /// 单飞（single-flight）保证同一时刻只有一次刷新在飞，后来者 join 同一个
  /// future，共用其结果或异常。
  ///
  /// 已知边界：请求本身无法取消（`Future` 不可取消），因此拦截点在写回而非
  /// 发送——见 [_tokenGeneration] 与 [_refreshOnce]。
  Future<String>? _inFlightRefresh;

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
      // 代次由 TokenRepository 在写入时自增，无需在此显式推进；交换失败时
      // 也不应推进，否则会作废在飞的刷新——那次刷新可能正带着有效令牌救场。
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
  ///
  /// 并发调用时刷新走单飞：同一时刻只有一次刷新请求在飞，后来者 join 同一个
  /// future，因此不会出现「后到的请求因 refresh token 已轮换而拿到 401」被
  /// 误判为登录失效的情况。
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
    return _inFlightRefresh ??= _refreshOnce(token)
        .whenComplete(() => _inFlightRefresh = null);
  }

  /// 用 refresh token 刷新并写回仓库，供 [_inFlightRefresh] 单飞去重。
  ///
  /// 若刷新期间令牌被替换或清除（[TokenRepository.generation] 已推进），说明这次
  /// 刷新基于的是已失效的 refresh token，结果不再写回：
  ///
  /// - 期间重新登录：否则切换账号时旧账号派生的令牌会覆盖新令牌，造成数据串号
  /// - 期间登出：否则令牌会在 [TokenRepository.clearToken] 之后被写回，下次启动
  ///   的 [LauncherBootService] 读到它会把用户重新判定为已登录
  Future<String> _refreshOnce(TokenData token) async {
    final int generationAtStart = _repository.generation;
    final Code2TokenData refreshed;
    try {
      refreshed = await _refreshToken(token.refreshToken);
    } on NetworkException catch (error) {
      // 见 [getValidAccessToken]：只有明确的 401 才算登录失效，瞬时故障不上报。
      if (error.statusCode == 401) {
        _sessionController?.markUnauthenticated(reason: 'refresh_rejected_401');
      }
      rethrow;
    }
    if (generationAtStart != _repository.generation) {
      // 令牌已在这期间被替换或清除，这份基于旧 refresh token 的结果作废。
      // 重新登录的情况下 join 在此的调用者仍需要可用结果，返回仓库当前令牌。
      final TokenData? current = await _repository.getToken();
      if (current != null && !current.isAccessTokenExpired(skew: _tokenSkew)) {
        return current.accessToken;
      }
      // 登出等情况没有可用令牌可返回：该请求确实无法服务，如实抛出。会话
      // 状态不重复上报——登出路径已由 LogoutService 置为未登录。
      throw AppException('AUTH_EXPIRED', 'Token replaced while refreshing');
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
