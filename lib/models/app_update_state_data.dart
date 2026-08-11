class AppUpdateStateData {
  const AppUpdateStateData({
    this.lastCheckedAtMillis,
    this.skippedVersionTag,
    this.pendingFilePath,
    this.pendingVersionTag,
    this.pendingSha256,
    this.pendingAwaitingInstallPermission = false,
  });

  final int? lastCheckedAtMillis;
  final String? skippedVersionTag;
  final String? pendingFilePath;
  final String? pendingVersionTag;
  final String? pendingSha256;
  final bool pendingAwaitingInstallPermission;

  DateTime? get lastCheckedAt {
    final int? millis = lastCheckedAtMillis;
    if (millis == null || millis <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// 复制当前状态数据
  ///
  /// clearSkippedVersionTag: 是否清除已跳过的版本标签 [skippedVersionTag]
  /// clearPendingInstall: 是否清除待安装的更新信息 [pendingFilePath, pendingVersionTag, pendingSha256, pendingAwaitingInstallPermission]
  AppUpdateStateData copyWith({
    int? lastCheckedAtMillis,
    String? skippedVersionTag,
    String? pendingFilePath,
    String? pendingVersionTag,
    String? pendingSha256,
    // 安装流程因权限问题而被暂停
    bool? pendingAwaitingInstallPermission,
    bool clearSkippedVersionTag = false,
    bool clearPendingInstall = false,
  }) {
    return AppUpdateStateData(
      lastCheckedAtMillis: lastCheckedAtMillis ?? this.lastCheckedAtMillis,
      skippedVersionTag: clearSkippedVersionTag
          ? null
          : (skippedVersionTag ?? this.skippedVersionTag),
      pendingFilePath: clearPendingInstall
          ? null
          : (pendingFilePath ?? this.pendingFilePath),
      pendingVersionTag: clearPendingInstall
          ? null
          : (pendingVersionTag ?? this.pendingVersionTag),
      pendingSha256:
          clearPendingInstall ? null : (pendingSha256 ?? this.pendingSha256),
      pendingAwaitingInstallPermission: clearPendingInstall
          ? false
          : (pendingAwaitingInstallPermission ??
              this.pendingAwaitingInstallPermission),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lastCheckedAtMillis': lastCheckedAtMillis,
      'skippedVersionTag': skippedVersionTag,
      'pendingFilePath': pendingFilePath,
      'pendingVersionTag': pendingVersionTag,
      'pendingSha256': pendingSha256,
      'pendingAwaitingInstallPermission': pendingAwaitingInstallPermission,
    };
  }

  factory AppUpdateStateData.fromJson(Map<String, dynamic> json) {
    return AppUpdateStateData(
      lastCheckedAtMillis: (json['lastCheckedAtMillis'] as num?)?.toInt(),
      skippedVersionTag: json['skippedVersionTag'] as String?,
      pendingFilePath: json['pendingFilePath'] as String?,
      pendingVersionTag: json['pendingVersionTag'] as String?,
      pendingSha256: json['pendingSha256'] as String?,
      pendingAwaitingInstallPermission:
          json['pendingAwaitingInstallPermission'] as bool? ?? false,
    );
  }
}
