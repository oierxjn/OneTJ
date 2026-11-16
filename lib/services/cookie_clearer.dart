import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 清空 WebView Cookie 的依赖抽象。
///
/// `CookieManager.instance()` 是平台静态调用，抽成注入依赖后，登出编排
/// 只面向本接口编程；实现绑定平台，测试可用内存替身注入失败。
abstract interface class CookieClearer {
  Future<void> deleteAllCookies();
}

/// 基于 flutter_inappwebview CookieManager 的正式实现。
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
