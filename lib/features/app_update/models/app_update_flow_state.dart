enum AppUpdateFlowPhase {
  idle,
  downloading,
  verifying,
  installing,
}

class AppUpdateFlowState {
  const AppUpdateFlowState({
    required this.phase,
    required this.receivedBytes,
    required this.totalBytes,
    required this.versionTag,
  });

  const AppUpdateFlowState.idle()
      : phase = AppUpdateFlowPhase.idle,
        receivedBytes = 0,
        totalBytes = null,
        versionTag = null;

  final AppUpdateFlowPhase phase;
  final int receivedBytes;
  final int? totalBytes;
  final String? versionTag;

  bool get busy => phase != AppUpdateFlowPhase.idle;

  double? get progress {
    final int? total = totalBytes;
    if (total == null || total <= 0) {
      return null;
    }
    final int clampedReceived = receivedBytes.clamp(0, total);
    return clampedReceived / total;
  }

  AppUpdateFlowState copyWith({
    AppUpdateFlowPhase? phase,
    int? receivedBytes,
    int? totalBytes,
    String? versionTag,
    bool clearTotalBytes = false,
    bool clearVersionTag = false,
  }) {
    return AppUpdateFlowState(
      phase: phase ?? this.phase,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: clearTotalBytes ? null : (totalBytes ?? this.totalBytes),
      versionTag: clearVersionTag ? null : (versionTag ?? this.versionTag),
    );
  }
}
