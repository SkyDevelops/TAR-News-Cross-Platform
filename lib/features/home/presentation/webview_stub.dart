// lib/features/home/presentation/webview_stub.dart
import 'package:flutter/material.dart';

class WebViewController {
  void setJavaScriptMode(dynamic mode) {}
  void setNavigationDelegate(dynamic delegate) {}
  void loadRequest(Uri uri) {}
}

class WebViewWidget extends StatelessWidget {
  final WebViewController controller;
  const WebViewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class JavaScriptMode {
  static const unrestricted = JavaScriptMode._();
  const JavaScriptMode._();
}

class NavigationDelegate {
  final void Function(String)? onPageStarted;
  final void Function(String)? onPageFinished;
  final void Function(int)? onProgress;
  const NavigationDelegate({
    this.onPageStarted,
    this.onPageFinished,
    this.onProgress,
  });
}