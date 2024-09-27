import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/checkListScreen.dart';
import 'package:hng_flutter/submitCheckListScreen.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/constants.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/HeaderQuestion.dart';

class checkListItemScreen extends StatefulWidget with WidgetsBindingObserver {
  // const checkListItemScreen({Key? key}) : super(key: key);
  final ActiveCheckList activeCheckList;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  checkListItemScreen(
      this.activeCheckList, this.mGetActvityTypes, this.locationsList);

  @override
  State<checkListItemScreen> createState() => _checkListItemScreenState(
      this.activeCheckList, this.mGetActvityTypes, this.locationsList);
}

class _checkListItemScreenState extends State<checkListItemScreen>
    with WidgetsBindingObserver {
  ActiveCheckList activeCheckList;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  _checkListItemScreenState(
      this.activeCheckList, this.mGetActvityTypes, this.locationsList);

  // late final Future myFuture = getData();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addObserver(this);

    getData();
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
                        // Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => checkListScreen(
                                  1,
                                  widget.mGetActvityTypes,
                                  widget.locationsList)),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'DILO',
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
                                        'Checklist No : ${widget.activeCheckList.checklistAssignId} ',
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
                child: headerQuestion.isEmpty
                    ? const Text("No data")
                    : ListView.builder(
                        itemCount: headerQuestion.length,
                        itemBuilder: (context, pos) {
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
                              if (headerQuestion[pos]
                                          .checklistEditStatus == //checklistProgressStatus
                                      "E" ||
                                  headerQuestion[pos].checklistEditStatus ==
                                      "P") {
                                // ||headerQuestion[pos].checklistEditStatus =="P"
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          submitCheckListScreen(
                                              headerQuestion[pos],
                                              widget.activeCheckList,
                                              0,
                                              widget.mGetActvityTypes,
                                              widget.locationsList)),
                                ).then((value) {
                                  getData();
                                });
                              }
                              /*  Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => submitCheckListScreen(
                                    headerQuestion[pos],
                                    widget.activeCheckList,
                                    0)),
                          ).then((value) {
                            getData();
                          });*/
                            },
                            child: listItem(pos, enddTime),
                          );
                        }),
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

  Widget listItem(int pos, String enddTime) {
    String startTime = headerQuestion[pos].startTime;
    DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(startTime);
    DateTime submitTimeDate = DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(headerQuestion[pos].updatedByDatetime);
    var inputDate = DateTime.parse(parseDate.toString());
    var subT = DateTime.parse(submitTimeDate.toString());
    var outputFormat = DateFormat('hh:mm a');
    var outputFormatSub = DateFormat('MMM dd yyyy hh:mm a');

    var outputDate = outputFormat.format(inputDate);
    var updatedByDatetime = outputFormatSub.format(subT);

    var status = headerQuestion[pos].checklistProgressStatus;
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
                        Text(enddTime,
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
                    : headerQuestion[pos].non_compliance_flag == ""
                        ? Colors.transparent
                        : Colors.green,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<HeaderQuestion> headerQuestion = [];

  String checklist_Header_Status = '';
  String checklist_Current_Stats = '';
  bool showsubmitBtn = false;

  Future<void> getData() async {
    try {
      setState(() {
        loading = true;
      });
      //replace your restFull API here.//api/CheckList/HeaderQuestion/46
      final prefs = await SharedPreferences.getInstance();

      var userID = prefs.getString('userCode') ?? '105060';

      String url =
          "${Constants.apiHttpsUrl}/CheckList/HeaderQuestion/${widget.activeCheckList.checklistAssignId}/$userID";

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(milliseconds: 3000));

      var responseData = json.decode(response.body);
      print(url);
      print(responseData);

      //Creating a list to store input data;
      Map<String, dynamic> map = json.decode(response.body);

/*    HeaderQuestion headerQuestionFromJson(String str) => HeaderQuestion.fromJson(json.decode(str));

    String headerQuestionToJson(HeaderQuestion data) => json.encode(data.toJson());
    final headerQuestion_ = headerQuestionFromJson(response.body);*/

      headerQuestion = [];
      List<dynamic> data = map["checklist_Question_Header"];
      print("checklist_Current_Statssssssss");

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
      print(checklist_Header_Status);
      /*List<HeaderQuestion> users = data.cast<HeaderQuestion>();
    headerQuestion = users;*/
      data.forEach((element) {
        headerQuestion.add(HeaderQuestion.fromJson(element));
      });

      /*   List<HeaderQuestion> toResponseList( data) {
      List<HeaderQuestion> value = <HeaderQuestion>[];
      data.forEach((element) {
        headerQuestion.add(HeaderQuestion.fromJson(element));
      });
      return value ?? List<HeaderQuestion>.empty();
    }
    toResponseList(data);*/

      // List<CustomModel> list = dynamicList.cast<CustomModel>();

      print(data.length);

      /*setState(() {
      headerQuestion = data;

    });*/
      // Iterable l = json.decode(response.body);
      /* headerQuestion = List<HeaderQuestion>.from(
        l.map((model) => HeaderQuestion.fromJson(model)));*/
      // return headerQuestion;
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
          content: const Text('Network issue\nPlease retry'),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
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
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
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
    try {
      setState(() {
        loading = true;
      });

      final payload =
          '{"checklist_assign_id":${widget.activeCheckList.checklistAssignId}}';

       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWASTAFFMOVEMENT_TEST/api/CheckList/WorkFlowStatus',
      );

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "checklist_assign_id": widget.activeCheckList.checklistAssignId
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        _showSuccessAlert('Checklist Successfully Submitted for Review');
        // Navigator.pop(context);
      } else {
        _showAlert(
            'Status code:${response.statusCode}\nSomething went wrong\nPlease contact IT suport');
      }
    } catch (e) {
      _showAlert(Constants.networkIssue);
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
                      builder: (context) => checkListScreen(
                          1, widget.mGetActvityTypes, widget.locationsList)),
                );
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
          title: const Text('Alert'),
          content: Text(msg),
          actions: <Widget>[
            CustomElevatedButton(
                text: 'Cancel',
                onPressed: () {
                  Navigator.pop(contextt);
                }),
            CustomElevatedButton(
                text: 'Retry',
                onPressed: () {
                  submitAllDilo();
                  Navigator.pop(contextt);
                }),
          ],
        );
      },
    );
  }
}
