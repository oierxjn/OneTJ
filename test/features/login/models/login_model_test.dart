import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/features/login/models/login_model.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';

void main() {
  late LoginModel model;

  setUp(() {
    model = LoginModel(
      auth: AuthTokenProvider(
        repository: TokenRepository(storage: InMemoryTokenStorage()),
      ),
    );
  });

  test('非重定向URI返回false', () async {
    final bool handled = await model.exchangeCodeIfRedirect(
      WebUri('https://ids.tongji.edu.cn/some/page'),
    );

    expect(handled, isFalse);
  });

  test('重定向携带error时抛出AuthRedirectException并带上description', () async {
    await expectLater(
      model.exchangeCodeIfRedirect(
        WebUri(
          'https://fakeredir.jkljkluiouio.top'
          '?error=invalid_scope&error_description=Invalid+scopes&state=abc',
        ),
      ),
      throwsA(
        isA<AuthRedirectException>().having(
          (AuthRedirectException e) => e.message,
          'message',
          contains('invalid_scope'),
        ),
      ),
    );
  });

  test('重定向缺少code时抛出AuthRedirectException', () async {
    await expectLater(
      model.exchangeCodeIfRedirect(
        WebUri('https://fakeredir.jkljkluiouio.top?state=abc'),
      ),
      throwsA(
        isA<AuthRedirectException>().having(
          (AuthRedirectException e) => e.code,
          'code',
          AuthRedirectException.errorCode,
        ),
      ),
    );
  });

  test('state不匹配时抛出AuthStateMismatchException', () async {
    await expectLater(
      model.exchangeCodeIfRedirect(
        WebUri('https://fakeredir.jkljkluiouio.top?code=some-code&state=wrong'),
      ),
      throwsA(isA<AuthStateMismatchException>()),
    );
  });
}
