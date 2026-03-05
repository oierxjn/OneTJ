import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoData {
  const DeviceInfoData({
    required this.brand,
    required this.model,
    required this.platform,
  });

  final String brand;
  final String model;
  final String platform;
}

class DeviceInfoService {
  DeviceInfoService({DeviceInfoPlugin? plugin}) : _plugin = plugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;

  String _pickFirstNonBlank(Iterable<String?> values, String fallback) {
    for (final String? value in values) {
      final String? trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return fallback;
  }

  Future<DeviceInfoData> getDeviceInfo() async {
    if (kIsWeb) {
      return const DeviceInfoData(
        brand: 'web',
        model: 'browser',
        platform: 'web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final AndroidDeviceInfo info = await _plugin.androidInfo;
        return DeviceInfoData(
          brand: _pickFirstNonBlank(
            <String?>[info.brand, info.manufacturer],
            'android',
          ),
          model: _pickFirstNonBlank(
            <String?>[info.model, info.product, info.device],
            'android',
          ),
          platform: 'android',
        );
      case TargetPlatform.ohos:
        final OhosDeviceInfo info = await _plugin.ohosInfo;
        return DeviceInfoData(
          brand: _pickFirstNonBlank(
            <String?>[info.brand, info.manufacture],
            'harmonyos',
          ),
          model: _pickFirstNonBlank(
            <String?>[info.productModel, info.marketName, info.softwareModel],
            'ohos',
          ),
          platform: 'ohos',
        );
      case TargetPlatform.iOS:
        final IosDeviceInfo info = await _plugin.iosInfo;
        return DeviceInfoData(
          brand: 'Apple',
          model: _pickFirstNonBlank(
            <String?>[info.utsname.machine, info.model, info.localizedModel],
            'ios',
          ),
          platform: 'ios',
        );
      case TargetPlatform.macOS:
        final MacOsDeviceInfo info = await _plugin.macOsInfo;
        return DeviceInfoData(
          brand: 'Apple',
          model: info.model,
          platform: 'macos',
        );
      case TargetPlatform.windows:
        final WindowsDeviceInfo info = await _plugin.windowsInfo;
        return DeviceInfoData(
          brand: 'Microsoft',
          model: _pickFirstNonBlank(
            <String?>[info.productName, info.editionId, info.computerName],
            'windows',
          ),
          platform: 'windows',
        );
      case TargetPlatform.linux:
        final LinuxDeviceInfo info = await _plugin.linuxInfo;
        return DeviceInfoData(
          brand: _pickFirstNonBlank(<String?>[info.name], 'linux'),
          model: _pickFirstNonBlank(<String?>[info.prettyName, info.version], 'linux'),
          platform: 'linux',
        );
      case TargetPlatform.fuchsia:
        return const DeviceInfoData(
          brand: 'fuchsia',
          model: 'fuchsia',
          platform: 'fuchsia',
        );
    }
  }
}
