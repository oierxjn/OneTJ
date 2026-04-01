import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/app_update_info.dart';

void main() {
  group('compareVersionStrings', () {
    test('treats missing trailing parts as zero', () {
      expect(compareVersionStrings('2.4', '2.4.0'), 0);
      expect(compareVersionStrings('2.4.0', '2.4'), 0);
    });

    test('compares numeric parts by value', () {
      expect(compareVersionStrings('2.4.10', '2.4.2'), greaterThan(0));
      expect(compareVersionStrings('2.4.1', '2.4.2'), lessThan(0));
    });

    test('ignores non-digit separators and prefixes', () {
      expect(compareVersionStrings('v2.4.1', '2.4.1'), 0);
      expect(compareVersionStrings('release-2_4_2', '2.4.1'), greaterThan(0));
    });

    test('treats empty or garbage strings as version zero', () {
      expect(compareVersionStrings('', '0'), 0);
      expect(compareVersionStrings('   ', '0.0.0'), 0);
      expect(compareVersionStrings('garbage', '0'), 0);
      expect(compareVersionStrings('vNext', '1.0.0'), lessThan(0));
    });
  });

  group('AppUpdateInfo.requiresMigration', () {
    const AppUpdateInfo baseInfo = AppUpdateInfo(
      latestVersion: '2.4.2',
      latestBuild: 14,
      releaseNotes: '',
      publishedAt: null,
      mandatory: false,
      downloadUrl: 'https://example.com/download',
      sha256: '',
      fileSize: null,
      minSupportedVersion: null,
    );

    test('returns false when minSupportedVersion is null or blank', () {
      expect(
        baseInfo.requiresMigration(currentVersion: '2.4.1'),
        isFalse,
      );
      expect(
        const AppUpdateInfo(
          latestVersion: '2.4.2',
          latestBuild: 14,
          releaseNotes: '',
          publishedAt: null,
          mandatory: false,
          downloadUrl: 'https://example.com/download',
          sha256: '',
          fileSize: null,
          minSupportedVersion: '   ',
        ).requiresMigration(currentVersion: '2.4.1'),
        isFalse,
      );
    });

    test('returns false when minSupportedVersion is not greater', () {
      expect(
        const AppUpdateInfo(
          latestVersion: '2.4.2',
          latestBuild: 14,
          releaseNotes: '',
          publishedAt: null,
          mandatory: false,
          downloadUrl: 'https://example.com/download',
          sha256: '',
          fileSize: null,
          minSupportedVersion: '2.4.1',
        ).requiresMigration(currentVersion: '2.4.1'),
        isFalse,
      );
      expect(
        const AppUpdateInfo(
          latestVersion: '2.4.2',
          latestBuild: 14,
          releaseNotes: '',
          publishedAt: null,
          mandatory: false,
          downloadUrl: 'https://example.com/download',
          sha256: '',
          fileSize: null,
          minSupportedVersion: '2.4',
        ).requiresMigration(currentVersion: '2.4.0'),
        isFalse,
      );
    });

    test('returns true when minSupportedVersion is greater', () {
      expect(
        const AppUpdateInfo(
          latestVersion: '2.4.2',
          latestBuild: 14,
          releaseNotes: '',
          publishedAt: null,
          mandatory: false,
          downloadUrl: 'https://example.com/download',
          sha256: '',
          fileSize: null,
          minSupportedVersion: '2.4.2',
        ).requiresMigration(currentVersion: '2.4.1'),
        isTrue,
      );
      expect(
        const AppUpdateInfo(
          latestVersion: '2.4.2',
          latestBuild: 14,
          releaseNotes: '',
          publishedAt: null,
          mandatory: false,
          downloadUrl: 'https://example.com/download',
          sha256: '',
          fileSize: null,
          minSupportedVersion: 'v2.5.0',
        ).requiresMigration(currentVersion: '2.4.9'),
        isTrue,
      );
    });

    test('treats garbage minSupportedVersion as not requiring migration', () {
      expect(
        const AppUpdateInfo(
          latestVersion: '2.4.2',
          latestBuild: 14,
          releaseNotes: '',
          publishedAt: null,
          mandatory: false,
          downloadUrl: 'https://example.com/download',
          sha256: '',
          fileSize: null,
          minSupportedVersion: 'invalid',
        ).requiresMigration(currentVersion: '2.4.1'),
        isFalse,
      );
    });
  });
}
