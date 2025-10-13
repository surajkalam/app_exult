import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TwaktoScreen extends StatefulWidget {
  const TwaktoScreen({super.key});

  @override
  State<TwaktoScreen> createState() => _TwaktoScreenState();
}

class _TwaktoScreenState extends State<TwaktoScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            log('WebView loading: $progress%');
          },
          onPageStarted: (String url) {
            log('Page started loading: $url');
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            log('Page finished loading: $url');
            setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            log('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            log('Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://tawk.to/chat/68b7e7d58fa1941924c9b65b/1j47637gk'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}