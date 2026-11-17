import 'dart:convert';

import 'package:onetj/app/exception/app_exception.dart';
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
  /// 返回值是初始鉴权状态的**唯一出口**：调用方（`LauncherViewModel`）会把它
  /// 交给 `SessionController.completeBoot`，再由路由守卫据此跳转。本方法自身
  /// 不写 `SessionController`——发布时机由调用方掌握（需等启动页最短展示时间）。
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
  /// 令牌有效返回 [AuthStatus.authenticated]；本机无令牌返回
  /// [AuthStatus.guest]（从未登录或已登出）；持有令牌但**确定性凭证失败**
  /// 返回 [AuthStatus.expired]（缓存仍可读，重新登录即可恢复）。
  ///
  /// 网络/瞬时错误不判失效：离线冷启动时 refresh token 往往仍有效，只是
  /// 此刻无法联网刷新。乐观判 authenticated 走缓存，与运行期「瞬时错误不
  /// 登出」一致；联网后首个真实请求会由 [AuthTokenProvider] 正确分类。
  Future<AuthStatus> _resolveInitialStatus() async {
    final TokenData? token = await _tokenRepository.getToken();

    if (token == null) {
      AppLogger.info(
        'Resolved session as guest',
        loggerName: 'LauncherBootService',
        context: const <String, Object?>{'status': 'guest'},
      );
      return AuthStatus.guest;
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
      final bool credentialFailure = _isCredentialFailure(error);
      AppLogger.warning(
        credentialFailure
            ? 'Credential failure during launch, resolved as expired'
            : 'Transient token resolution failure during launch, '
                'optimistically resolved as authenticated',
        loggerName: 'LauncherBootService',
        error: error,
        stackTrace: stackTrace,
      );
      return credentialFailure ? AuthStatus.expired : AuthStatus.authenticated;
    }
  }

  /// 是否为确定性凭证失败（重新登录是必要且有效的动作）。
  ///
  /// * `AUTH_EXPIRED`：本地 refresh token 已过期，或令牌被替换/清除；
  /// * 刷新被服务端 401 拒绝：refresh token 已作废；
  /// * 刷新被服务端以 OAuth `invalid_grant` 拒绝（含网关包在 HTTP 200 里的
  ///   `error_error` 包装，已由 [AuthTokenProvider] 还原为真实状态码）：
  ///   会话在服务端已失效。
  ///
  /// 其余（网络不可达、5xx 等瞬时错误）不算凭证失败——此时凭证大概率仍
  /// 有效，只是无法验证，不应把用户导向「重新登录」。
  bool _isCredentialFailure(Object error) {
    if (error is AppException && error.code == 'AUTH_EXPIRED') {
      return true;
    }
    if (error is NetworkException) {
      if (error.statusCode == 401) {
        return true;
      }
      final String? body = error.responseBody;
      if (body != null && body.isNotEmpty) {
        try {
          final dynamic decoded = json.decode(body);
          if (decoded is Map<String, dynamic> &&
              decoded['error'] == 'invalid_grant') {
            return true;
          }
        } on FormatException {
          // 非 JSON 响应体无法证明凭证失效，按瞬时错误处理。
        }
      }
    }
    return false;
  }
}
