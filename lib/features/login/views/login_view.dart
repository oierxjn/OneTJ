import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/session/session_controller.dart';

import '../view_models/login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    required this.viewModel,
    required this.sessionStatus,
    this.sessionLastReason,
    this.webViewEnvironment,
  });

  final LoginViewModel viewModel;
  final AuthStatus sessionStatus;
  final String? sessionLastReason;
  final WebViewEnvironment? webViewEnvironment;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel viewModel;
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModel;

    // 订阅Stream事件。登录成功不再经由此处跳转：视图模型更新会话状态后，
    // 路由守卫会把当前登录页替换为回跳目标或首页。
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
        return;
      }
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? bannerText = _bannerText(context);
    return Scaffold(
      body: Column(
        children: [
          if (bannerText != null)
            Material(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bannerText,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
        ],
      ),
    );
  }

  /// 按进入登录页的原因选择横幅文案；无明确原因时不显示。
  String? _bannerText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.sessionStatus == AuthStatus.expired) {
      return l10n.loginExpiredBanner;
    }
    if (widget.sessionStatus == AuthStatus.guest &&
        widget.sessionLastReason == 'guard_redirect') {
      return l10n.loginRequiredBanner;
    }
    return null;
  }
}
