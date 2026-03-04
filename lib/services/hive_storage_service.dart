import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

enum HiveDataMigrationResult { success, noLegacyData }

enum HiveDataCleanupResult { success, noLegacyData }

/// Hive 存储目录与数据迁移服务。
///
/// 当前正式目录为 `ApplicationSupportDirectory/hive`。
/// 旧数据迁移只在设置页手动触发
class HiveStorageService {
  HiveStorageService({HiveInterface? hive}) : _hive = hive ?? Hive;

  final HiveInterface _hive;

  /// 初始化 Hive 到新目录（`ApplicationSupportDirectory/hive`）。
  Future<void> initializeHive() async {
    final Directory targetDir = await _resolveTargetHiveDirectory();
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    _hive.init(targetDir.path);
  }

  /// 检查是否存在可迁移的旧 Hive 数据。
  ///
  /// 会扫描两个来源目录：
  /// 1. `ApplicationDocumentsDirectory`
  /// 2. `ApplicationSupportDirectory` 根目录
  Future<bool> hasLegacyHiveData() async {
    final List<Directory> sourceDirs = await _resolveLegacySourceDirectories();
    for (final Directory sourceDir in sourceDirs) {
      if (!await sourceDir.exists()) {
        continue;
      }
      await for (final FileSystemEntity entity
          in sourceDir.list(followLinks: false)) {
        if (entity is File && _isMigratableHiveFile(entity.path)) {
          return true;
        }
      }
    }
    return false;
  }

  /// 将旧目录中的 Hive 文件迁移到新目录。
  ///
  /// 迁移流程：
  /// 1. 扫描 `Documents` 与 `Support` 根目录中的 `.hive` 文件。
  /// 2. 若同名文件来自多个来源，按 `modified` 时间选择最新来源。
  /// 3. 复制到 `ApplicationSupportDirectory/hive`，并覆盖同名目标文件。
  ///
  /// 迁移期间会先关闭 Hive，结束后重新初始化到目标目录。
  ///
  /// 返回：
  /// - [HiveDataMigrationResult.success]：迁移成功
  /// - [HiveDataMigrationResult.noLegacyData]：未发现可迁移旧数据
  ///
  /// 发生异常时抛出错误。
  Future<HiveDataMigrationResult> migrateLegacyToNew() async {
    final Map<String, File> latestSourceFiles =
        await _collectLatestSourceHiveFiles();
    if (latestSourceFiles.isEmpty) {
      return HiveDataMigrationResult.noLegacyData;
    }

    final Directory targetDir = await _resolveTargetHiveDirectory();
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    await _hive.close();
    try {
      for (final MapEntry<String, File> entry in latestSourceFiles.entries) {
        final String filename = entry.key;
        final File source = entry.value;
        final String destinationPath = path.join(targetDir.path, filename);
        final File target = File(destinationPath);
        if (await target.exists()) {
          await target.delete();
        }
        await source.copy(destinationPath);
      }
    } finally {
      _hive.init(targetDir.path);
    }
    return HiveDataMigrationResult.success;
  }

  /// 清理旧目录中的 Hive 文件。
  ///
  /// 清理对象：
  /// - `.hive`
  /// - `.lock`
  ///
  /// 清理目录：
  /// - `ApplicationDocumentsDirectory`
  /// - `ApplicationSupportDirectory` 根目录
  Future<HiveDataCleanupResult> cleanupLegacyHiveData() async {
    final List<File> cleanupFiles = await _collectLegacyCleanupFiles();
    if (cleanupFiles.isEmpty) {
      return HiveDataCleanupResult.noLegacyData;
    }
    for (final File file in cleanupFiles) {
      try {
        await file.delete();
      } on FileSystemException {
        // 竞争条件下文件可能已被移除，此时无需中断清理流程。
        if (await file.exists()) {
          rethrow;
        }
      }
    }
    return HiveDataCleanupResult.success;
  }

  /// 目标 Hive 目录：`ApplicationSupportDirectory/hive`。
  Future<Directory> _resolveTargetHiveDirectory() async {
    final Directory supportDir = await getApplicationSupportDirectory();
    return Directory(path.join(supportDir.path, 'hive'));
  }

  /// 旧版 Hive 目录（历史路径）：`ApplicationDocumentsDirectory`。
  Future<Directory> _resolveLegacyHiveDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  /// 应用支持目录根路径：`ApplicationSupportDirectory`。
  Future<Directory> _resolveSupportDirectory() async {
    return getApplicationSupportDirectory();
  }

  /// 解析可用于迁移的来源目录列表。
  ///
  /// 正常情况下返回 Documents + Support 根目录；
  /// 若两者路径相同，则去重后只返回一个目录。
  Future<List<Directory>> _resolveLegacySourceDirectories() async {
    final Directory documentsDir = await _resolveLegacyHiveDirectory();
    final Directory supportDir = await _resolveSupportDirectory();
    final String documentsPath = path.normalize(documentsDir.path);
    final String supportPath = path.normalize(supportDir.path);
    if (documentsPath == supportPath) {
      return <Directory>[documentsDir];
    }
    return <Directory>[documentsDir, supportDir];
  }

  /// 收集每个文件名对应的“最新来源文件”。
  ///
  /// 键为文件名，值为应参与复制的源文件。
  Future<Map<String, File>> _collectLatestSourceHiveFiles() async {
    final List<Directory> sourceDirs = await _resolveLegacySourceDirectories();
    final Map<String, File> latestByName = <String, File>{};
    final Map<String, DateTime> latestTimeByName = <String, DateTime>{};

    for (final Directory sourceDir in sourceDirs) {
      if (!await sourceDir.exists()) {
        continue;
      }
      await for (final FileSystemEntity entity
          in sourceDir.list(followLinks: false)) {
        if (entity is! File || !_isMigratableHiveFile(entity.path)) {
          continue;
        }
        final String filename = path.basename(entity.path);
        final DateTime modifiedTime = await entity.lastModified();
        final DateTime? currentLatest = latestTimeByName[filename];
        if (currentLatest == null || modifiedTime.isAfter(currentLatest)) {
          latestByName[filename] = entity;
          latestTimeByName[filename] = modifiedTime;
        }
      }
    }
    return latestByName;
  }

  /// 收集用于清理的旧目录文件（`.hive` + `.lock`）。
  Future<List<File>> _collectLegacyCleanupFiles() async {
    final List<Directory> sourceDirs = await _resolveLegacySourceDirectories();
    final Set<String> seenPaths = <String>{};
    final List<File> files = <File>[];
    for (final Directory sourceDir in sourceDirs) {
      if (!await sourceDir.exists()) {
        continue;
      }
      await for (final FileSystemEntity entity
          in sourceDir.list(followLinks: false)) {
        if (entity is! File || !_isCleanupCandidateFile(entity.path)) {
          continue;
        }
        final String normalizedPath = path.normalize(entity.path);
        if (!seenPaths.add(normalizedPath)) {
          continue;
        }
        files.add(entity);
      }
    }
    return files;
  }

  /// 判断文件是否为当前支持迁移的 Hive 数据文件。
  bool _isMigratableHiveFile(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    return extension == '.hive';
  }

  bool _isCleanupCandidateFile(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    return extension == '.hive' || extension == '.lock';
  }
}
