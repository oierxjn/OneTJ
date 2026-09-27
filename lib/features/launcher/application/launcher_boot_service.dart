import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/models/launch_wallpaper_ref.dart';
import 'package:onetj/models/settings_data.dart';
import 'package:onetj/models/token_data.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/hive_storage_service.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';
import 'package:onetj/services/webview_environment_service.dart';

/// 启动引导编排。
///
/// 负责按正确顺序完成 Hive / 主题 / WebView / 设置 / 令牌的初始化，
/// 并据此决定会话的初始鉴权状态与启动壁纸。
class LauncherBootService {
  LauncherBootService({
    required HiveStorageService hiveStorageService,
    required ThemeChangeNotifier themeChangeNotifier,
    required WebViewEnvironmentService webViewEnvironmentService,
    required SettingsRepository settingsRepository,
    required TokenRepository tokenRepository,
    required AuthTokenProvider authTokenProvider,
  })  : _hiveStorageService = hiveStorageService,
        _themeChangeNotifier = themeChangeNotifier,
        _webViewEnvironmentService = webViewEnvironmentService,
        _settingsRepository = settingsRepository,
        _tokenRepository = tokenRepository,
        _authTokenProvider = authTokenProvider;

  final HiveStorageService _hiveStorageService;
  final ThemeChangeNotifier _themeChangeNotifier;
  final WebViewEnvironmentService _webViewEnvironmentService;
  final SettingsRepository _settingsRepository;
  final TokenRepository _tokenRepository;
  final AuthTokenProvider _authTokenProvider;

  /// 完成启动初始化并返回初始会话状态。
  ///
  /// [onWallpaperResolved] 会在壁纸解析完成、而 WebView 初始化与令牌校验
  /// 尚未结束时立即回调，使调用方能尽早展示启动壁纸，不必等待后续步骤。
  ///
  /// 返回值仅供调用方调试与测试断言使用；真正驱动跳转的是本方法写入
  /// [SessionController] 的鉴权状态。
  Future<AuthStatus> run({
    void Function(LaunchWallpaperResolved? wallpaper)? onWallpaperResolved,
  }) async {
    await _hiveStorageService.initializeHive();

    // 在 Hive 路径正确初始化后立即加载主题偏好
    await _themeChangeNotifier.initialize();

    final Future<void> webViewInitFuture =
        _webViewEnvironmentService.initialize();
    final SettingsData settings = await _settingsRepository.getSettings(
      refreshFromStorage: true,
    );
    final LaunchWallpaperResolved? wallpaper =
        await _resolveWallpaper(settings.selectedLaunchWallpaperRef);
    onWallpaperResolved?.call(wallpaper);
    await webViewInitFuture;
    return _resolveInitialStatus();
  }

  Future<LaunchWallpaperResolved?> _resolveWallpaper(
    LaunchWallpaperRef wallpaperRef,
  ) async {
    final LaunchWallpaperResolved? resolved =
        await LaunchWallpaperFileService.resolveWallpaper(wallpaperRef);
    if (resolved == null) {
      AppLogger.info(
        'Launch wallpaper fallback to default by missing selected id',
        loggerName: 'LauncherBootService',
      );
      return null;
    }
    AppLogger.info(
      'Launch wallpaper resolved',
      loggerName: 'LauncherBootService',
      context: <String, Object?>{
        'filePath': resolved.filePath,
        'assetPath': resolved.assetPath,
      },
    );
    return resolved;
  }

  /// 通过判断 token 状态确定初始会话状态
  ///
  /// 如果 token 有效则返回 [AuthStatus.authenticated]，否则返回
  /// [AuthStatus.unauthenticated]。
  Future<AuthStatus> _resolveInitialStatus() async {
    final TokenData? token = await _tokenRepository.getToken(
      refreshFromStorage: true,
    );

    if (token == null) {
      AppLogger.info(
        'Resolved session as unauthenticated',
        loggerName: 'LauncherBootService',
        context: const <String, Object?>{'status': 'unauthenticated'},
      );
      return AuthStatus.unauthenticated;
    }

    try {
      await _authTokenProvider.getValidAccessToken();
      AppLogger.info(
        'Resolved session as authenticated',
        loggerName: 'LauncherBootService',
        context: const <String, Object?>{'status': 'authenticated'},
      );
      return AuthStatus.authenticated;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to resolve a valid token during launch',
        loggerName: 'LauncherBootService',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return AuthStatus.unauthenticated;
  }
}
