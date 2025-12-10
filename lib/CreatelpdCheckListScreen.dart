// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:hng_flutter/data/GetActvityTypes.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'AmAcceptSelectionScreen.dart';
// import 'AmAcceptSelectionScreen_LPD.dart';
// import 'common/constants.dart';
// import 'data/ActiveCheckListModel.dart';
// import 'data/GetChecklist.dart';
// import 'data/LPDSection.dart';
// import 'PageHome.dart';
// import 'checkInOutScreenDilo.dart';
// import 'checkListItemScreen.dart';
// import 'checkListItemScreen_Lpd.dart';
// import 'checkListScreen.dart';
// import 'check_list_segregation_screen.dart';
// import 'imageUploadScreen.dart';
// import 'mainCntrl.dart';
//
// class CreatelpdCheckListScreen extends StatefulWidget {
//   // const checkListScreen({Key? key}) : super(key: key);
//
//  final int type;
//  final GetActvityTypes mGetActvityTypes;
//  final String locationsList;
//   // ActiveCheckListLpd activeCheckList;
//
//   //0=DILO,1=LPD,2=STORE AUDIT
//   // ActiveCheckList activeCheckList;
//
//   CreatelpdCheckListScreen(
//       this.type, this.mGetActvityTypes, this.locationsList/*, this. activeCheckList*/);
//
//   @override
//   State<CreatelpdCheckListScreen> createState() => _CreatelpdCheckListScreenState(
//       this.type, this.mGetActvityTypes, this.locationsList, /*, this. activeCheckList*/);
// }
//
// class _CreatelpdCheckListScreenState extends State<CreatelpdCheckListScreen>
//     with WidgetsBindingObserver {
//   int type;
//   GetActvityTypes mGetActvityTypes;
//   String locationsList;
//   // ActiveCheckListLpd activeCheckList;
//
//
//   // ActiveCheckList activeCheckList;
//
//   _CreatelpdCheckListScreenState(
//       this.type, this.mGetActvityTypes, this.locationsList,/*, this. activeCheckList*/);
//
//   var isSelected = 0;
//   var popupVisible = false;
//   late int index_;
//   bool loading = false;
//   var checkListId = '';
//
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       print("resumedCheckListScreen");
//       getAcitiveCheckListData();
//       //do your stuff
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     print("initState");
//     WidgetsBinding.instance.addObserver(this);
//
//     getAcitiveCheckListData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SafeArea(
//       child: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 20, top: 15),
//                 child: Row(
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: const Padding(
//                         padding: EdgeInsets.only(left: 15),
//                         child: Icon(Icons.arrow_back),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 20),
//                       child: Text(
//                         '${widget.mGetActvityTypes.auditName}',
//                         style: const TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 'CheckList id: $checkListId',
//                 style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold),
//               ),
//               Expanded(
//                 child: Stack(
//                   children: [
//                     checkListView(),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           Visibility(
//               visible: loading,
//               child: Container(
//                 color: const Color(0x80000000),
//                 child: Center(
//                     child: Container(
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(5)),
//                         padding: const EdgeInsets.all(20),
//                         height: 115,
//                         width: 150,
//                         child: const Column(
//                           children: [
//                             CircularProgressIndicator(),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('Please wait..'),
//                             )
//                           ],
//                         ))),
//               ))
//         ],
//       ),
//     ));
//   }
//
//   Widget checkListView() {
//     return mLpdChecklist.isEmpty
//         ? const Padding(
//             padding: EdgeInsets.all(10.0),
//             child: Text('No records found'),
//           )
//         : ListView.builder(
//             itemBuilder: (BuildContext context, int index) {
//               return InkWell(
//                 onTap: (){
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => checkListScreen_lpd( 1,
//                       widget.mGetActvityTypes,
//                       widget.locationsList,
//                       ),
//                   ));
//                   // checkListScreen_lpd
//
//                   /*if(widget.activeCheckList.checklistEditStatus=="R"){
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => AmAcceptSelectionScreen_LPD(widget.activeCheckList,mLpdChecklist[index])),
//                     );
//                   }else if(widget.activeCheckList.checklistEditStatus=="A"){
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => AmAcceptSelectionScreen_LPD(widget.activeCheckList,mLpdChecklist[index])),
//                     );
//                   }else{
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => checkListItemScreen_Lpd(widget.activeCheckList,mLpdChecklist[index])),
//                     );
//                   }
// */
//
//
//                 },
//                 child: Container(
//                   // color: Colors.white,
//                   margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
//                   padding: const EdgeInsets.only(
//                       left: 10, top: 30, right: 20, bottom: 30),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Color(0xFFBDBDBD), blurRadius: 2)
//                     ],
//                     borderRadius: BorderRadius.all(Radius.circular(5)),
//                   ),
//                   // height: 85,
//                   child: Row(
//                     children: [
//                       Text(
//                         mLpdChecklist[index].sectionName,
//                         style: const TextStyle(fontSize: 18),
//                       ),
//                       const Spacer(),
//                       Container(
//                         height: 35,
//                         margin: const EdgeInsets.only(right: 15),
//                         width: 1,
//                         color: Colors.grey[400],
//                       ),
//                       Icon(
//                         Icons.arrow_forward_ios,
//                         color: Colors.grey[400],
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             },
//             itemCount: mLpdChecklist.length,
//           );
//   }
//
//   List<LPDSection> mLpdChecklist = [];
//
//   Future<void> getAcitiveCheckListData() async {
//     try {
//       setState(() {
//         loading = true;
//       });
//       final prefs = await SharedPreferences.getInstance();
//       var locationCode = widget.locationsList;
//       var userID = prefs.getString('userCode') ?? '105060';
//       var url;
//
//       url =
//           "${Constants.apiHttpsUrl}/lpdaudit/CreateLPDChecklist?locationcode=$locationCode&createdby=$userID&checklistid=${widget.checkList.checklistId}";
//
//       final response = await http.get(Uri.parse(url));
//       print(response);
//
//       if(response.statusCode==200){
//         // print(urdl);
//
//         var responseData = json.decode(response.body);
//         // final lpdChecklist = lpdChecklistFromJson(responseData);
//
//         if (responseData['message'] == "LPDChecklist added Successfully"){
//
//           Map<String, dynamic> map = json.decode(response.body);
//           // if(map[])
//
// /*    HeaderQuestion headerQuestionFromJson(String str) => HeaderQuestion.fromJson(json.decode(str));
//
//     String headerQuestionToJson(HeaderQuestion data) => json.encode(data.toJson());
//     final headerQuestion_ = headerQuestionFromJson(response.body);*/
//
//           mLpdChecklist = [];
//           List<dynamic> data = map["section"];
//           // checkListId
//           setState(() {
//             checkListId = map['lpdChecklistId'];
//           });
//           // print("checklist_Current_Statssssssss");
//
//           data.forEach((element) {
//             mLpdChecklist.add(LPDSection.fromJson(element));
//           });
//
//         }else if(responseData['message'] == "USER NOT ACCESS/ALREADY ADDED!"){
//           showAlert(responseData['message']);
//         }
//
//
//         // //Creating a list to store input data  ;
//         // mLpdChecklist = [];
//         // // activeCheckListLpd = [];
//         //
//         // Iterable l = json.decode(response.body);
//         // mLpdChecklist = List<LpdChecklist>.from(
//         //     l.map((model) => LpdChecklist.fromJson(model)));
//         // print("mLpdChecklist.length");
//         // print(mLpdChecklist.length);
//
//         // return checkList;
//         setState(() {
//           loading = false;
//         });
//       }else{
//         showAlert("Something went wrong..\nStatusCode:${response.statusCode}");
//       }
//
//     } catch (e) {
//       print(e);
//       setState(() {
//         loading = false;
//       });
//       _showRetryAlert();
//     }
//   }
// //showAlert
//   Future<void> _showRetryAlert() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Alert!'),
//             content: const Text(Constants.networkIssue),
// // Please retry?'),
//           actions: <Widget>[
//             /*  Container(
//               padding: EdgeInsets.all(15),
//               decoration:
//                   const BoxDecoration(color: CupertinoColors.activeBlue),
//               child: InkWell(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     // submitCheckList();
//                   },
//                   child: const Text('Cancel',
//                       style: TextStyle(color: Colors.white))),
//             ),*/
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration:
//                   const BoxDecoration(color: CupertinoColors.activeBlue),
//               child: InkWell(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     getAcitiveCheckListData();
//                     // submitCheckList();
//                   },
//                   child: const Text('Retry',
//                       style: TextStyle(color: Colors.white))),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   Future<void> showAlert(var msg) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Alert!'),
//           content: Text(msg),
//           actions: <Widget>[
//             /*  Container(
//               padding: EdgeInsets.all(15),
//               decoration:
//                   const BoxDecoration(color: CupertinoColors.activeBlue),
//               child: InkWell(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     // submitCheckList();
//                   },
//                   child: const Text('Cancel',
//                       style: TextStyle(color: Colors.white))),
//             ),*/
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration:
//               const BoxDecoration(color: CupertinoColors.activeBlue),
//               child: InkWell(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     // getAcitiveCheckListData();
//                     // submitCheckList();
//                   },
//                   child: const Text('Ok',
//                       style: TextStyle(color: Colors.white))),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
