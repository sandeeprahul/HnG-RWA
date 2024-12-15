import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the saved URL, or use the default if not set
    String userId = prefs.getString('userId') ?? "";
    String savedUrl = "https://rwaweb.healthandglowonline.co.in/hgrwabrowser/hngposWebbrowser.aspx?userid=$userId";


    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint("Loading progress: $progress%");
          },
          onPageStarted: (String url) {
            debugPrint("Page started loading: $url");

            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint("Page finished loading: $url");

            setState(() {
              _isLoading = false;
            });
          },
          onHttpError: (HttpResponseError error) {
            debugPrint("HTTP error: $error");
            debugPrint("HTTP error: ${error.response}");
            debugPrint("HTTP error: ${error.request}");
            debugPrint("HTTP error: ${error.toString()}");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("Resource error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint("Blocking navigation to: ${request.url}");
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(savedUrl));

    setState(() {
      _url = savedUrl;
    });
    // _controller.reload(); // Reloads the current webpage

  }

  String _url = 'https://flutter.dev'; // Default URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter WebView"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload(); // Reloads the current webpage
            },
          ),
        ],
      ),
      body: Stack(
        children: [

          _isLoading? const Center(
              child: CircularProgressIndicator(),
            ): WebViewWidget(
            controller: _controller,
          ),

        ],
      ),
    );
  }
}


