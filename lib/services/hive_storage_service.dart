import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

enum HiveDataMigrationResult { success, noLegacyData }

class HiveStorageService {
  HiveStorageService({HiveInterface? hive}) : _hive = hive ?? Hive;

  final HiveInterface _hive;

  Future<void> initializeHive() async {
    final Directory targetDir = await _resolveTargetHiveDirectory();
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    _hive.init(targetDir.path);
  }

  Future<bool> hasLegacyHiveData() async {
    final Directory legacyDir = await _resolveLegacyHiveDirectory();
    if (!await legacyDir.exists()) {
      return false;
    }
    await for (final FileSystemEntity entity
        in legacyDir.list(followLinks: false)) {
      if (entity is File && _isMigratableHiveFile(entity.path)) {
        return true;
      }
    }
    return false;
  }

  /// 迁移旧目录Hive数据到新目录
  /// 
  /// 迁移过程中会关闭Hive数据库，迁移完成后会重新初始化Hive数据库
  /// 
  /// return [HiveDataMigrationResult.success] if migration success,
  /// [HiveDataMigrationResult.noLegacyData] if no legacy data found.
  /// 
  /// throw error if migration failed.
  Future<HiveDataMigrationResult> migrateLegacyToNew() async {
    final Directory legacyDir = await _resolveLegacyHiveDirectory();
    if (!await legacyDir.exists()) {
      return HiveDataMigrationResult.noLegacyData;
    }

    final List<File> files = <File>[];
    await for (final FileSystemEntity entity
        in legacyDir.list(followLinks: false)) {
      if (entity is File && _isMigratableHiveFile(entity.path)) {
        files.add(entity);
      }
    }
    if (files.isEmpty) {
      return HiveDataMigrationResult.noLegacyData;
    }

    final Directory targetDir = await _resolveTargetHiveDirectory();
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    await _hive.close();
    try {
      for (final File source in files) {
        final String filename = path.basename(source.path);
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

  Future<Directory> _resolveTargetHiveDirectory() async {
    return getApplicationSupportDirectory();
  }

  Future<Directory> _resolveLegacyHiveDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  bool _isMigratableHiveFile(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    return extension == '.hive';
  }
}
