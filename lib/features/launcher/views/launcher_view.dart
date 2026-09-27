import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/features/launcher/view_models/launcher_view_model.dart';
import 'package:onetj/models/settings_defaults.dart';

class LauncherView extends StatefulWidget {
  const LauncherView({super.key, required this.viewModel});

  final LauncherViewModel viewModel;

  @override
  State<LauncherView> createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> {
  late final LauncherViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    // 引导结果通过 SessionController 发布，跳转由路由守卫完成，此处无需订阅事件。
    // 不做 static future 缓存：引导失败后用户重试需要能再次执行 initialize()。
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          final LauncherBootFailure? failure = _viewModel.failure;
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildWallpaper(),
              if (failure != null) _buildBootFailureOverlay(failure),
            ],
          );
        },
      ),
    );
  }

  /// 引导失败面板：提示用户重试或退出，避免永久停留在启动页。
  Widget _buildBootFailureOverlay(LauncherBootFailure failure) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.scrim.withValues(alpha: 0.6),
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.error_outline, color: colors.error, size: 40),
                const SizedBox(height: 16),
                Text(
                  l10n.launcherBootFailedTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.launcherBootFailedMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: _viewModel.isInitializing ? null : _exitApp,
                      child: Text(l10n.launcherBootFailedExit),
                    ),
                    const SizedBox(width: 8),
                    // TODO(oierxjn): 「重新加载」只是重跑 LauncherViewModel.initialize，
                    // 并非真正的进程重启：已产生副作用的初始化步骤不会真正重试。
                    // 例如 WebViewEnvironmentService.initialize 在 try 之前就置位
                    // _initialized，其失败后重试会直接早退。若引导失败集中在这一步，
                    // 需要改为可重入（把标志置位移到成功后）或提供进程级重启。
                    // 另外桌面端 SystemNavigator.pop 无效果，此按钮是唯一出路。
                    FilledButton(
                      onPressed:
                          _viewModel.isInitializing ? null : _viewModel.initialize,
                      child: Text(l10n.launcherBootFailedRetry),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 退出应用。仅 Android 等移动平台支持通过 [SystemNavigator] 结束进程；
  /// 桌面端无此语义，调用无效但不会崩溃。
  void _exitApp() {
    SystemNavigator.pop();
  }

  Widget _buildWallpaper() {
    final String? assetPath = _viewModel.wallpaperAssetPath;
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultWallpaper(),
      );
    }
    final String? customPath = _viewModel.wallpaperFilePath;
    if (customPath != null) {
      return Image.file(
        File(customPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultWallpaper(),
      );
    }
    return _defaultWallpaper();
  }

  Widget _defaultWallpaper() {
    return Image.asset(
      kDefaultLaunchWallpaperAsset,
      fit: BoxFit.cover,
    );
  }
}
