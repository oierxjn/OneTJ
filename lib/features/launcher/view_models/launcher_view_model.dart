import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/app/logging/logging_bootstrap.dart';
import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/launcher/application/launcher_boot_service.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';

class LauncherViewModel extends BaseViewModel<UiEvent> {
  LauncherViewModel({
    required LauncherBootService bootService,
  }) : _bootService = bootService;

  final LauncherBootService _bootService;
  String? _wallpaperFilePath;
  String? _wallpaperAssetPath;

  String? get wallpaperFilePath => _wallpaperFilePath;
  String? get wallpaperAssetPath => _wallpaperAssetPath;

  /// 进行初始化任务和跳转路由
  Future<void> initialize() async {
    // 同步任务
    AppLoggingBootstrap.ensureInitialized();

    AppLogger.info(
      'Launcher initialization started',
      loggerName: 'LauncherViewModel',
    );

    final Future<String> routeFuture = _bootService.run(
      onWallpaperResolved: _updateWallpaper,
    );
    final Future<void> delayFuture = Future.delayed(
      const Duration(milliseconds: 1200),
    );

    final String route = await routeFuture;
    await delayFuture;

    AppLogger.logNavigation(
      from: RoutePaths.launcher,
      to: route,
      context: const <String, Object?>{'phase': 'launcher_initialize'},
    );
    emit(NavigateEvent(route));
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
