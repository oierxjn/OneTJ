import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'launch_wallpaper_file_service_test_',
    );
    LaunchWallpaperFileService.debugResetCache();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (
      MethodCall methodCall,
    ) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return tempDir.path;
      }
      return null;
    });
  });

  tearDown(() async {
    LaunchWallpaperFileService.debugResetCache();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LaunchWallpaperFileService', () {
    test('ignores builtin wallpaper rename requests', () async {
      await LaunchWallpaperFileService.renameWallpaper(
        wallpaperId: kDefaultLaunchWallpaperId,
        displayName: 'My Builtin',
      );

      final List wallpapers = await LaunchWallpaperFileService.listWallpapers(
        refreshFromDisk: true,
      );

      expect(wallpapers, hasLength(1));
      expect(wallpapers.single.id, kDefaultLaunchWallpaperId);
      expect(wallpapers.single.displayName, 'Built-in Wallpaper');

      final File indexFile = File(
        p.join(tempDir.path, 'wallpapers', 'index.json'),
      );
      expect(await indexFile.exists(), isFalse);
    });

    test('persists only custom wallpapers in index', () async {
      final File sourceFile = File(p.join(tempDir.path, 'source.png'));
      await sourceFile.writeAsBytes(<int>[1, 2, 3, 4]);

      final String importedId = await LaunchWallpaperFileService.importFromFile(
        sourcePath: sourceFile.path,
        preferredDisplayName: '   ',
        source: LaunchWallpaperFileService.importedSource,
      );

      final List wallpapers = await LaunchWallpaperFileService.listWallpapers(
        refreshFromDisk: true,
      );
      expect(wallpapers, hasLength(2));

      final dynamic builtinItem = wallpapers.firstWhere(
        (dynamic item) => item.id == kDefaultLaunchWallpaperId,
      );
      final dynamic importedItem = wallpapers.firstWhere(
        (dynamic item) => item.id == importedId,
      );
      expect(importedItem.displayName, 'Wallpaper 1');
      expect(builtinItem.displayName, 'Built-in Wallpaper');

      final File indexFile = File(
        p.join(tempDir.path, 'wallpapers', 'index.json'),
      );
      final List<dynamic> indexItems =
          jsonDecode(await indexFile.readAsString());
      expect(indexItems, hasLength(1));
      expect(indexItems.single['id'], importedId);
      expect(indexItems.single['source'],
          LaunchWallpaperFileService.importedSource);
    });

    test('filters legacy builtin entries from index data', () async {
      final Directory baseDir = Directory(p.join(tempDir.path, 'wallpapers'));
      await baseDir.create(recursive: true);
      final DateTime now = DateTime.now();
      final File indexFile = File(p.join(baseDir.path, 'index.json'));
      await indexFile.writeAsString(
        jsonEncode(<Map<String, dynamic>>[
          <String, dynamic>{
            'id': kDefaultLaunchWallpaperId,
            'displayName': 'Legacy Builtin',
            'fileName': null,
            'assetPath': kDefaultLaunchWallpaperAsset,
            'source': LaunchWallpaperFileService.builtinSource,
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
          <String, dynamic>{
            'id': 'custom-1',
            'displayName': 'Custom',
            'fileName': 'custom-1.jpg',
            'assetPath': null,
            'source': LaunchWallpaperFileService.importedSource,
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
        ]),
      );

      final List wallpapers = await LaunchWallpaperFileService.listWallpapers(
        refreshFromDisk: true,
      );

      expect(wallpapers, hasLength(2));
      final dynamic builtinItem = wallpapers.firstWhere(
        (dynamic item) => item.id == kDefaultLaunchWallpaperId,
      );
      expect(builtinItem.displayName, 'Built-in Wallpaper');

      await LaunchWallpaperFileService.renameWallpaper(
        wallpaperId: 'custom-1',
        displayName: 'Custom Renamed',
      );

      final List<dynamic> persisted =
          jsonDecode(await indexFile.readAsString());
      expect(persisted, hasLength(1));
      expect(persisted.single['id'], 'custom-1');
      expect(persisted.single['displayName'], 'Custom Renamed');
    });
  });
}
