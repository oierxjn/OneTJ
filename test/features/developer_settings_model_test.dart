import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/settings/models/developer_settings_exception.dart';
import 'package:onetj/features/settings/models/developer_settings_model.dart';

void main() {
  group('DeveloperSettingsModel.parseDebugEndpoint', () {
    test('接受 https 地址并去除首尾空白', () {
      final Uri endpoint = DeveloperSettingsModel.parseDebugEndpoint(
        '  https://example.com/collect  ',
      );

      expect(endpoint.toString(), 'https://example.com/collect');
    });

    test('接受 http 地址', () {
      final Uri endpoint = DeveloperSettingsModel.parseDebugEndpoint(
        'http://10.0.0.1:8080/collect',
      );

      expect(endpoint.host, '10.0.0.1');
      expect(endpoint.port, 8080);
    });

    test('缺少 scheme 或 authority 时抛出 invalidFormat', () {
      expect(
        () => DeveloperSettingsModel.parseDebugEndpoint('example.com/collect'),
        throwsA(
          isA<DeveloperDebugEndpointException>().having(
            (DeveloperDebugEndpointException e) => e.code,
            'code',
            DeveloperDebugEndpointException.invalidFormat,
          ),
        ),
      );
    });

    test('非 http/https scheme 时抛出 invalidScheme', () {
      expect(
        () => DeveloperSettingsModel.parseDebugEndpoint('ftp://example.com/x'),
        throwsA(
          isA<DeveloperDebugEndpointException>().having(
            (DeveloperDebugEndpointException e) => e.code,
            'code',
            DeveloperDebugEndpointException.invalidScheme,
          ),
        ),
      );
    });
  });
}
