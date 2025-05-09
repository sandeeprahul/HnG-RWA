import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/data/ActiveCheckListStoreAudit.dart';
import 'package:hng_flutter/data/HeaderQuesStoreAudit.dart';
import 'package:hng_flutter/data/LPDSection.dart';
import 'package:hng_flutter/checkListScreen.dart';
import 'package:hng_flutter/helper/simpleDialog.dart';
import 'package:hng_flutter/submitCheckListScreen.dart';
import 'package:hng_flutter/submitCheckListScreen_AM.dart';
import 'package:hng_flutter/submitCheckListScreen_Lpd.dart';
import 'package:hng_flutter/submitCheckListScreen_StoreAudit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/constants.dart';
import 'data/ActiveCheckListAm.dart';
import 'data/ActiveCheckListLpd.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/AuditSummary.dart';
import 'data/HeaderQuesLpd.dart';
import 'data/HeaderQuesStoreAM.dart';
import 'data/HeaderQuestion.dart';

class checkListItemScreen_AM extends StatefulWidget
    with WidgetsBindingObserver {
  // const checkListItemScreen({Key? key}) : super(key: key);
 final ActiveCheckListAm activeCheckList;
 final LPDSection mLpdChecklist;

  checkListItemScreen_AM(this.activeCheckList, this. mLpdChecklist);

  @override
  State<checkListItemScreen_AM> createState() =>
      _checkListItemScreen_AMState(this.activeCheckList,this. mLpdChecklist);
}

class _checkListItemScreen_AMState extends State<checkListItemScreen_AM>
    with WidgetsBindingObserver {
  ActiveCheckListAm activeCheckList;
  LPDSection mLpdChecklist;

  _checkListItemScreen_AMState(this.activeCheckList,this. mLpdChecklist);

  // late final Future myFuture = getData();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    getData();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getData();
      //do your stuff
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = widget.activeCheckList.publishDate;
    DateTime parseDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('MMM dd yyyy');
    var outputDate = outputFormat.format(inputDate);

    //starttime
    String start_time = widget.activeCheckList.startTime;
    DateTime start_time_ = DateFormat("dd-MM-yyyy HH:mm:ss").parse(start_time);
    var startTime_ = DateTime.parse(start_time_.toString());
    var startTimeFormat = DateFormat('hh:mm a');
    var outputTime = startTimeFormat.format(startTime_);

    //outtime
    String endTime = widget.activeCheckList.endTime;
    DateTime endTime_ = DateFormat("dd-MM-yyyy HH:mm:ss").parse(endTime);
    var endTime__ = DateTime.parse(endTime_.toString());
    // var startTimeFormat = DateFormat('hh:mm a');

    var enddTime = startTimeFormat.format(endTime__);

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
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'AM Store Audit',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                // color: Colors.white,
                // margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                // padding: EdgeInsets.only(left: 10, top: 10, right: 10),

                height: 85,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '${widget.activeCheckList.checklistName} for $outputDate',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Outlet name : ${widget.activeCheckList.locationName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Checklist No : ${widget.activeCheckList.amChecklistAssignId} ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          '$outputTime - $enddTime',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child:

                   ListView.builder(
                      itemCount: headerQuestion.length,
                      itemBuilder: (context, pos) {
                        final checkList = headerQuestion[pos];

                        /*  var time = snapshot.data[pos].endTime;
                                      int idx = time.indexOf("T");
                                      List parts = [
                                        time.substring(0, idx).trim(),
                                        time.substring(idx + 1).trim()
                                      ];*/
                        // var time_ = parts[1];
                        return InkWell(
                          onTap: () {
                            // checkLocation();
                            /*  if (headerQuestion[pos]
                                      .checklistEditStatus == //checklistProgressStatus
                                  "E") {
                                // ||headerQuestion[pos].checklistEditStatus =="P"
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          submitCheckListScreen_Lpd(
                                              headerQuestion[pos],
                                              widget.activeCheckList,

                                              0,widget.mLpdChecklist)),
                                ).then((value) {
                                  getData();
                                });
                              }*/
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      submitCheckListScreen_AM(
                                          checkList,
                                          widget.activeCheckList,
                                          0,widget.mLpdChecklist,headerQuestion, position: pos,)),
                            ).then((value) {
                              getData();
                            });
                          },
                          child: listItem(pos,checkList),
                        );
                      })
              ))
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Visibility(
              visible: showsubmitBtn,
              child: InkWell(
                onTap: () {
                  //popup
                  // submitAllDilo();
                  // openDialog();
                  showAuditSummaryDialog(context);

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
              ))
        ],
      ),
    ));
  }

  void openDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Alert!'),
        content: const Text('Do you want to Close this Section of Am Store Audit?'),
        actions: [
          TextButton(
            child: const Text("Yes",style: TextStyle(color: Colors.white),),//
            onPressed: () {
              Get.back();
              Navigator.pop(context);
              showAuditSummaryDialog(context);

              // submitAllDilo();
            },
          ),
          TextButton(
            child: const Text("No",style: TextStyle(color: Colors.white)),
            onPressed: (){
              Get.back();
            },
          ),
        ],

      ),
    );
  }


  Widget listItem(int pos, HeaderQuesStoreAM checkList) {
    //28-11-2024 11:19:10
    String startTime = checkList.startTime;
    DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(startTime);
    DateTime submitTimeDate = DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(checkList.updated_by_datetime);
    var inputDate = DateTime.parse(parseDate.toString());
    var subT = DateTime.parse(submitTimeDate.toString());
    var outputFormat = DateFormat('hh:mm a');
    var outputFormatSub = DateFormat('MMM dd yyyy hh:mm a');

    var outputDate = outputFormat.format(inputDate);
    var updatedByDatetime = outputFormatSub.format(subT);

    var status = checkList.checklistProgressStatus;
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [BoxShadow()]),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    checkList.itemName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Visibility(
                    visible: status == 'Completed'
                        ? false
                        : status == 'InProcess'
                            ? false
                            : true,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.orangeAccent,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        const Text('Submission Timeline : ',
                            style: TextStyle(fontSize: 13)),
                        Text(outputDate,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: status == 'Completed'
                        ? true
                        : status == 'InProcess'
                            ? true
                            : false,
                    child: Row(
                      children: [
                        const Text('Updated by : ',
                            style: TextStyle(fontSize: 13)),
                        Text(
                            '${checkList.updated_by}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Visibility(
                    visible: status == 'Completed'
                        ? true
                        : status == 'InProcess'
                            ? true
                            : false,
                    child: Row(
                      children: [
                        const Text('Updated on : ',
                            style: TextStyle(fontSize: 13)),
                        Text(updatedByDatetime,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 1,
                bottom: 1,
                top: 1,
                child: checkList.checklistEditStatus != 'C'
                    ? const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 25,
                      )
                    : const Icon(
                        Icons.check,
                        color: Colors.blue,
                        size: 25,
                      ),
              ),
            ],
          ),
        ),
      /*  Visibility(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(right: 40, top: 10),
              child: CircleAvatar(
                radius: 4.5,
                backgroundColor: headerQuestion[pos].non == "1"
                    ? Colors.red
                    : headerQuestion[pos].non_compliance_flag == ""?Colors.transparent: Colors.green,
              ),
            ),
          ),
          visible: false,
        ),*/
      ],
    );
  }


  List<HeaderQuesStoreAM> headerQuestion = [];

  String checklist_Header_Status = '';
  String checklist_Current_Stats = '';
  bool showsubmitBtn = false;

  void getData() async {
    setState(() {
      loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '105060';
      String url = "${Constants.apiHttpsUrlTest}/AreaManager/HeaderQuestion/${widget.activeCheckList.amChecklistAssignId}/${widget.mLpdChecklist.sectionId}/$userID";

      print(url);
      final response = await http.get(Uri.parse(url)).timeout(const Duration(milliseconds: 2500));

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        Map<String, dynamic> map = responseData;
        List<dynamic> data = map["checklist_Question_Header"];

        setState(() {
          headerQuestion = data.map((e) => HeaderQuesStoreAM.fromJson(e)).toList();
          checklist_Header_Status = map['checklist_Header_Status'] ?? '';
          checklist_Current_Stats = map['checklist_Current_Stats'] ?? '';
          showsubmitBtn = checklist_Current_Stats == "Completed";
          loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        loading = false;
        // hasError = true;
      });
      _showRetryAlert();
    }
  }

  void _showRetryAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Failed to fetch data. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              getData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  void showAuditSummaryDialog(BuildContext context) async {
    AuditSummary? summary = await fetchAuditSummary();

    if (summary != null) {
      Get.defaultDialog(
        title: "Audit Summary",
        content: SizedBox(
          height: MediaQuery.of(context).size.height /
              1.7, // Set a fixed height to allow scrolling
          width: double.maxFinite, // Make sure it takes full width
          child: Scrollbar(
            thumbVisibility: true, // Always show the scrollbar

            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Start: ${summary.auditStartTime}"),
                        Text("End: ${summary.auditEndTime}"),
                      ],
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      // Ensures ListView takes only necessary space
                      physics: const NeverScrollableScrollPhysics(),
                      // Prevents ListView from scrolling separately
                      itemCount: summary.sections.length,
                      itemBuilder: (context, index) {
                        final section = summary.sections[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${section.sectionName} ",
                                    style: const TextStyle(
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    " Score: ${section.yourRatingScore}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                    Text(
                      "Your Score: ${summary.yourRatingScore}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      "Percentage: ${summary.percentage}%",
                      style: const TextStyle(
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        textConfirm: "Continue",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        cancelTextColor: Colors.white,
        confirm: InkWell(
          onTap: () {
            submitAllDilo();
            Get.back(); // Close dialog
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(16)),
            child:
            const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ),
        cancel: InkWell(
          onTap: () {
            Get.back(); // Close dialog
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(16)),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ),
        onConfirm: () {
          Get.back(); // Close dialog
        },
        onCancel: () {
          Get.back(); // Close dialog

        },
      );
    } else {
      Get.snackbar(
        "Error",
        "Failed to load audit summary.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<AuditSummary?> fetchAuditSummary() async {
    final response = await http.get(
      Uri.parse('https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/AreaManager/GetAreamanagerSummary/${widget.activeCheckList.amChecklistAssignId}'),
    );

    if (response.statusCode == 200) {
      return AuditSummary.fromJson(jsonDecode(response.body));
    } else {
      // Handle the error accordingly
      print('Failed to load audit summary');
      return null;
    }
  }
  Future<void> submitAllDilo() async {
    setState(() {
      loading = true;
    });

    try{
      final payload =
          '{"checklist_assign_id":${widget.activeCheckList.amChecklistAssignId}}';

      var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        '/RWASTAFFMOVEMENT_TEST/api/AreaManager/WorkFlowStatus',
      );

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            {"am_checklist_assign_id": widget.activeCheckList.amChecklistAssignId}),
      );

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
        }
        else {
          Navigator.pop(context);
          /* setState(() {
          loading = false;
        });*/
          // _showAlert(respo['message']);
          // Fluttertoast.showToast(msg: respo['message']);
        }      // Navigator.pop(context);
      } else {
        _showAlert('Something went wrong\nPlease contact IT support\nStatusCode:${response.statusCode}');
        Fluttertoast.showToast(msg: respo['message']);
      }
    }catch(e){
      setState(() {
        loading = false;
      });
      _showAlert('Something went wrong\nPlease contact IT support\n$e');

      print(e);
    }

  }

  Future<void> _showSuccessAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(msg),
          actions: <Widget>[
            InkWell(
              onTap: () {
                // Navigator.of(context,rootNavigator: true).pop();
                Navigator.pop(contextt);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 35, right: 35, top: 15, bottom: 15),
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: const Text('OK',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(msg),
          actions: <Widget>[
            InkWell(
              onTap: () {
                // Navigator.of(context,rootNavigator: true).pop();
                Navigator.pop(contextt);
                // Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 35, right: 35, top: 15, bottom: 15),
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: const Text('OK',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        );
      },
    );
  }
}
