import 'package:flutter/material.dart';
import 'package:onetj/l10n/app_localizations.dart';

/// 数据页游客态登录引导空态。
///
/// 需登录才能拉取数据的页面（课表/成绩/四六级/考试）在游客态下展示本组件，
/// 替代数据内容；点击按钮跳转登录页。各页头部另放登录入口按钮。
class LoginPrompt extends StatelessWidget {
  const LoginPrompt({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.loginPromptTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.loginPromptSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login),
              label: Text(l10n.loginPromptAction),
            ),
          ],
        ),
      ),
    );
  }
}

/// 数据页头部的登录入口按钮（游客态替代刷新按钮）。
class LoginActionButton extends StatelessWidget {
  const LoginActionButton({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextButton.icon(
      onPressed: onLogin,
      icon: const Icon(Icons.login, size: 18),
      label: Text(l10n.loginPromptAction),
    );
  }
}