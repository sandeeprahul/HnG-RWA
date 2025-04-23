// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:file_picker/file_picker.dart';
//
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:file_picker/file_picker.dart';
//
// class MyWebView extends StatefulWidget {
//   @override
//   _MyWebViewState createState() => _MyWebViewState();
// }
//
// class _MyWebViewState extends State<MyWebView> {
//   final GlobalKey webViewKey = GlobalKey();
//   InAppWebViewController? webViewController;
//
//   @override
//   Widget build(BuildContext context) {
//     return InAppWebView(
//       key: webViewKey,
//       initialUrlRequest: URLRequest(url: WebUri("https://yourwebsite.com")),
//       initialSettings: InAppWebViewSettings(
//         javaScriptEnabled: true,
//         mediaPlaybackRequiresUserGesture: false,
//         allowsInlineMediaPlayback: true,
//       ),
//       onWebViewCreated: (controller) {
//         webViewController = controller;
//       },
//       onLoadStop: (controller, url) async {
//         // Inject JavaScript to handle file uploads
//         await controller.evaluateJavascript(source: """
//           // Create a hidden file input
//           const flutterFileInput = document.createElement('input');
//           flutterFileInput.type = 'file';
//           flutterFileInput.style.display = 'none';
//           document.body.appendChild(flutterFileInput);
//
//           // Intercept clicks on file inputs
//           document.addEventListener('click', function(e) {
//             if (e.target.tagName === 'INPUT' && e.target.type === 'file') {
//               e.preventDefault();
//               flutterFileInput.click();
//             }
//           });
//
//           // Handle file selection
//           flutterFileInput.addEventListener('change', function(e) {
//             if (this.files.length > 0) {
//               const file = this.files[0];
//               // Create a custom event with file data
//               const event = new CustomEvent('flutter-file-selected', {
//                 detail: {
//                   name: file.name,
//                   size: file.size,
//                   type: file.type
//                 }
//               });
//               document.dispatchEvent(event);
//             }
//           });
//         """);
//       },
//       onFileChooserRequest: (controller, request) async {
//         final result = await FilePicker.platform.pickFiles();
//         if (result != null && result.files.isNotEmpty) {
//           return FileChooserResponse(
//             filePaths: result.files.map((f) => f.path!).whereType<String>().toList(),
//           );
//         }
//         return FileChooserResponse(filePaths: []);
//       },
//     );
//   }
// }