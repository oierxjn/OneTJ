import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/data/code2token.dart';

void main() {
  group('Code2TokenData.fromJson', () {
    test('正常 JSON 解析成功', () {
      final data = Code2TokenData.fromJson({
        'access_token': 'access-123',
        'token_type': 'Bearer',
        'expires_in': 3600,
        'refresh_token': 'refresh-456',
        'refresh_expires_in': 86400,
        'not-before-policy': 0,
        'id_token': 'id-789',
        'scope': 'openid profile',
        'session_state': 'session-xyz',
      });
      expect(data.accessToken, 'access-123');
      expect(data.refreshToken, 'refresh-456');
      expect(data.expiresIn, 3600);
    });

    test('缺少 access_token 时抛出 Code2TokenParseException', () {
      expect(
        () => Code2TokenData.fromJson({
          'token_type': 'Bearer',
          'expires_in': 3600,
          'refresh_token': 'refresh-456',
          'refresh_expires_in': 86400,
          'scope': 'openid',
          'session_state': 's',
        }),
        throwsA(isA<Code2TokenParseException>()
            .having((e) => e.field, 'field', Code2TokenField.accessToken)
            .having((e) => e.reason, 'reason', Code2TokenParseReason.missing)),
      );
    });

    test('缺少 scope 时抛出 Code2TokenParseException', () {
      // refresh_token 响应中 scope 常常缺失，这是最需要排查的场景
      expect(
        () => Code2TokenData.fromJson({
          'access_token': 'access-123',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'refresh_token': 'refresh-456',
          'refresh_expires_in': 86400,
          'session_state': 's',
          // scope 缺失
        }),
        throwsA(isA<Code2TokenParseException>()
            .having((e) => e.field, 'field', Code2TokenField.scope)
            .having((e) => e.reason, 'reason', Code2TokenParseReason.missing)),
      );
    });

    test('缺少 session_state 时抛出 Code2TokenParseException', () {
      expect(
        () => Code2TokenData.fromJson({
          'access_token': 'access-123',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'refresh_token': 'refresh-456',
          'refresh_expires_in': 86400,
          'scope': 'openid',
          // session_state 缺失
        }),
        throwsA(isA<Code2TokenParseException>()
            .having((e) => e.field, 'field', Code2TokenField.sessionState)
            .having((e) => e.reason, 'reason', Code2TokenParseReason.missing)),
      );
    });

    test('expires_in 类型错误时抛出 typeMismatch', () {
      expect(
        () => Code2TokenData.fromJson({
          'access_token': 'access-123',
          'token_type': 'Bearer',
          'expires_in': 'not_a_number', // 类型错误
          'refresh_token': 'refresh-456',
          'refresh_expires_in': 86400,
          'scope': 'openid',
          'session_state': 's',
        }),
        throwsA(isA<Code2TokenParseException>()
            .having((e) => e.field, 'field', Code2TokenField.expiresIn)
            .having((e) => e.reason, 'reason', Code2TokenParseReason.typeMismatch)),
      );
    });

    test('异常 toString 脱敏 token 字段', () {
      Code2TokenParseException? caught;
      try {
        Code2TokenData.fromJson({
          'access_token': 'access-123',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'refresh_token': 'refresh-456',
          'refresh_expires_in': 86400,
          'id_token': 'id-789',
          'session_state': 's',
          // scope 缺失
        });
      } catch (e) {
        caught = e as Code2TokenParseException;
      }
      expect(caught, isNotNull);
      final msg = caught.toString();
      expect(msg, contains('scope'));
      expect(msg, contains('missing'));
      expect(msg, contains('Code2TokenParseException'));
      expect(msg, contains('<redacted>'));
      expect(msg, isNot(contains('access-123')));
      expect(msg, isNot(contains('refresh-456')));
      expect(msg, isNot(contains('id-789')));
      // 非敏感字段正常显示
      expect(msg, contains('Bearer'));
      expect(msg, contains('3600'));
    });

    test('可选字段缺失时使用默认值', () {
      final data = Code2TokenData.fromJson({
        'access_token': 'access-123',
        'token_type': 'Bearer',
        'expires_in': 3600,
        'refresh_token': 'refresh-456',
        'refresh_expires_in': 86400,
        'scope': 'openid',
        'session_state': 's',
        // id_token 和 not-before-policy 缺失，用默认值
      });
      expect(data.idToken, '');
      expect(data.notBeforePolicy, 0);
    });

    test('完整 JSON 包含所有字段', () {
      final data = Code2TokenData.fromJson({
        'access_token': 'access-abc',
        'token_type': 'bearer',
        'expires_in': 1800,
        'refresh_token': 'refresh-xyz',
        'refresh_expires_in': 43200,
        'not-before-policy': 123,
        'id_token': 'id-456',
        'scope': 'openid',
        'session_state': 'abc-123',
      });
      expect(data.accessToken, 'access-abc');
      expect(data.tokenType, 'bearer');
      expect(data.expiresIn, 1800);
      expect(data.refreshToken, 'refresh-xyz');
      expect(data.refreshExpiresIn, 43200);
      expect(data.notBeforePolicy, 123);
      expect(data.idToken, 'id-456');
      expect(data.scope, 'openid');
      expect(data.sessionState, 'abc-123');
    });
  });
}