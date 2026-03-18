import 'dart:io';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/launch_wallpaper_item.dart';

class LaunchWallpaperFileService {
  const LaunchWallpaperFileService._();

  static const String _folderName = 'wallpapers';
  static const String _indexFileName = 'index.json';
  static const String _filesFolderName = 'files';
  static const Uuid _uuid = Uuid();

  static Future<String?> importFromGallery() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (picked == null) {
      return null;
    }
    return importFromFile(
      sourcePath: picked.path,
      preferredDisplayName: p.basenameWithoutExtension(picked.path),
      source: 'gallery',
    );
  }

  static Future<String> importFromFile({
    required String sourcePath,
    required String preferredDisplayName,
    required String source,
  }) async {
    final Directory filesDir = await _getFilesDirectory(create: true);
    final List<LaunchWallpaperItem> items = await listWallpapers();
    final DateTime now = DateTime.now();

    final String id = _uuid.v4();
    final String extension = p.extension(sourcePath).toLowerCase();
    final String fileName = '$id$extension';
    final String destinationPath = p.join(filesDir.path, fileName);

    await File(sourcePath).copy(destinationPath);
    final LaunchWallpaperItem item = LaunchWallpaperItem(
      id: id,
      displayName: _normalizeDisplayName(
        preferredDisplayName,
        fallbackIndex: items.length + 1,
      ),
      fileName: fileName,
      source: source,
      createdAt: now,
      updatedAt: now,
    );
    items.add(item);
    await _saveIndex(items);

    AppLogger.info(
      'Launch wallpaper imported to managed folder',
      loggerName: 'LaunchWallpaperFileService',
      context: <String, Object?>{
        'sourcePath': sourcePath,
        'destinationPath': destinationPath,
        'id': id,
      },
    );
    return id;
  }

  /// 在index.json中读取所有壁纸项
  static Future<List<LaunchWallpaperItem>> listWallpapers() async {
    final File indexFile = await _getIndexFile(create: false);
    if (!await indexFile.exists()) {
      return <LaunchWallpaperItem>[];
    }
    final String raw = await indexFile.readAsString();
    if (raw.trim().isEmpty) {
      return <LaunchWallpaperItem>[];
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <LaunchWallpaperItem>[];
    }
    final List<LaunchWallpaperItem> items = <LaunchWallpaperItem>[];
    for (final Object? item in decoded) {
      if (item is! Map) {
        continue;
      }
      items.add(LaunchWallpaperItem.fromJson(Map<String, dynamic>.from(item)));
    }
    return items;
  }

  /// 根据壁纸ID获取壁纸文件路径
  ///
  /// 如果[wallpaperId]存在于index.json中且元数据对应的文件存在，返回对应的文件路径
  /// 否则返回null。
  static Future<String?> resolveWallpaperPathById(String? wallpaperId) async {
    if (wallpaperId == null || wallpaperId.isEmpty) {
      return null;
    }
    final List<LaunchWallpaperItem> items = await listWallpapers();
    final LaunchWallpaperItem? item =
        _findItemById(items, wallpaperId: wallpaperId);
    if (item == null) {
      return null;
    }
    final File file = await _getFileByName(item.fileName);
    if (!await file.exists()) {
      return null;
    }
    return file.path;
  }

  /// 重命名壁纸
  ///
  /// 将其显示名称更新为[displayName]的trimmed版本。
  /// 如果[displayName]为空，将显示名称设置为'Wallpaper'。
  static Future<void> renameWallpaper({
    required String wallpaperId,
    required String displayName,
  }) async {
    final String normalized =
        _normalizeDisplayName(displayName, fallbackIndex: 0);
    final List<LaunchWallpaperItem> items = await listWallpapers();
    final int index = items.indexWhere((item) => item.id == wallpaperId);
    if (index < 0) {
      return;
    }
    items[index] = items[index].copyWith(
      displayName: normalized,
      updatedAt: DateTime.now(),
    );
    await _saveIndex(items);
  }

  /// 删除壁纸
  ///
  /// 如果[wallpaperId]存在于index.json中，将其从index.json中移除
  /// 并删除对应的文件。
  /// 否则，不执行任何操作。
  static Future<void> deleteWallpaper(String wallpaperId) async {
    final List<LaunchWallpaperItem> items = await listWallpapers();
    final int index = items.indexWhere((item) => item.id == wallpaperId);
    if (index < 0) {
      // TODO 不存在的情况应该让上层感知
      return;
    }
    final LaunchWallpaperItem removed = items.removeAt(index);
    await _saveIndex(items);

    final File file = await _getFileByName(removed.fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static LaunchWallpaperItem? _findItemById(
    List<LaunchWallpaperItem> items, {
    required String wallpaperId,
  }) {
    for (final LaunchWallpaperItem item in items) {
      if (item.id == wallpaperId) {
        return item;
      }
    }
    return null;
  }

  /// 标准化壁纸显示名称
  ///
  /// 如果[value]不为空，返回[value]的trimmed版本。
  /// 否则，如果[fallbackIndex]大于0，返回'Wallpaper $fallbackIndex'。
  /// 否则，返回'Wallpaper'。
  static String _normalizeDisplayName(String value,
      {required int fallbackIndex}) {
    final String trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    if (fallbackIndex > 0) {
      return 'Wallpaper $fallbackIndex';
    }
    return 'Wallpaper';
  }

  static Future<Directory> _getBaseDirectory({required bool create}) async {
    final Directory supportDir = await getApplicationSupportDirectory();
    final Directory base = Directory(p.join(supportDir.path, _folderName));
    if (create) {
      await base.create(recursive: true);
    }
    return base;
  }

  static Future<Directory> _getFilesDirectory({required bool create}) async {
    final Directory base = await _getBaseDirectory(create: create);
    final Directory filesDir = Directory(p.join(base.path, _filesFolderName));
    if (create) {
      await filesDir.create(recursive: true);
    }
    return filesDir;
  }

  static Future<File> _getIndexFile({required bool create}) async {
    final Directory base = await _getBaseDirectory(create: create);
    return File(p.join(base.path, _indexFileName));
  }

  static Future<File> _getFileByName(String fileName) async {
    final Directory filesDir = await _getFilesDirectory(create: false);
    return File(p.join(filesDir.path, fileName));
  }

  static Future<void> _saveIndex(List<LaunchWallpaperItem> items) async {
    final File indexFile = await _getIndexFile(create: true);
    final String raw = jsonEncode(
      items.map((item) => item.toJson()).toList(growable: false),
    );
    await indexFile.writeAsString(raw);
    AppLogger.info(
      'Launch wallpaper index saved',
      loggerName: 'LaunchWallpaperFileService',
      context: <String, Object?>{
        'count': items.length,
      },
    );
  }
}
