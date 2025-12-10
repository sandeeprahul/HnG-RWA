import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hng_flutter/data/ActiveCheckListEmployee.dart';

import 'package:hng_flutter/submitCheckListScreenEmployee.dart';
import 'package:hng_flutter/widgets/header_question_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/constants.dart';
import 'data/GetActvityTypes.dart';
import 'data/GetChecklist.dart';
import 'data/HeaderQuestionEmployee.dart';
import 'check_list_segregation_screen.dart';

class checkListItemScreenEmployee extends StatefulWidget
    with WidgetsBindingObserver {
  // const checkListItemScreen({Key? key}) : super(key: key);
  final ActiveCheckListEmployee activeCheckList;
  final int type;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  checkListItemScreenEmployee(this.activeCheckList, this.mGetActvityTypes,
      this.locationsList, this.type);

  @override
  State<checkListItemScreenEmployee> createState() =>
      _checkListItemScreenEmployeeState(this.activeCheckList,
          this.mGetActvityTypes, this.locationsList, this.type);
}

class _checkListItemScreenEmployeeState
    extends State<checkListItemScreenEmployee> with WidgetsBindingObserver {
  ActiveCheckListEmployee activeCheckList;
  int type;
  GetActvityTypes mGetActvityTypes;
  String locationsList;

  _checkListItemScreenEmployeeState(this.activeCheckList, this.mGetActvityTypes,
      this.locationsList, this.type);

  // late final Future myFuture = getData();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addObserver(this);

    getData();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("resumedCheckListScreen");

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
        body: WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CheckListSegregationScreen(
                1,
                widget.mGetActvityTypes,
                widget.locationsList,
              ),
            ));

        return Future.value(false);
      },
      child: SafeArea(
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
                          'DILO  Employee',
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
                                          'Checklist No : ${widget.activeCheckList.empChecklistAssignId} ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
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
                  child: FutureBuilder<List<HeaderQuestionEmployee>?>(
                      future: getData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isNotEmpty) {
                            return ListView.builder(
                                itemCount: headerQuestion.length,
                                itemBuilder: (context, pos) {
                                  return InkWell(
                                    onTap: () {
                                      if (headerQuestion[pos]
                                              .checklistEditStatus == //checklistProgressStatus
                                          "E") {
                                        // ||headerQuestion[pos].checklistEditStatus =="P"
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  submitCheckListScreenEmployee(
                                                      widget.activeCheckList,
                                                      0,
                                                      widget.locationsList,
                                                      widget.mGetActvityTypes,
                                                      0,
                                                      '', empChecklistAssignId: "${headerQuestion[pos].empChecklistAssignId}", checklisTItemMstId: "${headerQuestion[pos].checklisTItemMstId}", checklistId: "${headerQuestion[pos].checklistId}",)), ////for non edit
                                        ).then((value) {
                                          getData();
                                        });
                                      }
                                    },
                                    child: listItem(pos),
                                  );
                                });
                          } else {
                            return Text('NO data');
                          }
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Center(
                            child: SizedBox(
                                height: MediaQuery.of(context).size.height / 7,
                                width: MediaQuery.of(context).size.height / 7,
                                child: const CircularProgressIndicator()),
                          );
                        }
                      }),
                ))
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: loading == true
                    ? false
                    : showsubmitBtn == true
                        ? true
                        : false,
                child: InkWell(
                  onTap: () {
                    //popup
                    submitAllDilo();
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
                // visible: true,
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
      ),
    ));
  }

  Widget listItem(int pos) {
    final headerQuestionDetails = headerQuestion[pos];
    //updated_Datetime//
    String endTime = headerQuestionDetails.endTime; //13-07-2023 16:58:59"
    String updatedTime = headerQuestionDetails.updatedDatetime;
    DateTime parseDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(updatedTime);

    DateTime endTimeFormat =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(headerQuestionDetails.endTime);
    var inputDate = DateTime.parse(endTimeFormat.toString());
    var subTUpdated = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('hh:mm a');
    var outputFormatSub = DateFormat('MMM dd yyyy hh:mm a');

    var outputDate = outputFormat.format(inputDate);
    var updatedByDatetime =
        outputFormatSub.format(subTUpdated); //updated_Datetime

    var status = headerQuestionDetails.checklistProgressStatus;
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
                    headerQuestion[pos].itemName,
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
                            '${headerQuestion[pos].updatedBy} ${headerQuestion[pos].updatedName}',
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
                child: headerQuestion[pos].checklistEditStatus != 'C'
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
        Visibility(
          visible: true,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 40, top: 10),
              child: CircleAvatar(
                radius: 4.5,
                backgroundColor: headerQuestion[pos].non_compliance_flag == "1"
                    ? Colors.red
                    : headerQuestion[pos].non_compliance_flag == "0"
                        ? Colors.green
                        : Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /*
  *     return HeaderQuestionWidget(status: status, itemName: headerQuestionDetails.itemName, submissionDate: outputDate, updatedBy: headerQuestionDetails.updatedBy, updatedName: headerQuestionDetails.updatedName, updatedByDatetime: headerQuestionDetails.updatedDatetime, checklistEditStatus: headerQuestionDetails.checklistEditStatus, non_compliance_flag: headerQuestionDetails.non_compliance_flag, outputDate: updatedByDatetime,);
*/

  List<HeaderQuestionEmployee> headerQuestion = [];

  String checklist_Header_Status = '';
  String checklist_Current_Stats = '';
  bool showsubmitBtn = false;

  Future<List<HeaderQuestionEmployee>?> getData() async {
    try {
      //replace your restFull API here.//api/CheckList/HeaderQuestion/46
      final prefs = await SharedPreferences.getInstance();

      var userID = prefs.getString('userCode') ?? '105060';

      String url =
          "${Constants.apiHttpsUrl}/Employee/HeaderQuestion/${widget.activeCheckList.empChecklistAssignId}/$userID";

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(milliseconds: 10000));

      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(response.body);

        headerQuestion = [];
        List<dynamic> data = map["checklist_Question_Header"];

        setState(() {
          checklist_Header_Status = map['checklist_Header_Status'];
          checklist_Current_Stats = map['checklist_Current_Stats'];
        });
        if (checklist_Header_Status == "E" &&
            checklist_Current_Stats == "Completed") {
          setState(() {
            showsubmitBtn = true;
          });
        } else {
          setState(() {
            showsubmitBtn = false;
          });
        }

        data.forEach((element) {
          headerQuestion.add(HeaderQuestionEmployee.fromJson(element));
        });

        // yield headerQuestion;
        return headerQuestion;
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showRetryAlert();
    }
    return null;
  }

  int i = -1;

  Future<void> _showRetryAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text('${Constants.networkIssue}'),
// Please retry?'),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white))),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // _showRetryAlert();
                    getData();
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

  Future<void> submitAllDilo() async {
    print("submitAllDilo");
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();

      var userId = prefs.getString("userCode");

      var url = Uri.parse(
          "https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Employee/WorkFlowStatusEmp");

      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      Map<String, dynamic> body = {
        'emp_checklist_assign_id': widget.activeCheckList.empChecklistAssignId,
        'employee_code': userId,
      };
      String jsonBody = jsonEncode(body);

      var response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
      );

      var respo = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (respo["statusCode"] == "201") {
          setState(() {
            loading = false;
          });
          _showSuccessAlert(respo["message"]);
        } else {
          setState(() {
            loading = false;
          });
          _showSuccessAlert(respo["message"]);
        }
      } else {
        setState(() {
          loading = false;
        });
        _showAlert(
            'Something went wrong\n${response.statusCode}\nPlease contact IT support');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e);
      _showAlert('Something went wrong\n$e\nPlease contact IT support');
    }
  }

  Future<void> _showSuccessAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text('$msg'),
          actions: <Widget>[
            InkWell(
              onTap: () {
                // Navigator.of(context,rootNavigator: true).pop();
                Navigator.pop(contextt);
                // Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckListSegregationScreen(
                        1,
                        widget.mGetActvityTypes,
                        widget.locationsList,
                      ),
                    ));
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
          content: Text('$msg'),
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
