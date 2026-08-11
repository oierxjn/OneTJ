import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/exception/app_exception.dart';
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
}
