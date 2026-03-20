import 'dart:convert';

import 'package:hive/hive.dart';

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

  AppUpdateStateData copyWith({
    int? lastCheckedAtMillis,
    String? skippedVersionTag,
    String? pendingFilePath,
    String? pendingVersionTag,
    String? pendingSha256,
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
      pendingSha256: clearPendingInstall
          ? null
          : (pendingSha256 ?? this.pendingSha256),
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

class AppUpdateStateRepository {
  AppUpdateStateRepository._({required HiveInterface hive}) : _hive = hive;

  static const String _boxName = 'app_update_state';
  static const String _key = 'payload';
  static AppUpdateStateRepository? _instance;

  static AppUpdateStateRepository getInstance() {
    return _instance ??= AppUpdateStateRepository._(hive: Hive);
  }

  final HiveInterface _hive;
  AppUpdateStateData? _cached;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  Future<AppUpdateStateData> getState({bool refreshFromStorage = false}) async {
    if (!refreshFromStorage && _cached != null) {
      return _cached!;
    }
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      _cached = const AppUpdateStateData();
      return _cached!;
    }
    final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
    _cached = AppUpdateStateData.fromJson(map);
    return _cached!;
  }

  Future<void> saveState(AppUpdateStateData data) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(data.toJson()));
    _cached = data;
  }

  Future<void> markCheckedAt(DateTime time) async {
    final AppUpdateStateData current = await getState();
    await saveState(
      current.copyWith(
        lastCheckedAtMillis: time.millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> skipVersion(String versionTag) async {
    final AppUpdateStateData current = await getState();
    await saveState(current.copyWith(skippedVersionTag: versionTag));
  }

  Future<void> clearSkippedVersion() async {
    final AppUpdateStateData current = await getState();
    await saveState(current.copyWith(clearSkippedVersionTag: true));
  }

  Future<void> savePendingInstall({
    required String filePath,
    required String versionTag,
    required String sha256,
    bool awaitingInstallPermission = false,
  }) async {
    final AppUpdateStateData current = await getState();
    await saveState(
      current.copyWith(
        pendingFilePath: filePath,
        pendingVersionTag: versionTag,
        pendingSha256: sha256,
        pendingAwaitingInstallPermission: awaitingInstallPermission,
      ),
    );
  }

  Future<void> markPendingAwaitingInstallPermission(bool value) async {
    final AppUpdateStateData current = await getState();
    await saveState(
      current.copyWith(
        pendingAwaitingInstallPermission: value,
      ),
    );
  }

  Future<void> clearPendingInstall() async {
    final AppUpdateStateData current = await getState();
    await saveState(current.copyWith(clearPendingInstall: true));
  }
}
