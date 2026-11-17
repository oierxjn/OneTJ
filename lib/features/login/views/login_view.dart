import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/features/settings/application/logout_service.dart';
import 'package:onetj/features/settings/models/event.dart';

import '../view_models/login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    required this.viewModel,
    this.webViewEnvironment,
  });

  final LoginViewModel viewModel;
  final WebViewEnvironment? webViewEnvironment;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel viewModel;
  StreamSubscription<UiEvent>? _eventSub;
  bool _residualSnackBarsCleared = false;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModel;

    // 订阅Stream事件。登录成功不再经由此处跳转：视图模型更新会话状态后，
    // 路由守卫会把当前登录页替换为首页。
    _eventSub = viewModel.events.listen((event) {
      if (event is ShowSnackBarEvent) {
        if (!mounted) return;
        if (event.code == AuthStateMismatchException.errorCode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context).authStateMismatch)),
          );
          return;
        }
        if (event.code == LogoutCleanupException.errorCode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context).logoutCleanupFailed)),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
        return;
      }
      if (event is LogoutCompletedWithWarningEvent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context).logoutResidualCleanupWarning)),
        );
        return;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 清掉上一页遗留的应用级 SnackBar 队列（#82）；
    // 只清一次，避免后续依赖变化误清本页提示。
    if (!_residualSnackBarsCleared) {
      _residualSnackBarsCleared = true;
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _continueAsGuest() async {
    final bool success = await viewModel.continueAsGuest();
    if (!success || !mounted) {
      return;
    }
    // 进入游客态后回首页，是否登录由用户决定。
    context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              webViewEnvironment: widget.webViewEnvironment,
              initialUrlRequest: URLRequest(
                url: WebUri(viewModel.authUri.toString()),
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                if (navigationAction.request.url == null) {
                  return NavigationActionPolicy.ALLOW;
                }
                return await viewModel.handleRedirectUri(
                    controller, navigationAction.request.url!);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: viewModel,
                  builder: (context, _) => OutlinedButton.icon(
                    onPressed:
                        viewModel.continuingAsGuest ? null : _continueAsGuest,
                    icon: const Icon(Icons.person_outline),
                    label: Text(l10n.continueAsGuest),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}