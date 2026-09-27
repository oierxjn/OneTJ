import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/models/token_data.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';

TokenData _buildToken({
  required int accessTokenExpiresIn,
  required int refreshTokenExpiresIn,
  DateTime? issuedAt,
}) {
  return TokenData(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'Bearer',
    scope: 'scope',
    idToken: 'id-token',
    sessionState: 'session-state',
    accessTokenExpiresIn: accessTokenExpiresIn,
    refreshTokenExpiresIn: refreshTokenExpiresIn,
    issuedAt: issuedAt ?? DateTime.now(),
  );
}

void main() {
  late TokenRepository repository;
  late AuthTokenProvider provider;

  setUp(() {
    repository = TokenRepository(storage: InMemoryTokenStorage());
    provider = AuthTokenProvider(repository: repository);
  });

  group('AuthTokenProvider.getValidAccessToken', () {
    test('没有 token 时抛出 AUTH_REQUIRED', () async {
      await expectLater(
        provider.getValidAccessToken(),
        throwsA(
          isA<AppException>().having(
            (AppException e) => e.code,
            'code',
            'AUTH_REQUIRED',
          ),
        ),
      );
    });

    test('access token 未过期时直接返回', () async {
      await repository.saveToken(
        _buildToken(
          accessTokenExpiresIn: 3600,
          refreshTokenExpiresIn: 7200,
        ),
      );

      final String token = await provider.getValidAccessToken();

      expect(token, 'access-token');
    });

    test('access 与 refresh token 均过期时抛出 AUTH_EXPIRED', () async {
      await repository.saveToken(
        _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: -7200,
        ),
      );

      await expectLater(
        provider.getValidAccessToken(),
        throwsA(
          isA<AppException>().having(
            (AppException e) => e.code,
            'code',
            'AUTH_EXPIRED',
          ),
        ),
      );
    });
  });

  group('AuthTokenProvider 向会话状态上报失效', () {
    late SessionController session;

    setUp(() {
      session = SessionController()..completeBoot(AuthStatus.authenticated);
      provider = AuthTokenProvider(
        repository: repository,
        sessionController: session,
      );
    });

    test('缺少令牌时标记为未登录', () async {
      await expectLater(
        provider.getValidAccessToken(),
        throwsA(isA<AppException>()),
      );

      expect(session.status, AuthStatus.unauthenticated);
      expect(session.lastReason, 'missing_token');
    });

    test('refresh token 过期时标记为未登录', () async {
      await repository.saveToken(
        _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: -7200,
        ),
      );

      await expectLater(
        provider.getValidAccessToken(),
        throwsA(isA<AppException>()),
      );

      expect(session.status, AuthStatus.unauthenticated);
      expect(session.lastReason, 'refresh_token_expired');
    });

    test('access token 有效时不会翻转会话状态', () async {
      await repository.saveToken(
        _buildToken(
          accessTokenExpiresIn: 3600,
          refreshTokenExpiresIn: 7200,
        ),
      );

      await provider.getValidAccessToken();

      expect(session.status, AuthStatus.authenticated);
    });
  });

  group('AuthTokenProvider 刷新被服务端拒绝', () {
    late SessionController session;

    /// 本地看 refresh token 未过期（access 已过期），从而走到真实刷新请求。
    TokenData expiredAccessToken() => _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: 7200,
        );

    setUp(() {
      session = SessionController()..completeBoot(AuthStatus.authenticated);
    });

    AuthTokenProvider providerWithResponse(int statusCode) {
      return AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async =>
            http.Response('{}', statusCode),
      );
    }

    test('刷新返回 401 时标记为未登录', () async {
      await repository.saveToken(expiredAccessToken());
      final AuthTokenProvider provider = providerWithResponse(401);

      await expectLater(
        provider.getValidAccessToken(),
        throwsA(isA<NetworkException>()),
      );

      expect(session.status, AuthStatus.unauthenticated);
      expect(session.lastReason, 'refresh_rejected_401');
    });

    test('刷新返回 500 等瞬时错误时不登出用户', () async {
      await repository.saveToken(expiredAccessToken());
      final AuthTokenProvider provider = providerWithResponse(500);

      await expectLater(
        provider.getValidAccessToken(),
        throwsA(isA<NetworkException>()),
      );

      expect(session.status, AuthStatus.authenticated);
    });

    test('刷新成功时写回新令牌且不翻转会话状态', () async {
      await repository.saveToken(expiredAccessToken());
      final AuthTokenProvider provider = AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async =>
            http.Response(
          '{"access_token":"new-access","refresh_token":"new-refresh",'
          '"token_type":"Bearer","scope":"s","id_token":"i",'
          '"session_state":"ss","expires_in":3600,"refresh_expires_in":7200}',
          200,
        ),
      );

      final String token = await provider.getValidAccessToken();

      expect(token, 'new-access');
      expect(session.status, AuthStatus.authenticated);
    });
  });
}
