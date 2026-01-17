import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_windows/webview_windows.dart';

class AdaptiveWebView extends StatefulWidget {
  final Uri initialUrl;

  const AdaptiveWebView({super.key, required this.initialUrl});

  @override
  State<AdaptiveWebView> createState() => _AdaptiveWebViewState();
}

class _AdaptiveWebViewState extends State<AdaptiveWebView> {
  final _windowsController = WebviewController();
  bool _windowsReady = false;

  bool get _isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  void initState() {
    super.initState();
    if (_isWindows) {
      _initWindowsWebView();
    }
  }

  Future<void> _initWindowsWebView() async {
    await _windowsController.initialize();
    await _windowsController.setBackgroundColor(Colors.transparent);
    await _windowsController.loadUrl(widget.initialUrl.toString());
    if (!mounted) return;
    setState(() => _windowsReady = true);
  }

  @override
  void dispose() {
    if (_isWindows) {
      _windowsController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isWindows) {
      return _windowsReady
          ? Webview(_windowsController)
          : const Center(child: CircularProgressIndicator());
    }

    return InAppWebView(
      initialUrlRequest:
          URLRequest(url: WebUri(widget.initialUrl.toString())),
    );
  }
}