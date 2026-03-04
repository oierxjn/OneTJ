import 'package:onetj/app/constant/app_version_constant.dart';
import 'package:onetj/models/base_model.dart';

class AboutViewModel extends BaseViewModel {
  static const String _appName = oneTJAppName;
  static const String _version = oneTJAppVersion;
  static const String _buildNumber = oneTJAppBuildNumber;

  String get appName => _appName;
  String get version => _version;
  String get buildNumber => _buildNumber;
}
