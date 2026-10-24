import 'dart:async';
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

  group('AuthTokenProvider 并发刷新去重', () {
    late SessionController session;

    /// access 已过期、refresh 仍有效，从而走到真实刷新请求。
    TokenData expiredAccessToken() => _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: 7200,
        );

    const String refreshBody =
        '{"access_token":"new-access","refresh_token":"new-refresh",'
        '"token_type":"Bearer","scope":"s","id_token":"i",'
        '"session_state":"ss","expires_in":3600,"refresh_expires_in":7200}';

    setUp(() {
      session = SessionController()..completeBoot(AuthStatus.authenticated);
    });

    /// 构造一个会阻塞在刷新上的 provider，返回它与调用计数。
    ///
    /// [gate] 未完成前不发响应，使并发调用必然落在同一个刷新窗口内，
    /// 从而确定性地覆盖「服务端按单次轮换 refresh token」的场景。
    ({
      AuthTokenProvider provider,
      int Function() callCount,
      void Function() release,
    }) buildBlockingProvider() {
      int calls = 0;
      final Completer<void> gate = Completer<void>();
      final AuthTokenProvider created = AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async {
          calls += 1;
          await gate.future;
          return http.Response(refreshBody, 200);
        },
      );
      return (
        provider: created,
        callCount: () => calls,
        release: gate.complete,
      );
    }

    test('并发调用只发一次刷新请求', () async {
      await repository.saveToken(expiredAccessToken());
      final (
        provider: AuthTokenProvider provider,
        callCount: int Function() callCount,
        release: void Function() release,
      ) = buildBlockingProvider();

      final List<Future<String>> pending = <Future<String>>[
        provider.getValidAccessToken(),
        provider.getValidAccessToken(),
        provider.getValidAccessToken(),
      ];
      // 让三个调用都跑到刷新处再放行，确保窗口重叠。
      await Future<void>.delayed(Duration.zero);
      release();

      final List<String> tokens = await Future.wait(pending);

      expect(callCount(), 1, reason: '刷新请求应只发一次');
      expect(tokens, <String>['new-access', 'new-access', 'new-access']);
      expect(session.status, AuthStatus.authenticated);
    });

    test('刷新失败时所有并发调用共享同一个异常', () async {
      await repository.saveToken(expiredAccessToken());
      int calls = 0;
      final Completer<void> gate = Completer<void>();
      final AuthTokenProvider provider = AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async {
          calls += 1;
          await gate.future;
          // 第二次使用同一个 refresh token 会被服务端拒绝。
          return http.Response('{}', 401);
        },
      );

      final List<Future<String>> pending = <Future<String>>[
        provider.getValidAccessToken(),
        provider.getValidAccessToken(),
      ];
      await Future<void>.delayed(Duration.zero);
      gate.complete();

      for (final Future<String> call in pending) {
        await expectLater(call, throwsA(isA<NetworkException>()));
      }

      expect(calls, 1, reason: '失败的刷新同样只发一次');
      expect(session.status, AuthStatus.unauthenticated);
      expect(session.lastReason, 'refresh_rejected_401');
    });

    test('刷新在飞期间重新登录：旧结果不覆盖新令牌', () async {
      await repository.saveToken(expiredAccessToken());
      final Completer<void> refreshGate = Completer<void>();
      // 刷新与登录交换共用同一个可注入入口，靠 grant_type 区分。
      final AuthTokenProvider provider = AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async {
          final Map<String, dynamic> fields =
              (body! as Map<String, dynamic>).cast<String, dynamic>();
          if (fields['grant_type'] == 'authorization_code') {
            return http.Response(
              '{"access_token":"brand-new-access",'
              '"refresh_token":"brand-new-refresh",'
              '"token_type":"Bearer","scope":"s","id_token":"i",'
              '"session_state":"ss","expires_in":3600,'
              '"refresh_expires_in":7200}',
              200,
            );
          }
          await refreshGate.future;
          return http.Response(
            '{"access_token":"stale-access","refresh_token":"stale-refresh",'
            '"token_type":"Bearer","scope":"s","id_token":"i",'
            '"session_state":"ss","expires_in":3600,"refresh_expires_in":7200}',
            200,
          );
        },
      );

      // 起飞刷新（access 已过期必然触发），随后在其挂起期间完成重新登录。
      final Future<String> pendingRefresh = provider.getValidAccessToken();
      await Future<void>.delayed(Duration.zero);
      await provider.exchangeCode('new-code');
      refreshGate.complete();

      // 在飞的调用者拿到的是当前有效令牌，而不是基于旧 refresh token 的结果。
      expect(await pendingRefresh, 'brand-new-access');

      final TokenData stored = (await repository.getToken())!;
      expect(stored.accessToken, 'brand-new-access',
          reason: '陈旧的刷新结果不应覆盖新登录写入的令牌');
      expect(stored.refreshToken, 'brand-new-refresh');
    });

    test('旧刷新在新登录后返回 401：不误登出新会话', () async {
      await repository.saveToken(expiredAccessToken());
      final Completer<void> refreshGate = Completer<void>();
      final AuthTokenProvider provider = AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async {
          final Map<String, dynamic> fields =
              (body! as Map<String, dynamic>).cast<String, dynamic>();
          if (fields['grant_type'] == 'authorization_code') {
            return http.Response(
              '{"access_token":"brand-new-access",'
              '"refresh_token":"brand-new-refresh",'
              '"token_type":"Bearer","scope":"s","id_token":"i",'
              '"session_state":"ss","expires_in":3600,'
              '"refresh_expires_in":7200}',
              200,
            );
          }
          await refreshGate.future;
          return http.Response('{}', 401);
        },
      );

      final Future<String> pendingRefresh = provider.getValidAccessToken();
      await Future<void>.delayed(Duration.zero);
      await provider.exchangeCode('new-code');
      session.markAuthenticated();
      refreshGate.complete();

      await expectLater(pendingRefresh, throwsA(isA<NetworkException>()));
      final TokenData stored = (await repository.getToken())!;
      expect(stored.accessToken, 'brand-new-access');
      expect(stored.refreshToken, 'brand-new-refresh');
      expect(session.status, AuthStatus.authenticated);
    });

    test('重新登录失败时在飞刷新仍然有效', () async {
      await repository.saveToken(expiredAccessToken());
      final Completer<void> refreshGate = Completer<void>();
      final AuthTokenProvider provider = AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async {
          final Map<String, dynamic> fields =
              (body! as Map<String, dynamic>).cast<String, dynamic>();
          if (fields['grant_type'] == 'authorization_code') {
            return http.Response('{}', 400);
          }
          await refreshGate.future;
          return http.Response(
            '{"access_token":"rescued-access","refresh_token":"rescued-refresh",'
            '"token_type":"Bearer","scope":"s","id_token":"i",'
            '"session_state":"ss","expires_in":3600,"refresh_expires_in":7200}',
            200,
          );
        },
      );

      final Future<String> pendingRefresh = provider.getValidAccessToken();
      await Future<void>.delayed(Duration.zero);
      await expectLater(
        provider.exchangeCode('bad-code'),
        throwsA(isA<NetworkException>()),
      );
      refreshGate.complete();

      // 交换失败没有替换仓库里的 refresh token，在飞刷新照常写回——否则会
      // 平白丢掉一个可用令牌。
      expect(await pendingRefresh, 'rescued-access');
      final TokenData stored = (await repository.getToken())!;
      expect(stored.accessToken, 'rescued-access');
    });

    test('刷新在飞期间登出：令牌不会被写回', () async {
      await repository.saveToken(expiredAccessToken());
      final Completer<void> refreshGate = Completer<void>();
      final SessionController session = SessionController()
        ..completeBoot(AuthStatus.authenticated);
      final AuthTokenProvider provider = AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async {
          await refreshGate.future;
          return http.Response(
            '{"access_token":"resurrected-access","refresh_token":"r",'
            '"token_type":"Bearer","scope":"s","id_token":"i",'
            '"session_state":"ss","expires_in":3600,"refresh_expires_in":7200}',
            200,
          );
        },
      );

      final Future<String> pendingRefresh = provider.getValidAccessToken();
      await Future<void>.delayed(Duration.zero);
      // 登出：LogoutService 直接清仓库，不经过 token provider。
      await repository.clearToken();
      session.markSignedOut();
      refreshGate.complete();

      await expectLater(pendingRefresh, throwsA(isA<AppException>()));

      expect(await repository.getToken(), isNull,
          reason: '登出后在飞刷新不得把令牌写回，否则下次启动会被判定为已登录');
    });

    test('并发调用期间登出：全部失败且仓库保持为空', () async {
      await repository.saveToken(expiredAccessToken());
      final Completer<void> refreshGate = Completer<void>();
      final AuthTokenProvider provider = AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async {
          await refreshGate.future;
          return http.Response(
            '{"access_token":"resurrected-access","refresh_token":"r",'
            '"token_type":"Bearer","scope":"s","id_token":"i",'
            '"session_state":"ss","expires_in":3600,"refresh_expires_in":7200}',
            200,
          );
        },
      );

      // 单飞去重会把这三次调用合并到同一个在飞刷新上。
      final List<Future<String>> pending = <Future<String>>[
        provider.getValidAccessToken(),
        provider.getValidAccessToken(),
        provider.getValidAccessToken(),
      ];
      await Future<void>.delayed(Duration.zero);
      await repository.clearToken();
      refreshGate.complete();

      for (final Future<String> call in pending) {
        await expectLater(call, throwsA(isA<AppException>()));
      }
      expect(await repository.getToken(), isNull);
    });

    test('刷新完成后新一轮调用会重新发起刷新', () async {
      await repository.saveToken(expiredAccessToken());
      int calls = 0;
      // 每次刷新都返回一个 access token 仍然过期的结果，模拟持续过期场景，
      // 从而验证单飞窗口确实在完成后关闭，而不是被永久缓存。
      final AuthTokenProvider provider = AuthTokenProvider(
        repository: repository,
        sessionController: session,
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async {
          calls += 1;
          return http.Response(
            '{"access_token":"new-access","refresh_token":"new-refresh",'
            '"token_type":"Bearer","scope":"s","id_token":"i",'
            '"session_state":"ss","expires_in":-3600,"refresh_expires_in":7200}',
            200,
          );
        },
      );

      await provider.getValidAccessToken();
      await provider.getValidAccessToken();

      expect(calls, 2, reason: '前一次刷新结束后应允许新的刷新');
    });
  });
}
