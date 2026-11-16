import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 清空 WebView Cookie。平台静态调用的注入抽象。
abstract interface class CookieClearer {
  Future<void> deleteAllCookies();
}

class WebViewCookieClearer implements CookieClearer {
  WebViewCookieClearer({WebViewEnvironment? environment})
      : _environment = environment;

  final WebViewEnvironment? _environment;

  @override
  Future<void> deleteAllCookies() {
    return CookieManager.instance(webViewEnvironment: _environment)
        .deleteAllCookies();
  }
}
