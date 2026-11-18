import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/login/application/login_data_service.dart';
import 'package:onetj/features/login/models/login_model.dart';
import 'package:onetj/features/login/view_models/login_view_model.dart';
import 'package:onetj/features/login/views/login_view.dart';
import 'package:onetj/features/settings/application/logout_service.dart';
import 'package:onetj/l10n/app_localizations.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';

/// 登录页测试不触发登出清理，LogoutService 用空实现占位。
class _FakeLogoutService implements LogoutService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 测试环境无 WebView 平台实现，注入只渲染占位框的桩件，
/// 让登录页其余部分正常构建。
class _FakeInAppWebViewPlatform extends InAppWebViewPlatform {
  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return _FakePlatformInAppWebViewWidget(params);
  }
}

class _FakePlatformInAppWebViewWidget extends PlatformInAppWebViewWidget {
  _FakePlatformInAppWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}
}

LoginViewModel _buildViewModel() {
  return LoginViewModel(
    dataService: LoginDataService(
      model: LoginModel(state: 'test-state'),
      authTokenProvider: AuthTokenProvider(
        repository: TokenRepository(storage: InMemoryTokenStorage()),
      ),
    ),
    sessionController: SessionController()
      ..completeBoot(AuthStatus.expired),
    logoutService: _FakeLogoutService(),
  );
}

void main() {
  setUpAll(() {
    InAppWebViewPlatform.instance = _FakeInAppWebViewPlatform();
  });

  testWidgets('进入登录页清掉上一页遗留的 SnackBar 队列', (tester) async {
    final GlobalKey<NavigatorState> navigatorKey =
        GlobalKey<NavigatorState>();
    final LoginViewModel loginViewModel = _buildViewModel();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LoginView(viewModel: loginViewModel),
                    ),
                  );
                },
                child: const Text('去登录'),
              ),
            ),
          ),
        ),
      ),
    );

    // 模拟仪表盘遗留的应用级提示队列：两条排队展示。
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.of(navigatorKey.currentContext!);
    messenger.showSnackBar(const SnackBar(content: Text('遗留提示一')));
    messenger.showSnackBar(const SnackBar(content: Text('遗留提示二')));
    await tester.pump();
    expect(find.text('遗留提示一'), findsOneWidget);

    await tester.tap(find.text('去登录'));
    await tester.pumpAndSettle();

    // 登录页已展示，遗留提示（含排队中的第二条）全部被清掉。
    expect(find.text('以游客身份继续'), findsOneWidget);
    expect(find.text('遗留提示一'), findsNothing);
    expect(find.text('遗留提示二'), findsNothing);
  });
}