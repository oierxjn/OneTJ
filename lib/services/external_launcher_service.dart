import 'package:url_launcher/url_launcher.dart';

enum ExternalUrlLaunchResult {
  launched,
  failed,
}

class ExternalLauncherService {
  ExternalLauncherService();

  static ExternalLauncherService? _instance;

  static ExternalLauncherService getInstance() {
    return _instance ??= ExternalLauncherService();
  }

  Uri? tryParseExternalUrl(String url) {
    final String trimmed = url.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return Uri.tryParse(trimmed);
  }

  bool isValidExternalUrl(String url) {
    return tryParseExternalUrl(url) != null;
  }

  Future<ExternalUrlLaunchResult> openExternalUrl(String url) async {
    final Uri? uri = tryParseExternalUrl(url);
    if (uri == null) {
      return ExternalUrlLaunchResult.failed;
    }
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched
          ? ExternalUrlLaunchResult.launched
          : ExternalUrlLaunchResult.failed;
    } catch (_) {
      return ExternalUrlLaunchResult.failed;
    }
  }
}
