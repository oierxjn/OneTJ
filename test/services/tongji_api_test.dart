import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/models/token_data.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/tongji.dart';

TokenData _validToken({
  String accessToken = 'access-token',
  String refreshToken = 'refresh-token',
}) {
  return TokenData(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: 'Bearer',
    scope: 'scope',
    idToken: 'id-token',
    sessionState: 'session-state',
    accessTokenExpiresIn: 3600,
    refreshTokenExpiresIn: 7200,
    issuedAt: DateTime.now(),
  );
}

/// 一个装好令牌、注入假 HTTP 的 [TongjiApi]，以及它共享的 [SessionController]。
class _Harness {
  _Harness(this.api, this.session);

  final TongjiApi api;
  final SessionController session;
}

/// 构造返回 [statusCode] 的 [TongjiApi]。
///
/// 令牌预置为未过期，使 `getValidAccessToken()` 直接返回而不发起刷新请求，
/// 从而把测试聚焦在 [TongjiApi] 自身对响应状态码的处理上。
Future<_Harness> _harness(int statusCode, {String responseBody = '{}'}) async {
  final SessionController session = SessionController()
    ..completeBoot(AuthStatus.authenticated);
  final TokenRepository repository =
      TokenRepository(storage: InMemoryTokenStorage());
  await repository.saveToken(_validToken());
  return _Harness(
    TongjiApi(
      auth: AuthTokenProvider(repository: repository),
      sessionController: session,
      httpGet: (
        Uri uri, {
        Map<String, String>? headers,
        String loggerName = 'Http',
      }) async =>
          http.Response(responseBody, statusCode),
      httpPost: (
        Uri uri, {
        Map<String, String>? headers,
        Object? body,
        Encoding? encoding,
        String loggerName = 'Http',
      }) async =>
          http.Response(responseBody, statusCode),
    ),
    session,
  );
}

void main() {
  group('TongjiApi 状态码与会话上报', () {
    test('401 时标记为未登录', () async {
      final _Harness h = await _harness(401);

      await expectLater(
          h.api.fetchCetScores(), throwsA(isA<NetworkException>()));

      expect(h.session.status, AuthStatus.unauthenticated);
      expect(h.session.lastReason, 'http_401');
    });

    test('旧请求的 401 不影响重新登录后的会话', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.authenticated);
      final TokenRepository repository =
          TokenRepository(storage: InMemoryTokenStorage());
      await repository.saveToken(_validToken());
      final TongjiApi api = TongjiApi(
        auth: AuthTokenProvider(repository: repository),
        sessionController: session,
        httpGet: (
          Uri uri, {
          Map<String, String>? headers,
          String loggerName = 'Http',
        }) async {
          await repository.saveToken(_validToken(
            accessToken: 'brand-new-access',
            refreshToken: 'brand-new-refresh',
          ));
          session.markAuthenticated();
          return http.Response('{}', 401);
        },
      );

      await expectLater(api.fetchCetScores(), throwsA(isA<NetworkException>()));

      expect((await repository.getToken())?.accessToken, 'brand-new-access');
      expect(session.status, AuthStatus.authenticated);
    });

    test('403 不翻转会话状态', () async {
      final _Harness h = await _harness(403);

      await expectLater(
          h.api.fetchCetScores(), throwsA(isA<NetworkException>()));

      expect(h.session.status, AuthStatus.authenticated);
    });

    test('5xx 等瞬时错误不翻转会话状态', () async {
      final _Harness h = await _harness(500);

      await expectLater(
          h.api.fetchCetScores(), throwsA(isA<NetworkException>()));

      expect(h.session.status, AuthStatus.authenticated);
    });

    test('2xx 时保持登录态并解析数据', () async {
      final _Harness h = await _harness(
        200,
        responseBody: json.encode(<String, Object?>{
          'data': <String, Object?>{'cet': <String, Object?>{}},
        }),
      );

      await h.api.fetchCetScores();

      expect(h.session.status, AuthStatus.authenticated);
    });

    test('响应体非法 JSON 时抛 JSONResolveException 且不动会话', () async {
      final _Harness h = await _harness(200, responseBody: 'not-json');

      await expectLater(
          h.api.fetchCetScores(), throwsA(isA<JSONResolveException>()));

      expect(h.session.status, AuthStatus.authenticated);
    });

    test('传输层异常被包装为 NetworkException 且不动会话', () async {
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.authenticated);
      final TokenRepository repository =
          TokenRepository(storage: InMemoryTokenStorage());
      await repository.saveToken(_validToken());
      final TongjiApi api = TongjiApi(
        auth: AuthTokenProvider(repository: repository),
        sessionController: session,
        httpGet: (
          Uri uri, {
          Map<String, String>? headers,
          String loggerName = 'Http',
        }) async =>
            throw const SocketExceptionStub(),
      );

      await expectLater(api.fetchCetScores(), throwsA(isA<NetworkException>()));

      expect(session.status, AuthStatus.authenticated);
    });
  });

  group('TongjiApi 请求构造', () {
    test('GET 携带 Bearer 令牌', () async {
      final TokenRepository repository =
          TokenRepository(storage: InMemoryTokenStorage());
      await repository.saveToken(_validToken());
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.authenticated);
      Map<String, String>? capturedHeaders;
      final TongjiApi api = TongjiApi(
        auth: AuthTokenProvider(repository: repository),
        sessionController: session,
        httpGet: (
          Uri uri, {
          Map<String, String>? headers,
          String loggerName = 'Http',
        }) async {
          capturedHeaders = headers;
          return http.Response('{}', 200);
        },
      );

      await expectLater(api.fetchCetScores(), throwsA(anything));

      expect(capturedHeaders?['Authorization'], 'Bearer access-token');
    });
  });
}

/// 传输层失败的占位异常，用于验证异常被包装而非原样抛出。
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
