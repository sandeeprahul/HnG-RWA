import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';




class WebViewExample extends StatefulWidget {
  final int from;

  const WebViewExample({super.key, required this.from});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final InAppWebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  double _height = 0.001;

  Future<void> _initializeWebView() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the saved URL, or use the default if not set
    String userId = prefs.getString('userCode') ?? "";
    String savedUrl =
        "https://rwaweb.healthandglowonline.co.in/hgrwabrowser1/hngposWebbrowser.aspx?userid=$userId";
    String savedUrlForReports =
        "https://rwaweb.healthandglowonline.co.in/hgrwabrowser/hngposWebbrowser.aspx?userid=$userId";

    print(savedUrl);
    if (widget.from == 0) {
      setState(() {
        _isLoading = false;
        _url = savedUrl;
      });
    } else {
      setState(() {
        _isLoading = false;
        _url = savedUrlForReports;
      });
    }

    print(_url);
  }

  // Future<void> _initializeWebView() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   // Retrieve the saved URL, or use the default if not set
  //   String userId = prefs.getString('userId') ?? "";
  //   String savedUrl = "https://rwaweb.healthandglowonline.co.in/hgrwabrowser/hngposWebbrowser.aspx?userid=$userId";
  //   _controller = WebViewControllerPlus()
  //     ..setNavigationDelegate(
  //       NavigationDelegate(
  //         onPageFinished: (url) async {
  //           final h = await _controller.webViewHeight;
  //           var height = double.parse(h.toString());
  //           if (height != _height) {
  //             if (kDebugMode) {
  //               print("Height is: $height");
  //             }
  //             setState(() {
  //               _height = height;
  //               _isLoading = false;
  //
  //             });
  //           }
  //         },
  //       ),
  //     )
  //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //     ..loadRequest(Uri.parse(savedUrl))
  //   ..setBackgroundColor(const Color(0x00000000));
  //
  //   // // Initialize the WebViewController
  // _controller = WebViewController()
  //   //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //   //   ..setNavigationDelegate(
  //   //     NavigationDelegate(
  //   //       onProgress: (int progress) {
  //   //         debugPrint("Loading progress: $progress%");
  //   //       },
  //   //       onPageStarted: (String url) {
  //   //         debugPrint("Page started loading: $url");
  //   //
  //   //         setState(() {
  //   //           _isLoading = true;
  //   //         });
  //   //       },
  //   //       onPageFinished: (String url) {
  //   //         debugPrint("Page finished loading: $url");
  //   //
  //   //         setState(() {
  //   //           _isLoading = false;
  //   //         });
  //   //       },
  //   //       onHttpError: (HttpResponseError error) {
  //   //         debugPrint("HTTP error: $error");
  //   //         debugPrint("HTTP error: ${error.response}");
  //   //         debugPrint("HTTP error: ${error.request}");
  //   //         debugPrint("HTTP error: ${error.toString()}");
  //   //       },
  //   //       onWebResourceError: (WebResourceError error) {
  //   //         debugPrint("Resource error: ${error.description}");
  //   //       },
  //   //       onNavigationRequest: (NavigationRequest request) {
  //   //         if (request.url.startsWith('https://www.youtube.com/')) {
  //   //           debugPrint("Blocking navigation to: ${request.url}");
  //   //           return NavigationDecision.prevent;
  //   //         }
  //   //         return NavigationDecision.navigate;
  //   //       },
  //   //     ),
  //   //   )
  //   //   ..loadRequest(Uri.parse(savedUrl));
  //
  //   setState(() {
  //     _url = savedUrl;
  //   });
  //   // _controller.reload(); // Reloads the current webpage
  //   // ( _controller.platform).setO
  // }

  String _url = 'https://flutter.dev'; // Default URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DashBoard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
              // Reloads the current webpage
              // webViewController.al
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : InAppWebView(


                  onWebViewCreated: (controller) {
                    _controller = controller;
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                  initialUrlRequest: URLRequest(url: WebUri(_url)),
            initialSettings: InAppWebViewSettings(
                allowFileAccess: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                useOnDownloadStart: true,
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                useShouldInterceptRequest: true, // Example of a setting

                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                useHybridComposition: true),
                ),
        ],
      ),
    );
  }
}
