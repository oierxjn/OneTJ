import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/login/view_models/login_view_model.dart';

void main() {
  test('登录跳转日志不记录查询参数值', () {
    const String authorizationCode = 'authorization-code-should-not-be-logged';
    const String state = 'state-should-not-be-logged';
    final Map<String, Object?> context = LoginViewModel.redirectUriLogContext(
      WebUri(
        'https://example.com/oauth/callback?code=$authorizationCode&state=$state',
      ),
    );

    expect(context['scheme'], 'https');
    expect(context['host'], 'example.com');
    expect(context['path'], '/oauth/callback');
    expect(context['queryParameterNames'], <String>['code', 'state']);
    expect(context.values.join(), isNot(contains(authorizationCode)));
    expect(context.values.join(), isNot(contains(state)));
  });
}
