import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hng_flutter/data/ActiveCheckListLpd.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/data/Locations.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'AmAcceptSelectionScreen.dart';
import 'AmAcceptSelectionScreen_LPD.dart';
import 'common/constants.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/GetChecklist.dart';
import 'data/LPDSection.dart';
import 'OutletSelectScreen.dart';
import 'PageHome.dart';
import 'checkInOutScreenDilo.dart';
import 'checkListItemScreen.dart';
import 'checkListItemScreen_Lpd.dart';
import 'checkListScreen.dart';
import 'checkListScreen_lpd.dart';
import 'imageUploadScreen.dart';
import 'mainCntrl.dart';

class lpdCheckListScreen extends StatefulWidget {
  // const checkListScreen({Key? key}) : super(key: key);

  final int type;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;
  final  ActiveCheckListLpd activeCheckList;

  //0=DILO,1=LPD,2=STORE AUDIT
  // ActiveCheckList activeCheckList;

  lpdCheckListScreen(this.type, this.mGetActvityTypes, this.locationsList,
     this.activeCheckList);

  @override
  State<lpdCheckListScreen> createState() => _lpdCheckListScreenState(
      this.type,
      this.mGetActvityTypes,
      this.locationsList,
      this.activeCheckList);
}

class _lpdCheckListScreenState extends State<lpdCheckListScreen>
    with WidgetsBindingObserver {
  int type;
  GetActvityTypes mGetActvityTypes;
  String locationsList;
  ActiveCheckListLpd activeCheckList;

  // ActiveCheckList activeCheckList;

  _lpdCheckListScreenState(this.type, this.mGetActvityTypes, this.locationsList,
      this.activeCheckList);

  var isSelected = 0;
  var popupVisible = false;
  late int index_;
  bool loading = false;
  var checkListId = '';

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("resumedCheckListScreen");
      getActiveCheckListData();
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

    getActiveCheckListData();
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
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'CheckList id: $checkListId',
                style: const TextStyle(
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
                color: const Color(0x80000000),
                child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.all(20),
                        height: 115,
                        width: 150,
                        child: const Column(
                          children: [
                            CircularProgressIndicator(),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Please wait..'),
                            )
                          ],
                        ))),
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Visibility(
              visible: widget.activeCheckList.checklistEditStatus == "R"
                  ? false
                  : widget.activeCheckList.checklistEditStatus == "A"
                  ? false
                  : checklist_completed_status == "Completed"
                  ? true
                  : false,
              child: InkWell(
                onTap: () {
                  //popup
                  // submitAllDilo();
                  openDialog();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.blue,
                  child: const Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    ));
  }

  Widget checkListView() {
    return mLpdChecklist.length == 0
        ? const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('No records found'),
          )
        : ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  if (widget.activeCheckList.checklistEditStatus == "R") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AmAcceptSelectionScreen_LPD(
                              widget.activeCheckList, mLpdChecklist[index])),
                    ).then((value) {
                      getActiveCheckListData();
                    });
                  } else if (widget.activeCheckList.checklistEditStatus ==
                      "A") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AmAcceptSelectionScreen_LPD(
                              widget.activeCheckList, mLpdChecklist[index])),
                    ).then((value) {getActiveCheckListData();});
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => checkListItemScreen_Lpd(
                              widget.activeCheckList, mLpdChecklist[index])),
                    ).then((value) {
                      getActiveCheckListData();
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            mLpdChecklist[index].sectionName,
                            style: const TextStyle(fontSize: 18),
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
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            mLpdChecklist[index].section_completion_status,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Text(' - '),
                          // Spacer(),
                          Text(
                            mLpdChecklist[index].percentage,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: mLpdChecklist.length,
          );
  }

  List<LPDSection> mLpdChecklist = [];

  String checklist_completed_status = "";

  Future<void> getActiveCheckListData() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var locationCode = widget.locationsList;
      var userID = prefs.getString('userCode') ?? '105060';
      String url;


      url =
          "${Constants.apiHttpsUrl}/lpdaudit/GetLPDChecklistSection/${widget.activeCheckList.lpdChecklistAssignId}";

      final response = await http.get(Uri.parse(url));



      if(response.statusCode==200){
        var responseData = json.decode(response.body);
        if (responseData['message'] == "Success") {
          Map<String, dynamic> map = json.decode(response.body);
          mLpdChecklist = [];
          List<dynamic> data = map["section"];
          setState(() {
            checkListId = map['lpdChecklistId'];
            checklist_completed_status = map['checklist_completed_status'];

          });

          for (var element in data) {
            mLpdChecklist.add(LPDSection.fromJson(element));
          }
        } else {
          showAlert(responseData['message']);
        }
      }else{
        showAlert(response.statusCode);
        _showRetryAlert("Something went wrong..\nStatusCode:${response.statusCode}\nPlease retry");

      }

      setState(() {
        loading = false;
      });

    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      _showRetryAlert("Something went wrong..\nPlease retry");
    }
  }

  void openDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Alert!'),
        content: const Text('Do you want to close the audit?'),
        actions: [
          TextButton(
            child: const Text("Yes"),
            onPressed: () {
              submitWorkFlow();
              Get.back();
            },
          ),
          TextButton(
            child: const Text("No"),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Future<void> submitWorkFlow() async {
    setState(() {
      loading = true;
    });

    final payload =
        '{"lpd_checklist_assign_id":${widget.activeCheckList.lpdChecklistAssignId}}';

     var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        '/RWA_GROOMING_API/api/lpdaudit/WorkFlowStatus',
    );

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "lpd_checklist_assign_id":
        widget.activeCheckList.lpdChecklistAssignId
      }),
    );

    print(response.body);
    print(response.request);
    print(response.statusCode);
    var respo = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
      });
      if (respo['statusCode'] == "200") {
        setState(() {
          loading = false;
        });

        // if()
        // _showSuccessAlert('Checklist Successfully Submitted for Review');
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OutletSelectionScreen(
                widget.mGetActvityTypes,
              )),
        ).then((value) => (){
          getActiveCheckListData();
        });
      } else {
        setState(() {
          loading = false;
        });
        showAlert(respo['message']);
      } // Navigator.pop(context);
    } else {
      setState(() {
        loading = false;
      });
      showAlert('Something went wrong\nPlease contact IT suport');
      // _showAlert('Something went wrong\nPlease contact IT suport');
    }
  }


//showAlert
  Future<void> _showRetryAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
            content:  Text(msg),
// Please retry?'),
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
            CustomElevatedButton(text: 'Retry', onPressed: () {
              Navigator.of(context).pop();
              getActiveCheckListData();
            },),

          ],
        );
      },
    );
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
              padding: const EdgeInsets.all(15),
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
