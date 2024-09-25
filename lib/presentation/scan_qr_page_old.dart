// import 'package:flutter/material.dart';
// import 'package:hng_flutter/presentation/qr_view.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
//
// class ScanQrPage extends StatefulWidget {
//   const ScanQrPage({super.key});
//
//   @override
//   State<ScanQrPage> createState() => _ScanQrPageState();
// }
//
// class _ScanQrPageState extends State<ScanQrPage> {
//   TextEditingController phoneController = TextEditingController();
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   Barcode? result;
//   QRViewController? controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Stack(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(36),
//             margin: const EdgeInsets.all(36),
//             decoration:  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [
//               const BoxShadow(
//                 color: Colors.grey,
//               ),
//
//             ]),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const Text(
//                   'MOBILE NUMBER',
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                       color: Colors.black),
//                 ),
//                 const SizedBox(
//                   height: 16,
//                 ),
//                 const Text(
//                   'Please enter your mobile number',
//                   style: TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 const Spacer(),
//                 TextField(
//                   controller: phoneController,
//                   keyboardType: TextInputType.phone,
//                   maxLength: 10,
//                   decoration:
//                       const InputDecoration(
//                         hintText: 'Enter Phone number',),
//
//                 ),
//                 const Spacer(),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: SizedBox(
//                     height: 46,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (phoneController.text.isNotEmpty &&
//                             phoneController.text.length == 10) {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => QRViewExample(
//                                         phoneController.text.toString(),
//                                         phone: phoneController.text.toString(),
//                                       )));
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                               14), // Adjust the value as needed
//                         ),
//                       ),
//                       child: const Text('SUBMIT'),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
