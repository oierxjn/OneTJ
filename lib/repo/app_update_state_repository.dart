import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/app_update_state_data.dart';

class AppUpdateStateRepository {
  AppUpdateStateRepository({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'app_update_state';
  static const String _key = 'payload';

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

  /// 标记版本为已跳过
  ///
  /// 用于记录用户已跳过的版本，避免重复提示
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

  /// 标记待安装的更新是否因权限问题而被暂停
  ///
  /// 用于记录用户因权限问题而被暂停的更新
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
