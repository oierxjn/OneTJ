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

  bool requiresMigration({
    required String currentVersion,
  }) {
    final String minVersion = minSupportedVersion?.trim() ?? '';
    if (minVersion.isEmpty) {
      return false;
    }
    return compareVersionStrings(minVersion, currentVersion) > 0;
  }

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

int compareVersionStrings(String left, String right) {
  final List<int> leftParts = _parseVersionParts(left);
  final List<int> rightParts = _parseVersionParts(right);
  final int length =
      leftParts.length > rightParts.length ? leftParts.length : rightParts.length;
  for (int i = 0; i < length; i += 1) {
    final int leftPart = i < leftParts.length ? leftParts[i] : 0;
    final int rightPart = i < rightParts.length ? rightParts[i] : 0;
    if (leftPart != rightPart) {
      return leftPart.compareTo(rightPart);
    }
  }
  return 0;
}

List<int> _parseVersionParts(String version) {
  final List<String> rawParts =
      version.trim().split(RegExp(r'[^\d]+')).where((part) => part.isNotEmpty).toList();
  if (rawParts.isEmpty) {
    return const <int>[0];
  }
  return rawParts
      .map((part) => int.tryParse(part) ?? 0)
      .toList(growable: false);
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
