import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/app/logging/logging_bootstrap.dart';
import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/launcher/application/launcher_boot_service.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';

/// 启动页视图模型。
///
/// 引导流程结束后不会自行跳转，而是在启动页最短展示时间用满后，把结果写入
/// [SessionController]，由路由守卫统一完成跳转。这样启动页的展示时长与鉴权
/// 判定互不干扰，也避免「先跳走再回退」的抖动。
class LauncherViewModel extends BaseViewModel<Never> {
  LauncherViewModel({
    required LauncherBootService bootService,
    required SessionController sessionController,
    this.minimumSplashDuration = const Duration(milliseconds: 1200),
  })  : _bootService = bootService,
        _sessionController = sessionController;

  /// 启动页最短展示时间，避免引导过快导致壁纸一闪而过。
  final Duration minimumSplashDuration;

  final LauncherBootService _bootService;
  final SessionController _sessionController;

  String? _wallpaperFilePath;
  String? _wallpaperAssetPath;

  String? get wallpaperFilePath => _wallpaperFilePath;
  String? get wallpaperAssetPath => _wallpaperAssetPath;

  /// 进行初始化任务，并在最短展示时间用满后发布会话状态。
  Future<void> initialize() async {
    // 同步任务
    AppLoggingBootstrap.ensureInitialized();

    AppLogger.info(
      'Launcher initialization started',
      loggerName: 'LauncherViewModel',
    );

    final Future<AuthStatus> statusFuture = _bootService.run(
      onWallpaperResolved: _updateWallpaper,
    );
    final Future<void> delayFuture = Future<void>.delayed(minimumSplashDuration);

    final AuthStatus status = await statusFuture;
    await delayFuture;

    AppLogger.logNavigation(
      from: RoutePaths.launcher,
      to: status == AuthStatus.authenticated ? RoutePaths.home : RoutePaths.login,
      context: <String, Object?>{
        'phase': 'launcher_initialize',
        'status': status.name,
      },
    );
    // 发布状态后守卫会立即重新求值并离开启动页。
    _sessionController.completeBoot(status);
  }

  void _updateWallpaper(LaunchWallpaperResolved? resolved) {
    final String? nextFilePath = resolved?.filePath;
    final String? nextAssetPath = resolved?.assetPath;
    if (_wallpaperFilePath == nextFilePath &&
        _wallpaperAssetPath == nextAssetPath) {
      return;
    }
    _wallpaperFilePath = nextFilePath;
    _wallpaperAssetPath = nextAssetPath;
    notifyListeners();
  }
}
