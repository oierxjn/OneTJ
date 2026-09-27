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
///
/// 引导失败时进入 [LauncherBootFailure] 状态：状态停留在 `unknown`（守卫不放行），
/// 由视图展示错误并提供重试或退出，避免用户永久卡在启动页。
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
  LauncherBootFailure? _failure;
  bool _isInitializing = false;

  String? get wallpaperFilePath => _wallpaperFilePath;
  String? get wallpaperAssetPath => _wallpaperAssetPath;

  /// 引导失败信息；为 null 表示未失败（进行中或已完成）。
  LauncherBootFailure? get failure => _failure;

  /// 是否正在引导；重试期间用于禁用按钮，避免并发重复引导。
  bool get isInitializing => _isInitializing;

  /// 进行初始化任务，并在最短展示时间用满后发布会话状态。
  ///
  /// 失败时记录 [failure] 并通知视图，不发布会话状态——守卫继续把用户留在
  /// 启动页，直到用户重试成功或退出。
  Future<void> initialize() async {
    if (_isInitializing) {
      return;
    }
    _isInitializing = true;

    // 同步任务
    AppLoggingBootstrap.ensureInitialized();

    AppLogger.info(
      'Launcher initialization started',
      loggerName: 'LauncherViewModel',
    );

    _failure = null;
    notifyListeners();

    final Future<AuthStatus> statusFuture = _bootService.run(
      onWallpaperResolved: _updateWallpaper,
    );
    final Future<void> delayFuture = Future<void>.delayed(minimumSplashDuration);

    final AuthStatus status;
    try {
      status = await statusFuture;
    } catch (error, stackTrace) {
      // 引导失败（Hive 初始化、设置读取、WebView 初始化等）：停在启动页并
      // 提供重试，绝不能让 completeBoot 永不调用导致状态永远为 unknown。
      _failure = LauncherBootFailure(
        error: error,
        stackTrace: stackTrace,
      );
      _isInitializing = false;
      AppLogger.error(
        'Launcher boot failed',
        loggerName: 'LauncherViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      notifyListeners();
      return;
    }
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

/// 启动引导失败的一次记录。
class LauncherBootFailure {
  const LauncherBootFailure({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;
}
