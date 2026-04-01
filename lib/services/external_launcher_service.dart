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

  Future<ExternalUrlLaunchResult> openExternalUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
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
