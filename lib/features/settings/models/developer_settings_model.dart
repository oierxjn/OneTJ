import 'package:onetj/features/settings/models/developer_settings_exception.dart';

/// 开发者设置页的纯逻辑：调试上报 endpoint 的解析与校验。
///
/// 只做格式校验，不涉及任何 I/O；上报编排见
/// `settings/application/developer_settings_service.dart`。
class DeveloperSettingsModel {
  const DeveloperSettingsModel._();

  /// 解析并校验调试上报 endpoint。
  ///
  /// 必须是带 scheme 与 authority 的 http/https 地址，否则抛出
  /// [DeveloperDebugEndpointException]。
  static Uri parseDebugEndpoint(String raw) {
    final String trimmed = raw.trim();
    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw DeveloperDebugEndpointException(
        code: DeveloperDebugEndpointException.invalidFormat,
        message: 'Invalid endpoint format',
      );
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw DeveloperDebugEndpointException(
        code: DeveloperDebugEndpointException.invalidScheme,
        message: 'Endpoint scheme must be http or https',
      );
    }
    return uri;
  }
}
