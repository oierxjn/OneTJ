import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/repo/app_update_state_repository.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;
  late HttpServer server;
  late AppUpdateService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_update_service_test_');
    Hive.init(tempDir.path);
    await Hive.deleteFromDisk();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel,
            (MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return tempDir.path;
      }
      return null;
    });
    service = AppUpdateService(
      repository: AppUpdateStateRepository.getInstance(),
    );
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    await server.close(force: true);
    await Hive.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AppUpdateService.downloadPackage', () {
    test('downloads file and verifies sha256 in a case-insensitive way',
        () async {
      final List<int> payload =
          utf8.encode(List<String>.filled(2048, 'onetj').join());
      final String sha256Hex = sha256.convert(payload).toString().toUpperCase();
      _servePayload(server, payload);

      final AppUpdateInfo info = AppUpdateInfo(
        latestVersion: '2.3.0',
        latestBuild: 12,
        releaseNotes: 'notes',
        publishedAt: null,
        mandatory: false,
        downloadUrl: _buildUrl(server, '/onetj_installer.exe'),
        sha256: sha256Hex,
        fileSize: payload.length,
        minSupportedVersion: null,
      );

      final File file = await service.downloadPackage(info);

      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), payload);
      expect(p.basename(file.path), 'onetj_installer.exe');

      final AppUpdateStateData state =
          await AppUpdateStateRepository.getInstance().getState(
        refreshFromStorage: true,
      );
      expect(state.pendingFilePath, file.path);
      expect(state.pendingVersionTag, info.versionTag);
      expect(state.pendingSha256, sha256Hex);
    });

    test('skips hash verification when expected sha256 is empty', () async {
      final List<int> payload = utf8.encode('payload without checksum');
      _servePayload(server, payload);

      final AppUpdateInfo info = AppUpdateInfo(
        latestVersion: '2.3.0',
        latestBuild: 12,
        releaseNotes: 'notes',
        publishedAt: null,
        mandatory: false,
        downloadUrl: _buildUrl(server, '/onetj_installer.apk'),
        sha256: '',
        fileSize: payload.length,
        minSupportedVersion: null,
      );

      final File file = await service.downloadPackage(info);

      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), payload);
    });

    test('throws AppException when sha256 does not match', () async {
      final List<int> payload = utf8.encode('tampered payload');
      _servePayload(server, payload);

      final AppUpdateInfo info = AppUpdateInfo(
        latestVersion: '2.3.0',
        latestBuild: 12,
        releaseNotes: 'notes',
        publishedAt: null,
        mandatory: false,
        downloadUrl: _buildUrl(server, '/onetj_installer.exe'),
        sha256: 'deadbeef',
        fileSize: payload.length,
        minSupportedVersion: null,
      );

      await expectLater(
        service.downloadPackage(info),
        throwsA(
          isA<AppException>().having(
            (AppException error) => error.code,
            'code',
            'UPDATE_PACKAGE_HASH_MISMATCH',
          ),
        ),
      );

      final File file = File(p.join(tempDir.path, 'onetj_installer.exe'));
      expect(await file.exists(), isFalse);
    });
  });
}

String _buildUrl(HttpServer server, String path) {
  return 'http://${server.address.host}:${server.port}$path';
}

void _servePayload(HttpServer server, List<int> payload) {
  server.listen((HttpRequest request) async {
    request.response.statusCode = HttpStatus.ok;
    request.response.contentLength = payload.length;
    request.response.add(payload);
    await request.response.close();
  });
}
