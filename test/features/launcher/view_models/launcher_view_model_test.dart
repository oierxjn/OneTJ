import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/launcher/application/launcher_boot_service.dart';
import 'package:onetj/features/launcher/view_models/launcher_view_model.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/theme_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/hive_storage_service.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';
import 'package:onetj/services/webview_environment_service.dart';

/// 可控的引导服务替身：按 [result] 返回状态或抛出错误，并记录调用次数。
class _FakeLauncherBootService extends LauncherBootService {
  _FakeLauncherBootService({
    required super.hiveStorageService,
    required super.themeChangeNotifier,
    required super.webViewEnvironmentService,
    required super.settingsRepository,
    required super.tokenRepository,
    required super.authTokenProvider,
    this.result = AuthStatus.authenticated,
    this.error,
  });

  AuthStatus result;
  Object? error;
  int runCount = 0;

  @override
  Future<AuthStatus> run({
    void Function(LaunchWallpaperResolved? wallpaper)? onWallpaperResolved,
  }) async {
    runCount += 1;
    if (error != null) {
      throw error!;
    }
    return result;
  }
}

void main() {
  late ThemeChangeNotifier themeNotifier;
  late TokenRepository tokenRepository;
  late SessionController sessionController;

  _FakeLauncherBootService buildBoot({
    AuthStatus result = AuthStatus.authenticated,
    Object? error,
  }) {
    return _FakeLauncherBootService(
      hiveStorageService: HiveStorageService(),
      themeChangeNotifier: themeNotifier,
      webViewEnvironmentService: WebViewEnvironmentService(),
      settingsRepository: SettingsRepository(
        storage: InMemorySettingsStorage(),
      ),
      tokenRepository: tokenRepository,
      authTokenProvider: AuthTokenProvider(repository: tokenRepository),
      result: result,
      error: error,
    );
  }

  LauncherViewModel buildViewModel(_FakeLauncherBootService boot) {
    return LauncherViewModel(
      bootService: boot,
      sessionController: sessionController,
      minimumSplashDuration: Duration.zero,
    );
  }

  setUp(() {
    sessionController = SessionController();
    tokenRepository = TokenRepository(storage: InMemoryTokenStorage());
    themeNotifier = ThemeChangeNotifier(
      repository: ThemeRepository(storage: InMemoryThemeStorage()),
    );
  });

  tearDown(() {
    themeNotifier.dispose();
  });

  test('引导成功后发布会话状态，且不进入失败态', () async {
    final LauncherViewModel viewModel =
        buildViewModel(buildBoot(result: AuthStatus.authenticated));

    await viewModel.initialize();

    expect(viewModel.failure, isNull);
    expect(sessionController.status, AuthStatus.authenticated);
  });

  test('引导抛错时进入失败态且不发布会话状态（守卫继续留在启动页）', () async {
    final LauncherViewModel viewModel =
        buildViewModel(buildBoot(error: StateError('hive init failed')));

    await viewModel.initialize();

    expect(viewModel.failure, isNotNull);
    // 关键：状态必须仍为 unknown，否则守卫会放行到未完成初始化的页面。
    expect(sessionController.status, AuthStatus.unknown);
  });

  test('失败后重试成功可恢复并发布状态', () async {
    final _FakeLauncherBootService boot =
        buildBoot(error: StateError('transient boot failure'));
    final LauncherViewModel viewModel = buildViewModel(boot);

    await viewModel.initialize();
    expect(viewModel.failure, isNotNull);
    expect(sessionController.status, AuthStatus.unknown);

    // 用户点击「重新加载」：错误消失后重试应能成功。
    boot.error = null;
    await viewModel.initialize();

    expect(viewModel.failure, isNull);
    expect(sessionController.status, AuthStatus.authenticated);
    expect(boot.runCount, 2);
  });

  test('重试期间重复调用不会并发重复引导', () async {
    final _FakeLauncherBootService boot =
        buildBoot(result: AuthStatus.unauthenticated);
    final LauncherViewModel viewModel = buildViewModel(boot);

    // 并发触发两次，第二次应被 isInitializing 挡住。
    await Future.wait(<Future<void>>[
      viewModel.initialize(),
      viewModel.initialize(),
    ]);

    expect(boot.runCount, 1);
  });
}
