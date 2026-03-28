import 'package:onetj/features/app_update/models/app_update_flow_state.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/services/app_update_service.dart';

enum AppUpdateFlowCompletionType {
  installerStarted,
  permissionRequired,
  failed,
}

class AppUpdateFlowCompletion {
  const AppUpdateFlowCompletion._({
    required this.type,
    this.error,
    this.stackTrace,
  });

  const AppUpdateFlowCompletion.installerStarted()
      : this._(type: AppUpdateFlowCompletionType.installerStarted);

  const AppUpdateFlowCompletion.permissionRequired()
      : this._(type: AppUpdateFlowCompletionType.permissionRequired);

  const AppUpdateFlowCompletion.failed({
    required Object error,
    StackTrace? stackTrace,
  }) : this._(
          type: AppUpdateFlowCompletionType.failed,
          error: error,
          stackTrace: stackTrace,
        );

  final AppUpdateFlowCompletionType type;
  final Object? error;
  final StackTrace? stackTrace;
}

class AppUpdateFlowViewModel extends BaseViewModel {
  AppUpdateFlowViewModel({
    required AppUpdateService appUpdateService,
  }) : _appUpdateService = appUpdateService;

  final AppUpdateService _appUpdateService;

  AppUpdateFlowState _state = const AppUpdateFlowState.idle();

  AppUpdateFlowState get state => _state;

  Future<AppUpdateFlowCompletion> run(AppUpdateInfo updateInfo) async {
    if (_state.busy) {
      return AppUpdateFlowCompletion.failed(
        error: StateError('App update flow is already running'),
      );
    }
    _state = AppUpdateFlowState(
      phase: AppUpdateFlowPhase.downloading,
      receivedBytes: 0,
      totalBytes: null,
      versionTag: updateInfo.versionTag,
    );
    notifyListeners();
    try {
      final file = await _appUpdateService.downloadPackage(
        updateInfo,
        onProgress: _handleProgress,
        onStageChanged: _handleStageChanged,
      );
      _setState(
        _state.copyWith(
          phase: AppUpdateFlowPhase.installing,
          receivedBytes: _state.totalBytes ?? _state.receivedBytes,
        ),
      );
      final AppUpdateInstallResult result =
          await _appUpdateService.installPackage(file);
      return result == AppUpdateInstallResult.permissionRequired
          ? const AppUpdateFlowCompletion.permissionRequired()
          : const AppUpdateFlowCompletion.installerStarted();
    } catch (error, stackTrace) {
      _appUpdateService.logUpdateFailure(error, stackTrace);
      return AppUpdateFlowCompletion.failed(
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _setState(const AppUpdateFlowState.idle());
    }
  }

  /// 下载进度
  /// 
  /// [receivedBytes] 已接收的字节数
  /// [totalBytes] 总字节数
  void _handleProgress(int receivedBytes, int? totalBytes) {
    final AppUpdateFlowPhase phase = _state.phase == AppUpdateFlowPhase.idle
        ? AppUpdateFlowPhase.downloading
        : _state.phase;
    _setState(
      _state.copyWith(
        phase: phase,
        receivedBytes: receivedBytes,
        totalBytes: totalBytes,
      ),
    );
  }

  /// 下载阶段改变
  /// 
  /// [stage] 下载阶段
  void _handleStageChanged(AppUpdateDownloadStage stage) {
    switch (stage) {
      case AppUpdateDownloadStage.downloading:
        _setState(_state.copyWith(phase: AppUpdateFlowPhase.downloading));
        return;
      case AppUpdateDownloadStage.verifying:
        _setState(_state.copyWith(phase: AppUpdateFlowPhase.verifying));
        return;
    }
  }

  /// 设置状态为 [next] 并通知监听者
  void _setState(AppUpdateFlowState next) {
    _state = next;
    notifyListeners();
  }
}
