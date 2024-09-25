import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hng_flutter/data/ActiveCheckListLpd.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/data/Locations.dart';
import 'package:hng_flutter/amCheckListScreen.dart';
import 'package:hng_flutter/lpdCheckListScreen.dart';
import 'package:hng_flutter/presentation/virtualMerch_CheckList_Page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'AmAcceptSelectionScreen.dart';
import 'CreatelpdCheckListScreen.dart';
import 'common/constants.dart';
import 'data/ActiveCheckListAm.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/GetChecklist.dart';
import 'PageHome.dart';
import 'checkInOutScreenDilo.dart';
import 'checkListItemScreen.dart';
import 'checkListItemScreen_Lpd.dart';
import 'checkListScreen_lpd.dart';

// import 'createCheckListScreen_lpd.dart';
import 'imageUploadScreen.dart';
import 'mainCntrl.dart';

class applicableScreen extends StatefulWidget {
  // const checkListScreen({Key? key}) : super(key: key);

  final int type;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  // final GetChecklist mGetChecklist;

  //0=DILO,1=LPD,2=STORE AUDIT
  // ActiveCheckList activeCheckList;

  applicableScreen(
    this.type,
    this.mGetActvityTypes,
    this.locationsList,
  );

  @override
  State<applicableScreen> createState() => _applicableScreenState(
      this.type, this.mGetActvityTypes, this.locationsList);
}

class _applicableScreenState extends State<applicableScreen>
    with WidgetsBindingObserver {
  int type;
  GetActvityTypes mGetActvityTypes;
  String locationsList;

  // GetChecklist mGetChecklist;

  // ActiveCheckList activeCheckList;

  _applicableScreenState(this.type, this.mGetActvityTypes, this.locationsList);

  var isSelected = 0;
  var popupVisible = false;
  late int index_;
  bool loading = false;

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("resumedCheckListScreen");
      getAcitiveCheckListData();
      //do your stuff
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("initState");
    WidgetsBinding.instance.addObserver(this);

    getAcitiveCheckListData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 15),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        '${widget.mGetActvityTypes.auditName}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Applicable Activity',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Stack(
                  children: [
                    checkListView(),
                  ],
                ),
              )
            ],
          ),
          Visibility(
              visible: loading,
              child: Container(
                color: Color(0x80000000),
                child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.all(20),
                        height: 115,
                        width: 150,
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Please wait..'),
                            )
                          ],
                        ))),
              ))
        ],
      ),
    ));
  }

  Widget checkListView() {
    return checkList.length == 0
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('No records found'),
          )
        : ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  if (widget.mGetActvityTypes.auditId == "3") {
                    callCreatelpdCheckList(checkList[index].checklistId, index);
                  } else if (widget.mGetActvityTypes.auditId == "2") {
                    callCreateStoreAuditCheckList(
                        checkList[index].checklistId, index);
                  } else if (widget.mGetActvityTypes.auditId == "5") {
                    callCreateAMCheckList(checkList[index].checklistId, index);
                  } else if (widget.mGetActvityTypes.auditId == "4") {
                    // callCreateEmployeCheckList(checkList[index].checklistId,index);

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => checkListScreen_lpd(
                              1,
                              widget.mGetActvityTypes,
                              widget.locationsList,
                              checkList[index]),
                        )).then((value) {
                      if (context.mounted) {
                        getAcitiveCheckListData();
                      }
                    });
                    // Active_CheckList
                  }
                  else if(widget.mGetActvityTypes.auditId == "6"){
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VirtualMerchCheckListPage(
                              1,
                              widget.mGetActvityTypes,
                              widget.locationsList,
                              ),
                        )).then((value) {
                      if (context.mounted) {
                        getAcitiveCheckListData();
                      }
                    });
                  }
                },
                child: Container(
                  // color: Colors.white,
                  margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  padding: const EdgeInsets.only(
                      left: 10, top: 30, right: 20, bottom: 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Color(0xFFBDBDBD), blurRadius: 2)
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  // height: 85,
                  child: Row(
                    children: [
                      Text(
                        '${checkList[index].checklistName}',
                        style: TextStyle(fontSize: 18),
                      ),
                      const Spacer(),
                      Container(
                        height: 35,
                        margin: const EdgeInsets.only(right: 15),
                        width: 1,
                        color: Colors.grey[400],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: checkList.length,
          );
  }

  List<GetChecklist> checkList = [];
  List<ActiveCheckListLpd> activeCheckListLpd = [];
  List<ActiveCheckListAm> activeCheckListAm = [];

  Future<void> getAcitiveCheckListData() async {
    try {
      setState(() {
        loading = true;
      });

      var url;

      if (widget.mGetActvityTypes.auditId == "3") {
        url =
            "${Constants.apiHttpsUrl}/lpdaudit/GetChecklistId/${widget.mGetActvityTypes.auditId}";
      } else if (widget.mGetActvityTypes.auditId == "2") {
        url =
            "${Constants.apiHttpsUrl}/StoreAudit/GetChecklistId/${widget.mGetActvityTypes.auditId}";
      } else if (widget.mGetActvityTypes.auditId == "5") {
        url =
            "${Constants.apiHttpsUrl}/AreaManager/GetChecklistId/${widget.mGetActvityTypes.auditId}";
      } else if (widget.mGetActvityTypes.auditId == "4") {
        url =
            "${Constants.apiHttpsUrl}/Employee/GetChecklistId/${widget.mGetActvityTypes.auditId}";
      }
      else if (widget.mGetActvityTypes.auditId == "6") {
        url =
        "${Constants.apiHttpsUrl}/Employee/GetChecklistId/${widget.mGetActvityTypes.auditId}";
      }

      print("ACTIVEEEEEE " + url);
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 3));
      print(response.body);

      var responseData = json.decode(response.body);

      //Creating a list to store input data;
      checkList = [];
      activeCheckListAm = [];

      Iterable l = json.decode(response.body);
      checkList = List<GetChecklist>.from(
          l.map((model) => GetChecklist.fromJson(model)));
      print("checkList.length");
      print(checkList.length);

      // return checkList;
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showRetryAlert();
    }
  }

  Future<void> _showRetryAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text('Network issue\nPlease retry'),
          actions: <Widget>[
            /*  Container(
              padding: EdgeInsets.all(15),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white))),
            ),*/
            Container(
              padding: EdgeInsets.all(15),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    getAcitiveCheckListData();
                    // submitCheckList();
                  },
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white))),
            ),
          ],
        );
      },
    );
  }

  Future<void> callCreatelpdCheckList(var id, int index) async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var locationCode = widget.locationsList;
      var userID = prefs.getString('userCode') ?? '105060';
      String url;
      url =
          "${Constants.apiHttpsUrl}/lpdaudit/CreateLPDChecklist?locationcode=$locationCode&createdby=$userID&checklistid=$id";
      final response = await http.get(Uri.parse(url));
      // print(response);

      // print(urdl);
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        var responseData = json.decode(response.body);
        print(responseData);

        if (responseData['statusCode'] == "200") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => checkListScreen_lpd(
                    1,
                    widget.mGetActvityTypes,
                    widget.locationsList,
                    checkList[index]),
              )).then((value) => () {
                getAcitiveCheckListData();
              });
        }
        // final lpdChecklist = lpdChecklistFromJson(responseData);

        if (responseData['message'] == "LPDChecklist added Successfully") {
          /*  Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => checkListScreen_lpd(
                  1,
                  widget.mGetActvityTypes,
                  widget.locationsList,
                  checkList[index]),
            ));
*/
          // Map<String, dynamic> map = json.decode(response.body);
          // if(map[])

/*    HeaderQuestion headerQuestionFromJson(String str) => HeaderQuestion.fromJson(json.decode(str));

    String headerQuestionToJson(HeaderQuestion data) => json.encode(data.toJson());
    final headerQuestion_ = headerQuestionFromJson(response.body);*/

          /* mLpdChecklist = [];
        List<dynamic> data = map["section"];
        // checkListId
        setState(() {
          checkListId = map['lpdChecklistId'];
        });
        // print("checklist_Current_Statssssssss");

        data.forEach((element) {
          mLpdChecklist.add(LPDSection.fromJson(element));
        });*/
        } else if (responseData['message'] ==
            "USER NOT ACCESS/ALREADY ADDED!") {
          showAlert(responseData['message']);
        }
      } else {
        showAlert('Something went wrong please IT support');
      }

      // //Creating a list to store input data  ;
      // mLpdChecklist = [];
      // // activeCheckListLpd = [];
      //
      // Iterable l = json.decode(response.body);
      // mLpdChecklist = List<LpdChecklist>.from(
      //     l.map((model) => LpdChecklist.fromJson(model)));
      // print("mLpdChecklist.length");
      // print(mLpdChecklist.length);

      // return checkList;
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      _showRetryAlert();
    }
  }

  Future<void> callCreateStoreAuditCheckList(var id, int index) async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var locationCode = widget.locationsList;
      var userID = prefs.getString('userCode') ?? '105060';
      String url;

      url =
          "Constants.apiHttpsUrl/StoreAudit/CreateStoreChecklist?locationcode=$locationCode&createdby=$userID&checklistid=$id";

      final response = await http.get(Uri.parse(url));

      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        print(responseData);

        if (responseData['statusCode'] == "200") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => checkListScreen_lpd(
                    1,
                    widget.mGetActvityTypes,
                    widget.locationsList,
                    checkList[index]),
              )).then((value) => () {
                getAcitiveCheckListData();
              });
        } else if (responseData['statusCode'] == "201") {
          showAlert(responseData['message']);
        }
        // final lpdChecklist = lpdChecklistFromJson(responseData);

//         if (responseData['message'] == "LPDChecklist added Successfully"){
//
//           /*  Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => checkListScreen_lpd(
//                   1,
//                   widget.mGetActvityTypes,
//                   widget.locationsList,
//                   checkList[index]),
//             ));
// */
//           // Map<String, dynamic> map = json.decode(response.body);
//           // if(map[])
//
// /*    HeaderQuestion headerQuestionFromJson(String str) => HeaderQuestion.fromJson(json.decode(str));
//
//     String headerQuestionToJson(HeaderQuestion data) => json.encode(data.toJson());
//     final headerQuestion_ = headerQuestionFromJson(response.body);*/
//
//           /* mLpdChecklist = [];
//         List<dynamic> data = map["section"];
//         // checkListId
//         setState(() {
//           checkListId = map['lpdChecklistId'];
//         });
//         // print("checklist_Current_Statssssssss");
//
//         data.forEach((element) {
//           mLpdChecklist.add(LPDSection.fromJson(element));
//         });*/
//
//         }else if(responseData['message'] == "USER NOT ACCESS/ALREADY ADDED!"){
//           showAlert(responseData['message']);
//         }
      } else {
        showAlert(responseData['message']);
      }

      // //Creating a list to store input data  ;
      // mLpdChecklist = [];
      // // activeCheckListLpd = [];
      //
      // Iterable l = json.decode(response.body);
      // mLpdChecklist = List<LpdChecklist>.from(
      //     l.map((model) => LpdChecklist.fromJson(model)));
      // print("mLpdChecklist.length");
      // print(mLpdChecklist.length);

      // return checkList;
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      _showRetryAlert();
    }
  }

  Future<void> callCreateAMCheckList(var id, int index) async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var locationCode = widget.locationsList;
      var userID = prefs.getString('userCode') ?? '105060';
      String url;

      url =
          "${Constants.apiHttpsUrl}/AreaManager/CreateareamanagerChecklist?locationcode=$locationCode&createdby=$userID&checklistid=$id";

      final response = await http.get(Uri.parse(url));

      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        print(responseData);

        if (responseData['statusCode'] == "200") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => checkListScreen_lpd(
                    1,
                    widget.mGetActvityTypes,
                    widget.locationsList,
                    checkList[index]),
              )).then((value) {
            if (context.mounted) {
              getAcitiveCheckListData();
            }
          });
        } else if (responseData['statusCode'] == "201") {
          showAlert(responseData['message']);
        }
        // final lpdChecklist = lpdChecklistFromJson(responseData);

//         if (responseData['message'] == "LPDChecklist added Successfully"){
//
//           /*  Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => checkListScreen_lpd(
//                   1,
//                   widget.mGetActvityTypes,
//                   widget.locationsList,
//                   checkList[index]),
//             ));
// */
//           // Map<String, dynamic> map = json.decode(response.body);
//           // if(map[])
//
// /*    HeaderQuestion headerQuestionFromJson(String str) => HeaderQuestion.fromJson(json.decode(str));
//
//     String headerQuestionToJson(HeaderQuestion data) => json.encode(data.toJson());
//     final headerQuestion_ = headerQuestionFromJson(response.body);*/
//
//           /* mLpdChecklist = [];
//         List<dynamic> data = map["section"];
//         // checkListId
//         setState(() {
//           checkListId = map['lpdChecklistId'];
//         });
//         // print("checklist_Current_Statssssssss");
//
//         data.forEach((element) {
//           mLpdChecklist.add(LPDSection.fromJson(element));
//         });*/
//
//         }else if(responseData['message'] == "USER NOT ACCESS/ALREADY ADDED!"){
//           showAlert(responseData['message']);
//         }
      } else {
        showAlert(responseData['message']);
      }

      // //Creating a list to store input data  ;
      // mLpdChecklist = [];
      // // activeCheckListLpd = [];
      //
      // Iterable l = json.decode(response.body);
      // mLpdChecklist = List<LpdChecklist>.from(
      //     l.map((model) => LpdChecklist.fromJson(model)));
      // print("mLpdChecklist.length");
      // print(mLpdChecklist.length);

      // return checkList;
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      _showRetryAlert();
    }
  }

  Future<void> callCreateEmployeCheckList(var id, int index) async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var locationCode = widget.locationsList;
      var userID = prefs.getString('userCode') ?? '105060';
      String url;

      url =
          "${Constants.apiHttpsUrl}/Employee/CreateareamanagerChecklist?locationcode=$locationCode&createdby=$userID&checklistid=$id";

      final response = await http.get(Uri.parse(url));
      // print(response);

      // print(urdl);
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        print(responseData);

        if (responseData['statusCode'] == "200") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => checkListScreen_lpd(
                    1,
                    widget.mGetActvityTypes,
                    widget.locationsList,
                    checkList[index]),
              )).then((value) {
            if (context.mounted) {
              getAcitiveCheckListData();
            }
          });
        } else if (responseData['statusCode'] == "201") {
          showAlert(responseData['message']);
        }
        // final lpdChecklist = lpdChecklistFromJson(responseData);

//         if (responseData['message'] == "LPDChecklist added Successfully"){
//
//           /*  Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => checkListScreen_lpd(
//                   1,
//                   widget.mGetActvityTypes,
//                   widget.locationsList,
//                   checkList[index]),
//             ));
// */
//           // Map<String, dynamic> map = json.decode(response.body);
//           // if(map[])
//
// /*    HeaderQuestion headerQuestionFromJson(String str) => HeaderQuestion.fromJson(json.decode(str));
//
//     String headerQuestionToJson(HeaderQuestion data) => json.encode(data.toJson());
//     final headerQuestion_ = headerQuestionFromJson(response.body);*/
//
//           /* mLpdChecklist = [];
//         List<dynamic> data = map["section"];
//         // checkListId
//         setState(() {
//           checkListId = map['lpdChecklistId'];
//         });
//         // print("checklist_Current_Statssssssss");
//
//         data.forEach((element) {
//           mLpdChecklist.add(LPDSection.fromJson(element));
//         });*/
//
//         }else if(responseData['message'] == "USER NOT ACCESS/ALREADY ADDED!"){
//           showAlert(responseData['message']);
//         }
      } else {
        showAlert(responseData['message']);
      }

      // //Creating a list to store input data  ;
      // mLpdChecklist = [];
      // // activeCheckListLpd = [];
      //
      // Iterable l = json.decode(response.body);
      // mLpdChecklist = List<LpdChecklist>.from(
      //     l.map((model) => LpdChecklist.fromJson(model)));
      // print("mLpdChecklist.length");
      // print(mLpdChecklist.length);

      // return checkList;
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      _showRetryAlert();
    }
  }

  Future<void> showAlert(var msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(msg),
          actions: <Widget>[
            /*  Container(
              padding: EdgeInsets.all(15),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white))),
            ),*/
            Container(
              padding: EdgeInsets.all(15),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // getAcitiveCheckListData();
                    // submitCheckList();
                  },
                  child:
                      const Text('Ok', style: TextStyle(color: Colors.white))),
            ),
          ],
        );
      },
    );
  }
}
