class AppUpdateInfo {
  const AppUpdateInfo({
    required this.latestVersion,
    required this.latestBuild,
    required this.releaseNotes,
    required this.publishedAt,
    required this.mandatory,
    required this.downloadUrl,
    required this.sha256,
    required this.fileSize,
    required this.minSupportedVersion,
  });

  final String latestVersion;
  final int latestBuild;
  final String releaseNotes;
  final DateTime? publishedAt;
  final bool mandatory;
  final String downloadUrl;
  final String sha256;
  final int? fileSize;
  final String? minSupportedVersion;

  String get versionTag => '$latestVersion+$latestBuild';

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    final Object? rawPublishedAt = json['published_at'];
    DateTime? publishedAt;
    if (rawPublishedAt is String && rawPublishedAt.isNotEmpty) {
      publishedAt = DateTime.tryParse(rawPublishedAt);
    }
    return AppUpdateInfo(
      latestVersion: json['latest_version'] as String? ?? '',
      latestBuild: (json['latest_build'] as num?)?.toInt() ?? 0,
      releaseNotes: json['release_notes'] as String? ?? '',
      publishedAt: publishedAt,
      mandatory: json['mandatory'] as bool? ?? false,
      downloadUrl: json['download_url'] as String? ?? '',
      sha256: (json['sha256'] as String? ?? '').toLowerCase(),
      fileSize: (json['file_size'] as num?)?.toInt(),
      minSupportedVersion: json['min_supported_version'] as String?,
    );
  }
}

class AppUpdateCheckResult {
  const AppUpdateCheckResult({
    required this.checked,
    required this.hasUpdate,
    this.updateInfo,
    this.throttled = false,
  });

  final bool checked;
  final bool hasUpdate;
  final AppUpdateInfo? updateInfo;
  final bool throttled;

  static const AppUpdateCheckResult notChecked = AppUpdateCheckResult(
    checked: false,
    hasUpdate: false,
  );
}
