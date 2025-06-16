import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

// ... (main function and MyApp as before) ...

class WebViewScreen extends StatefulWidget {
  final int from;
  final String  userId;

  const WebViewScreen({super.key, required this.userId, required this.from});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController _webViewController;
  String _pageTitle = "Loading...";
  bool _isCameraActive = false;
  bool _isMicrophoneActive = false;

  // Now using your actual URL
  final String _targetUrl = "https://rwaweb.healthandglowonline.co.in/hgrwabrowser1/hngposWebbrowser.aspx?userid=";
  final String _targetUrlToReports = "https://rwaweb.healthandglowonline.co.in/hgrwabrowser/hngposWebbrowser.aspx?userid=";

  @override
  void initState() {
    super.initState();
    _requestAppPermissions(); // Request app permissions on startup
  }

  Future<void> _requestAppPermissions() async {
    // Request camera and microphone permissions for the Flutter app itself
    // These are essential for the WebView to even *ask* for permissions.
    await [
      Permission.camera,
      Permission.microphone,
    ].request();

    // While not directly for WebRTC, if the page also uses file uploads, ensure these:
    await [
      Permission.storage, // For older Android versions (< Android 13)
      Permission.photos, // For iOS photo library
      // For Android 13+
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.from == 1 ? "Forms & Reports" : "DashBoard")),

      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.from == 1 ? "$_targetUrlToReports${widget.userId}" : "$_targetUrl${widget.userId}")), // Loading your remote URL
        initialSettings: InAppWebViewSettings( // Use InAppWebViewSettings
          javaScriptEnabled: true, // Common options directly here
          mediaPlaybackRequiresUserGesture: false,
          allowFileAccess: true,
          javaScriptCanOpenWindowsAutomatically: true,
          // If you need specific Android options, use android.

          // If you need specific Web options, use web.
          // web: WebInAppWebViewSettings(),
        ),        onWebViewCreated: (controller) {
          _webViewController = controller;
          // Register JS handlers for communication from the web page
          _webViewController.addJavaScriptHandler(
              handlerName: 'cameraStatusChanged',
              callback: (args) {
                if (args.isNotEmpty && args[0] is bool) {
                  setState(() {
                    _isCameraActive = args[0];
                  });
                  print("Flutter received cameraStatusChanged: ${args[0]}");
                }
              });
          _webViewController.addJavaScriptHandler(
              handlerName: 'microphoneStatusChanged',
              callback: (args) {
                if (args.isNotEmpty && args[0] is bool) {
                  setState(() {
                    _isMicrophoneActive = args[0];
                  });
                  print("Flutter received microphoneStatusChanged: ${args[0]}");
                }
              });
        },
        onLoadStart: (controller, url) {
          setState(() {
            _pageTitle = url?.toString() ?? "Loading...";
          });
        },
        onLoadStop: (controller, url) async {
          setState(() {
            _pageTitle = url?.toString() ?? "Loaded";
          });
          String? title = await controller.getTitle();
          if (title != null) {
            setState(() {
              _pageTitle = title;
            });
          }
        },
        // **THIS IS THE MOST CRUCIAL CALLBACK FOR WEBVIEW PERMISSIONS**
        onPermissionRequest: (controller, permissionRequest) async {
          print("Web page requested permissions: ${permissionRequest.resources}");

          // Grant all requested permissions. In a real app, you might show a user dialog.
          return PermissionResponse(
            resources: permissionRequest.resources,
            action: PermissionResponseAction.GRANT,
          );
        },
        onCameraCaptureStateChanged: (controller, oldState, newState) async {
          print("Camera state changed: $oldState -> $newState");

        },
        onMicrophoneCaptureStateChanged: (controller, oldState, newState) async {
          print("Microphone state changed: $oldState -> $newState");

        },
        onConsoleMessage: (controller, consoleMessage) {
          print("WebView Console: ${consoleMessage.message}");
        },
        onReceivedError: (controller, request, error) {
          print("WebView Error: ${error.description} (Code: ${error}) for URL: ${request.url}");
        },
      ),
    );
  }
}