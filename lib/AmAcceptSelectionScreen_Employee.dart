import 'dart:convert';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hng_flutter/data/ActiveCheckListLpd.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/data/HeaderQuesLpd.dart';
import 'package:hng_flutter/data/HeaderQuestionEmployee.dart';
import 'package:hng_flutter/submitCheckListScreenEmployee.dart';
import 'package:hng_flutter/submitCheckListScreen_Lpd.dart';
import 'package:hng_flutter/submitCheckListScreen_StoreAudit.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hng_flutter/AmOutletSelectScreen.dart';
import 'package:hng_flutter/data/AmHeaderQuestion.dart';
import 'package:hng_flutter/data/HeaderQuestion.dart';
import 'package:hng_flutter/checkListScreen.dart';
import 'package:hng_flutter/submitCheckListScreen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/constants.dart';
import 'data/ActiveCheckListEmployee.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/AmHeaderQuestionEmployee.dart';
import 'data/AmHeaderQuestionStoreAudit.dart';
import 'data/GetChecklist.dart';
import 'data/LPDSection.dart';
import 'checkListScreen_lpd.dart';

class AmAcceptSelectionScreen_Employee extends StatefulWidget {
  // const AmAcceptSelectionScreen({Key? key}) : super(key: key);
  // int id;
  final ActiveCheckListEmployee activeCheckList;
  final int type;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;
  final GetChecklist checkList;

  // final HeaderQuestionEmployee headerQuestionEmployee;

  AmAcceptSelectionScreen_Employee(
    this.activeCheckList,
    this.mGetActvityTypes,
    this.locationsList,
    this.checkList,
    this.type,
  );

  @override
  State<AmAcceptSelectionScreen_Employee> createState() =>
      _AmAcceptSelectionScreen_EmployeeState(this.activeCheckList,
          this.mGetActvityTypes, this.locationsList, this.checkList, this.type);
}

class _AmAcceptSelectionScreen_EmployeeState
    extends State<AmAcceptSelectionScreen_Employee> {
  final ActiveCheckListEmployee activeCheckList;
  final int type;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;
  final GetChecklist checkList;

  // final HeaderQuestionEmployee headerQuestionEmployee;

  _AmAcceptSelectionScreen_EmployeeState(
    this.activeCheckList,
    this.mGetActvityTypes,
    this.locationsList,
    this.checkList,
    this.type,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // myFuture  = getData();
    print("AmAcceptSelectionScreen_StoreAudit");
    getData();
    getDataCheckList();
    nonCompFlag_O.clear();

    clearData();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getData();
      getDataCheckList();
      //do your stuff
    }
  }

  bool showSelectAll = false;
  bool showcheckBox = false;
  int? selectedIndex;
  bool showPopUp = false;
  bool showCheckListDetails = false;
  List<HeaderQuestion> selectedHeaderQues = [];
  final _listKey = GlobalKey();
  bool showImage = false;

  bool selectAll = false;
  bool selectedAll = false;

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/json.txt'; // 3
    return filePath;
  }

  void saveFile(String json) async {
    File file = File(await getFilePath()); // 1
    file.writeAsString(json); // 2
  }

  int index_ = -1;

  @override
  void dispose() {
    // TODO: implement dispose
    // users.clear();
    nonCompFlag_O.clear();
    headerQuestionSelected.clear();
    // headerQuestion.clear();
    headerQuestionSelected_.clear();
    mAmHeaderQuestion_notSelected.clear();
    mAmHeaderQuestion.clear();
    overallScore = [];
    nonCompFlag = [];

    // clearData();
    super.dispose();
  }

  clearData() {
    mAmHeaderQuestion = [];
    mAmHeaderQuestion_notSelected = [];
    headerQuestionSelected = [];
    headerQuestionSelected_ = [];
    overallScore = [];
    nonCompFlag = [];
    nonCompFlag_O = [];
    setState(() {
      pendingCount = 0;
      CompltedCount = 0;
      complanceFlgLength = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    String date = widget.activeCheckList.publishDate;
    DateTime parseDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('MMM dd yyyy');
    var outputDate = outputFormat.format(inputDate); //publish_date

    //starttime
    String startTime = widget.activeCheckList.startTime;
    DateTime start_time_ = DateFormat("dd-MM-yyyy HH:mm:ss").parse(startTime);
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
        backgroundColor: Colors.grey[50],
        body: WillPopScope(
          onWillPop: () {
            if (showCheckListDetails == true) {
              setState(() {
                showCheckListDetails = false;
              });
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => checkListScreen_lpd(
                        1,
                        widget.mGetActvityTypes,
                        widget.locationsList,
                        widget.checkList),
                  ));
            }

            return Future.value(false);
          },
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, top: 15),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => checkListScreen_lpd(
                                        1,
                                        widget.mGetActvityTypes,
                                        widget.locationsList,
                                        widget.checkList),
                                  ));
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Icon(Icons.arrow_back),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'Dilo Employee',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 10),
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        '${widget.activeCheckList.checklistName} for $outputDate',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Outlet name : ${widget.activeCheckList.locationName} ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            'Time : $outputTime - $enddTime',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Text(
                                            '${widget.activeCheckList.empChecklistAssignId}',
                                            style: const TextStyle(
                                              fontSize: 12,
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
                    const Divider(),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 10, bottom: 10),
                          child: Row(
                            children: [
                              const Text(
                                'Overall Score : ',
                                style: TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              //  String checklist_Question_header_Total_Count = '';

                              Text(
                                '$checklist_Question_header_Total_Count/$checklist_Question_header_Completed_Count',
                                style: const TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        /* Container(
                          margin: EdgeInsets.only(top: 15, bottom: 15),
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 10, bottom: 10),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.deepOrange,
                                size: 15,
                              ),
                              Expanded(
                                child: Text(
                                  'Your are about to reject the checklist.This action cannot be undone',
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),*/
                        Visibility(
                          visible:
                              widget.activeCheckList.checklistEditStatus == "R"
                                  ? false
                                  : true,
                          child: InkWell(
                            onTap: () {
                              if (showSelectAll == false) {
                                setState(() {
                                  showSelectAll = true;
                                  // signleSelection = false;
                                });
                              } else {
                                setState(() {
                                  showSelectAll = false;
                                  // signleSelection = false;
                                });
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(
                                  left: 15, right: 10, bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    'Select items to approve',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Select Items',
                                    style: TextStyle(
                                        color: Colors.lightBlueAccent,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: showSelectAll,
                          // visible: showSelectAll,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    headerQuestionSelected_.clear();
                                    mAmHeaderQuestion_notSelected.clear();
                                    if (showcheckBox) {
                                      setState(() {
                                        showcheckBox = false;
                                        // headerQuestionSelected = [];
                                        headerQuestionSelected_ = [];
                                        // headerQuestionSelected.clear;
                                        headerQuestionSelected_.clear();
                                        /*  for(var i=0;i<users.length;i++){

                                        }*/
                                        for (int i = 0;
                                            i < mAmHeaderQuestion.length;
                                            i++) {
                                          setState(() {
                                            // selectedHeaderQues = headerQuestion;
                                            // headerQuestionSelected_.remove(i);
                                            mAmHeaderQuestion_notSelected
                                                .add(i);
                                          });
                                        }
                                        // selectedCheckList.addAll(users.);

                                        /*for (var i = 0; i < users.length; i++) {
                                          users[i].isSlected = true;
                                        }*/
                                        // selectedCheckList.addAll(pos);
                                      });
                                    } else {
                                      setState(() {
                                        showcheckBox = true;

                                        /* for (int i = 0; i < users.length; i++) {
                                          setState(() {
                                          });
                                        }*/
                                        mAmHeaderQuestion_notSelected = [];
                                        mAmHeaderQuestion_notSelected.clear();

                                        for (int i = 0;
                                            i < mAmHeaderQuestion.length;
                                            i++) {
                                          setState(() {
                                            // selectedHeaderQues = headerQuestion;
                                            headerQuestionSelected_.add(i);
                                            // mAmHeaderQuestion_notSelected
                                            //     .remove(i);
                                          });
                                        }

                                        /* for (var i = 0; i < users.length; i++) {
                                          users[i].isSlected = false;
                                        }*/
                                        // showcheckBox = false;

                                        // selectedCheckList.addAll(users);
                                      });
                                    }

                                    if (!showcheckBox) {
                                      for (int i = 0;
                                          i < mAmHeaderQuestion.length;
                                          i++) {
                                        setState(() {
                                          // selectedHeaderQues = headerQuestion;
                                          mAmHeaderQuestion_notSelected.add(i);
                                          headerQuestionSelected_.remove(i);
                                        });
                                      }
                                    }
                                    setState(() {
                                      selectedAll = showcheckBox;
                                    });

                                    print("selectAll");
                                    print(showcheckBox);
                                  },
                                  icon: Icon(showcheckBox
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank),
                                  color: Colors.blue,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  'Select all',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                const Spacer(),
                                const Text(
                                  'Done',
                                  style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      // padding: const EdgeInsets.only(bottom: 50),
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      color: Colors.white,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, bottom: 15, top: 10),
                            child: Text(
                              mAmHeaderQuestion.isEmpty ? "" : "",
                              // : mAmHeaderQuestion[0].itemName,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10, bottom: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${overallScore.length} Completed",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${pendingCount} Pending',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrangeAccent),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "${nonCompFlag.length} Non-Comp",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        color: Colors.white,
                        child: mAmHeaderQuestion
                                .isEmpty /*||
                                headerQuestion.isEmpty*/
                            ? const Center(
                                child: Text(
                                'Please wait',
                                textAlign: TextAlign.center,
                              ))
                            : ListView.separated(
                                scrollDirection: Axis.vertical,
                                // shrinkWrap: true,
                                key: _listKey,
                                itemCount: mAmHeaderQuestion.length,
                                itemBuilder: (context, pos) {
                                  DateTime parseDate =
                                      DateFormat("dd-MM-yyyy hh:mm:ss").parse(
                                          mAmHeaderQuestion[pos]
                                              .updatedByDatetime
                                              .toString());
                                  var inputDate =
                                      DateTime.parse(parseDate.toString());
                                  var outputFormat_ =
                                      DateFormat('hh:mm a'); // hh:mm a

                                  var outputFormat = DateFormat(
                                      'dd MMM yyyy hh:mm a'); // hh:mm a
                                  var time_ = outputFormat_.format(inputDate);
                                  var date_ = outputFormat.format(inputDate);

                                  // var time_ = 'timw';
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        index_ = pos;

                                        showCheckListDetails = true;
                                        selectedAmHeaderQuestion =
                                            mAmHeaderQuestion[pos];
                                      });

                                      setData(pos);
                                    },
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            Visibility(
                                              visible: showSelectAll,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: IconButton(
                                                    onPressed: () {
                                                      // if (showcheckBox) {
                                                      //
                                                      // } else {
                                                      if (headerQuestionSelected_
                                                          .contains(pos)) {
                                                        setState(() {
                                                          headerQuestionSelected_
                                                              .remove(pos);
                                                          mAmHeaderQuestion_notSelected
                                                              .add(pos);
                                                        });
                                                      } else {
                                                        setState(() {
                                                          /* selectedCheckList
                                                                        .add(pos);*/
                                                          headerQuestionSelected_
                                                              .add(pos);
                                                          mAmHeaderQuestion_notSelected
                                                              .remove(pos);
                                                        });
                                                      }
                                                      setState(() {
                                                        selectAll = false;
                                                        // showSelectAll = false;
                                                        showcheckBox = false;
                                                        selectedAll = false;
                                                      });

                                                      /*  setState(() {

                                                    });*/
                                                    },
                                                    icon: Icon(
                                                      headerQuestionSelected_
                                                              .isEmpty
                                                          ? Icons
                                                              .check_box_outline_blank
                                                          : headerQuestionSelected_
                                                                  .contains(pos)
                                                              ? Icons.check_box
                                                              : Icons
                                                                  .check_box_outline_blank,
                                                      color: Colors.blue,
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                // color: Colors.white,
                                                margin: const EdgeInsets.only(
                                                    bottom: 10,
                                                    left: 15,
                                                    right: 15),
                                                padding: const EdgeInsets.only(
                                                  top: 10,
                                                  left: 10,
                                                  right: 10,
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Visibility(
                                                          visible: false,
                                                          child: Text(
                                                            mAmHeaderQuestion[
                                                                    pos]
                                                                .itemName,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .grey[600]),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const CircleAvatar(
                                                              radius: 5,
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                  maxLines: 1,
                                                                  mAmHeaderQuestion[
                                                                          pos]
                                                                      .itemName,
                                                                  // '${mAmHeaderQuestion[pos].updatedBy} - ${mAmHeaderQuestion[pos].employeeName}',
                                                                  // $time_
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                            maxLines: 1,
                                                            // mAmHeaderQuestion[pos].itemName,
                                                            '${mAmHeaderQuestion[pos].updatedBy} - ${mAmHeaderQuestion[pos].employeeName}',
                                                            // $time_
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                                mAmHeaderQuestion[
                                                                        pos]
                                                                    .checklistProgressStatus,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .green)),
                                                            Text(' $date_',
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12)),
                                                            // const Spacer(),
                                                            const Expanded(
                                                              child: Text(
                                                                'View Details',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ),
                                                            /*   Text(
                                                                mAmHeaderQuestion[pos]
                                                                            .nonComplianceFlag ==
                                                                        "1"
                                                                    ? 'Non-Complaint'
                                                                    : '',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: mAmHeaderQuestion[pos]
                                                                                .nonComplianceFlag ==
                                                                            "1"
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .transparent)),*/
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                          visible: checklist_Header_Status ==
                                                  "E" ||
                                              checklist_Header_Status == "R" ||
                                              checklist_Header_Status == "A",
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 35, top: 5),
                                              child: CircleAvatar(
                                                radius: 4.5,
                                                backgroundColor: mAmHeaderQuestion[
                                                                pos]
                                                            .nonComplianceFlag ==
                                                        "1"
                                                    ? Colors.red
                                                    : mAmHeaderQuestion[pos]
                                                                .nonComplianceFlag ==
                                                            "0"
                                                        ? Colors.green
                                                        : Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const Divider();
                                },
                              ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
                Visibility(
                  visible: checklist_Header_Status == "A"
                      ? showSelectAll == true
                          ? true
                          : false
                      : true,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        // sendData();
                        setState(() {
                          showPopUp = true;
                        });
                      },
                      child: Container(
                          width: double.infinity,
                          height: 45,
                          color: Colors.green,
                          child: Center(
                            child: Text(
                              checklist_Header_Status == "R"
                                  ? "Review"
                                  : 'Accept selected',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          )),
                    ),
                  ),
                ),
                Visibility(
                    visible: showProgress,
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
                Visibility(
                  visible: showCheckListDetails,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showCheckListDetails = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      height: double.infinity,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                /*  height:
                                    MediaQuery.of(context).size.height / 1.3,*/
                                width: double.infinity,
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15, bottom: 5),
                                        child: Text(
                                          checkListName.isEmpty
                                              ? 'No Data'
                                              : mAmHeaderQuestion.isNotEmpty
                                                  ? checkListName
                                                  : 'No data',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.white,
                                      margin: const EdgeInsets.only(
                                          bottom: 10,
                                          // left: 15,
                                          right: 15),
                                      padding: const EdgeInsets.only(
                                        top: 15,
                                        // left: 10,
                                        right: 10,
                                      ),
                                      child: Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  /*   const CircleAvatar(
                                                    radius: 10,
                                                  ),*/
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                      mAmHeaderQuestion
                                                              .isNotEmpty
                                                          ? updatedBy_
                                                          : '',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                      mAmHeaderQuestion
                                                              .isNotEmpty
                                                          ? checklistProgressStatus
                                                          : '',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.green)),
                                                  Text(
                                                      mAmHeaderQuestion
                                                              .isNotEmpty
                                                          ? ' $updatedByDatetime'
                                                          : '',
                                                      style: const TextStyle(
                                                          fontSize: 12)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                        visible: chooseTheAns,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Divider(),
                                              Text(mAmHeaderQuestion.isNotEmpty
                                                      ? checkListName
                                                      : ''
                                                  /*mAmHeaderQuestion.length != 0
                                                  ? mAmHeaderQuestion[0].itemName
                                                  : ''*/
                                                  ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                mAmHeaderQuestion.isNotEmpty
                                                    ? chooseTheAns_answer
                                                    : '',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              const Divider(),
                                            ],
                                          ),
                                        )),

                                    Visibility(
                                        visible: attachProof, //answer_type_id
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                               Text(
                                                 attachProofTitle,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ), //fontWeight: FontWeight.bold
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    showImage = true;
                                                  });
                                                },
                                                child: SizedBox(
                                                  height: 75,
                                                  width: 75,
                                                  child: Image.network(
                                                      attachProofImg.isNotEmpty
                                                          ? attachProofImg
                                                          : ''),
                                                  /* CachedNetworkImage(
                                                    imageUrl: attachProofImg.isNotEmpty
                                                        ? attachProofImg
                                                        : "http://via.placeholder.com/350x150",
                                                    placeholder: (context, url) => new CircularProgressIndicator(),
                                                    errorWidget: (context, url, error) => new Icon(Icons.error),
                                                  ),*/
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    const Divider(),

                                    Visibility(
                                        visible: answer_TypeId,
                                        //answer_type_id
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Comment',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                answer_TypeId_answer,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        )),
                                    Visibility(
                                      visible: index_ == -1
                                          ? false
                                          : checklist_Header_Status == "E" ||
                                                  checklist_Header_Status == "R"
                                              ? true
                                              : false,
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              showCheckListDetails = false;
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      submitCheckListScreenEmployee(
                                                          headerQuestion[0],
                                                          widget
                                                              .activeCheckList,
                                                          1,
                                                          //for edit
                                                          widget.locationsList,
                                                          widget
                                                              .mGetActvityTypes,
                                                          widget.checkList,
                                                          sendingToEditAmHeaderQuestion
                                                              .updatedBy,
                                                          "${selectedAmHeaderQuestion!.checklisTItemMstId}")),
                                            ).then((value) {
                                              getData();
                                              getDataCheckList();
                                            });
                                          },
                                          child: Container(
                                            // width: 70,
                                            padding: const EdgeInsets.all(10),
                                            margin: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.red,
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 3),
                                                  child: Icon(
                                                    Icons
                                                        .arrow_forward_ios_outlined,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //alert
                // showPopUp

                Visibility(
                  visible: showPopUp,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showPopUp = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      height: double.infinity,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(15),
                            padding: const EdgeInsets.all(15),
                            color: Colors.white,
                            child: Column(
                              children: [
                                const Text(
                                  'Are you sure you want to approve this:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                            color:
                                                Colors.green.withOpacity(0.5),
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            padding: const EdgeInsets.all(5),
                                            width: 45,
                                            child: Center(
                                              child: Text(
                                                widget.activeCheckList
                                                            .checklistEditStatus ==
                                                        "A"
                                                    ? '${headerQuestionSelected_.length}'
                                                    : '${mAmHeaderQuestion.length}',
                                                //widget.activeCheckList.checklistEditStatus=="A"?  :
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.green),
                                              ),
                                            )),
                                        const Text(
                                          'Accepted',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            color: Colors.red.withOpacity(0.5),
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            width: 45,
                                            padding: const EdgeInsets.all(5),
                                            child: Center(
                                                child: Text(
                                              widget.activeCheckList
                                                          .checklistEditStatus ==
                                                      "A"
                                                  ? '${mAmHeaderQuestion_notSelected.length}'
                                                  : '0',
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.red),
                                            ))),
                                        const Text(
                                          'Rejected',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${nonCompFlag_O.length}',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.green),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text(
                                          'Non Compliance',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${nonCompFlag.length}',
                                          style: const TextStyle(
                                              fontSize: 20, color: Colors.red),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text(
                                          'Compliance',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${overallScore.length}',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.green),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text(
                                          'Completed',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$pendingCount',
                                          style: const TextStyle(
                                              fontSize: 20, color: Colors.red),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text(
                                          'Pending',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        // Navigator.of(context).pop();
                                        setState(() {
                                          showPopUp = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 35,
                                            right: 35,
                                            top: 15,
                                            bottom: 15),
                                        margin: const EdgeInsets.only(
                                            left: 15, bottom: 10),
                                        decoration: const BoxDecoration(
                                            color: CupertinoColors.systemGrey3,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        child: const Text('No,Cancel',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14)),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // Navigator.of(context).pop();
                                        if (checklist_Header_Status == "A") {
                                          //A
                                          sendData__();
                                        } else {
                                          sendData();
                                        }
                                        setState(() {
                                          showPopUp = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 35,
                                            right: 35,
                                            top: 15,
                                            bottom: 15),
                                        margin: const EdgeInsets.only(
                                            right: 15, bottom: 10),
                                        decoration: const BoxDecoration(
                                            color: CupertinoColors.activeBlue,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        child: const Text(
                                          'Yes,approve',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //
                Visibility(
                    visible: showImage,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        children: [
                          // Icon(Icons.close,color: Colors.red,),
                          Image.network(
                              attachProofImg.isNotEmpty ? attachProofImg : ''),
                          Container(
                            color: Colors.white,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showImage = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                )),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ));
  }

  late List<Checklist> users;
  var ratingValue = 0.0;
  var rating_;

  var ratingValue_2 = 0.0;
  var rating_2;

  // late final Future myFuture = getData();

  // List<HeaderQuestion> headerQuestion = [];
  List<AmHeaderQuestionEmployee> mAmHeaderQuestion = [];
  AmHeaderQuestionEmployee? selectedAmHeaderQuestion;
  late AmHeaderQuestionEmployee sendingToEditAmHeaderQuestion;
  List mAmHeaderQuestion_notSelected = [];
  List<HeaderQuestionEmployee> headerQuestionSelected = [];
  List headerQuestionSelected_ = [];
  List overallScore = [];
  var nonCompFlag = [];
  var nonCompFlag_O = [];

  int pendingCount = 0;
  int CompltedCount = 0;
  int complanceFlgLength = 0;

  bool attachProof = false, answer_TypeId = false, chooseTheAns = false;
  var attachProofImg = '',
      answer_TypeId_answer = '',
      chooseTheAns_answer = '',
      updatedByDatetime = '',
      checkListName = '',
      updatedBy_ = '',
      checklistProgressStatus = '';

  Future<void> getData() async {
    try {
      setState(() {
        loading = true;
        overallScore = [];
        nonCompFlag = [];
        pendingCount = 0;
        CompltedCount = 0;
        complanceFlgLength = 0;

        attachProof = false;
        answer_TypeId = false;
        chooseTheAns = false;
        attachProofImg = '';
        answer_TypeId_answer = '';
        chooseTheAns_answer = '';
        updatedByDatetime = '';
        checkListName = '';
        updatedBy_ = '';
        checklistProgressStatus = '';
      });

      //replace your restFull API here.
      var type = '';
      if (widget.activeCheckList.checklistEditStatus == "R") {
        setState(() {
          type = 'GetQuestionRM';
        });
        // GetApproveRejectByRM
      } else {
        setState(() {
          type = 'GetQuestionAM';
        });
      }
      String url =
          "${Constants.apiHttpsUrl}/Employee/$type/${widget.activeCheckList.empChecklistAssignId}";
      /* +
            widget.id.toString();*/
      final response = await http.get(Uri.parse(url));

      print('URL->$url');
      var responseData = json.decode(response.body);
      print('responseData->$responseData');

      // final amHeaderQuestionStoreAudit = amHeaderQuestionStoreAuditFromJson(jsonString);

      // Map<String, dynamic> map = json.decode(response.body);

      // headerQuestion = [];
      mAmHeaderQuestion = [];
      print(mAmHeaderQuestion.length);
      Iterable l = json.decode(response.body);
      mAmHeaderQuestion = List<AmHeaderQuestionEmployee>.from(
          l.map((model) => AmHeaderQuestionEmployee.fromJson(model)));

      // overallScore = [];
      // nonCompFlag = [];

      for (int i = 0; i < mAmHeaderQuestion.length; i++) {
        setState(() {
          mAmHeaderQuestion_notSelected.add(i);
        });
        if (mAmHeaderQuestion[i].checklistProgressStatus == "Completed") {
          overallScore.add(i);
          setState(() {
            pendingCount = mAmHeaderQuestion.length - overallScore.length;
          });
        }

        if (mAmHeaderQuestion[i].nonComplianceFlag == "1") {
          nonCompFlag.add(i); //red
          setState(() {
            complanceFlgLength = mAmHeaderQuestion.length - nonCompFlag.length;
          });
        }
        if (mAmHeaderQuestion[i].nonComplianceFlag == "0") {
          nonCompFlag_O.add(i);
        }
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  List<HeaderQuestionEmployee> headerQuestion = [];
  String checklist_Header_Status = '';
  String checklist_Question_header_Total_Count = '';
  String checklist_Question_header_Completed_Count = '';

  Future<void> getDataCheckList() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();

      var userID = prefs.getString('userCode') ?? '105060';
      String url =
          "${Constants.apiHttpsUrl}/Employee/HeaderQuestion/${widget.activeCheckList.empChecklistAssignId}/$userID";

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));

      var responseData = json.decode(response.body);
      print(url);
      print(responseData);

      Map<String, dynamic> map = json.decode(response.body);

      headerQuestion = [];
      List<dynamic> data = map["checklist_Question_Header"];

      setState(() {
        checklist_Header_Status = map['checklist_Header_Status'];
        checklist_Question_header_Total_Count =
            map['checklist_Question_header_Total_Count'];
        checklist_Question_header_Completed_Count =
            map['checklist_Question_header_Completed_Count'];
      });

      data.forEach((element) {
        headerQuestion.add(HeaderQuestionEmployee.fromJson(element));
      });

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  bool loading = false;
 String  attachProofTitle='';
  setData(int pos) async {
    attachProofImg = '';
    answer_TypeId_answer = '';
    chooseTheAns_answer = '';
    attachProof = false;
    answer_TypeId = false;
    chooseTheAns = false;

    updatedByDatetime = '';
    checkListName = '';
    updatedBy_ = '';
    checklistProgressStatus = '';

    int i = pos;
    if (mAmHeaderQuestion.isNotEmpty) {
      sendingToEditAmHeaderQuestion = mAmHeaderQuestion[i];

      // for (int i = 0; i < mAmHeaderQuestion.length; i++) {
      for (int j = 0; j < mAmHeaderQuestion[i].checkListDetails.length; j++) {
        checkListName = mAmHeaderQuestion[i].itemName;
        updatedByDatetime = mAmHeaderQuestion[i].updatedByDatetime;
        checklistProgressStatus = mAmHeaderQuestion[i].checklistProgressStatus;
        checkListName = mAmHeaderQuestion[i].itemName;
        updatedBy_ = mAmHeaderQuestion[i].updatedBy.toString();

        if (mAmHeaderQuestion[i].checkListDetails[j].answerTypeId == 1) {
          print("answerTypeId = 1");
          setState(() {
            answer_TypeId = true;
            answer_TypeId_answer =
                mAmHeaderQuestion[i].checkListDetails[j].answerOption;
          });
        }

        if (mAmHeaderQuestion[i].checkListDetails[j].answerTypeId == 4) {
          setState(() {
            chooseTheAns = true;
            chooseTheAns_answer =
                mAmHeaderQuestion[i].checkListDetails[j].answerOption;
          });
        }
        if (mAmHeaderQuestion[i].checkListDetails[j].imageName != "" &&
            mAmHeaderQuestion[i].checkListDetails[j].imageName != null) {
          final prefs = await SharedPreferences.getInstance();

          var locationCode = widget.activeCheckList.locationCode;

          setState(() {

            attachProofTitle = mAmHeaderQuestion[i].checkListDetails[j].question;

          });
          try {
            final storageRef = FirebaseStorage.instanceFor(
                    bucket: "gs://hng-offline-marketing.appspot.com")
                .ref();
            //gs://loghng-942e6.appspot.com
            //gs://hng-offline-marketing.appspot.com //original

            final imageUrl = await storageRef
                .child(
                    "$locationCode/QuesAns/${mAmHeaderQuestion[i].checkListDetails[j].imageName}")
                .getDownloadURL();
            setState(() {
              attachProof = true;
              attachProofImg = imageUrl;
            });
          } catch (e) {}
        }

        if (mAmHeaderQuestion[i].checkListDetails[j].answerTypeId == 5) {
          setState(() {
            // ratingValue = true;
            ratingValue = double.parse(
                mAmHeaderQuestion[i].checkListDetails[j].answerOption);
          });
        }
        //  rating_2
        if (mAmHeaderQuestion[i].checkListDetails[j].question ==
            "Department Rating") {
          setState(() {
            // ratingValue = true;
            ratingValue_2 = double.parse(
                mAmHeaderQuestion[i].checkListDetails[j].answerOption);
          });
        }
      }
      // }
    }
  }

  bool showProgress = false;
  int tried = 0;

  Future<void> sendData__() async {
    setState(() {
      showProgress = true;
    });
    String datetime_ = DateFormat("yyyy-MM-dd hh:mm").format(DateTime.now());
    // print('DATATIME ' + datetime_);
    try {
      final prefs = await SharedPreferences.getInstance();

      var userId = prefs.getString('userCode');
      // String url = staticUrlString + "Login/validateLogin";
       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWASTAFFMOVEMENT_TEST/api/Employee/QuestionUpdate',
      );

      var params = [];

      if (selectedAll) {
        for (int i = 0; i < mAmHeaderQuestion.length; i++) {
          params.add({
            "emp_checklist_assign_id": mAmHeaderQuestion.isEmpty
                ? 0
                : mAmHeaderQuestion[i].empChecklistAssignId,
            "checklist_id": widget.activeCheckList.checklisTId,
            "checklist_item_mst_id": mAmHeaderQuestion.isEmpty
                ? 0
                : mAmHeaderQuestion[i].checklisTItemMstId,
            "checklist_Answer_Id": /* mAmHeaderQuestion[i].checkListDetails.isEmpty
                ? 0
                : */
                mAmHeaderQuestion[i].checkListDetails[0].checklisTAnswerId,
            "checklist_answer_option_id":
                mAmHeaderQuestion[i].checkListDetails.isEmpty
                    ? 0
                    : mAmHeaderQuestion[i]
                        .checkListDetails[0]
                        .checklisTAnswerOptionId,
            "approved_by": userId,
            "approved_by_datetime": datetime_,
            "reviewed_by": 0,
            "reviewed_by_datetime": datetime_,
            "approved_by_remarks": "Approved by $userId",
            "rejected_by": 0,
            "rejected_by_remarks": "",
            "rejected_by_datetime": "",
            "reviewed_by_remarks": "",
          });
        }
      } else if (!selectedAll &&
          headerQuestionSelected_.isEmpty &&
          mAmHeaderQuestion_notSelected.isNotEmpty) {
        for (int i = 0; i < mAmHeaderQuestion.length; i++) {
          // print('mAmHeaderQuestion[i]');
          // print(mAmHeaderQuestion[i]);
          // int pos = mAmHeaderQuestion[i];
          params.add({
            "emp_checklist_assign_id": mAmHeaderQuestion.isEmpty
                ? 0
                : mAmHeaderQuestion[i].empChecklistAssignId,
            "checklist_id": widget.activeCheckList.checklisTId,
            "checklist_item_mst_id": mAmHeaderQuestion.isEmpty
                ? 0
                : mAmHeaderQuestion[i].checklisTItemMstId,
            "checklist_Answer_Id": /* mAmHeaderQuestion[i].checkListDetails.isEmpty
                ? 0
                : */
                mAmHeaderQuestion[i].checkListDetails[0].checklisTAnswerId,
            "checklist_answer_option_id":
                mAmHeaderQuestion[i].checkListDetails.isEmpty
                    ? 0
                    : mAmHeaderQuestion[i]
                        .checkListDetails[0]
                        .checklisTAnswerOptionId,
            "approved_by": 0,
            "approved_by_datetime": "",
            "reviewed_by": 0,
            "reviewed_by_datetime": "",
            "approved_by_remarks": "",
            "rejected_by": userId,
            "rejected_by_remarks": "$userId Rejected this",
            "rejected_by_datetime": datetime_,
            "reviewed_by_remarks": "",
          });
        }
      } else {
        if (headerQuestionSelected_.isNotEmpty ||
            mAmHeaderQuestion_notSelected.isNotEmpty) {
          for (int i = 0; i < headerQuestionSelected_.length; i++) {
            int pos = headerQuestionSelected_[i];
            params.add({
              "emp_checklist_assign_id": mAmHeaderQuestion.isEmpty
                  ? 0
                  : mAmHeaderQuestion[pos].empChecklistAssignId,
              "checklist_id": widget.activeCheckList.checklisTId,
              "checklist_item_mst_id": mAmHeaderQuestion.isEmpty
                  ? 0
                  : mAmHeaderQuestion[pos].checklisTItemMstId,
              "checklist_Answer_Id": /* mAmHeaderQuestion[i].checkListDetails.isEmpty
                ? 0
                : */
                  mAmHeaderQuestion[pos].checkListDetails[0].checklisTAnswerId,
              "checklist_answer_option_id":
                  mAmHeaderQuestion[pos].checkListDetails.isEmpty
                      ? 0
                      : mAmHeaderQuestion[pos]
                          .checkListDetails[0]
                          .checklisTAnswerOptionId,
              "approved_by": userId,
              "approved_by_datetime": datetime_,
              "reviewed_by": 0,
              "reviewed_by_datetime": "",
              "approved_by_remarks": "Approved by $userId",
              "rejected_by": 0,
              "rejected_by_remarks": "",
              "rejected_by_datetime": "",
              "reviewed_by_remarks": "",
            });
          }

          for (int i = 0; i < mAmHeaderQuestion_notSelected.length; i++) {
            print('mAmHeaderQuestion_notSelected[i]');
            print(mAmHeaderQuestion_notSelected[i]);
            int pos = mAmHeaderQuestion_notSelected[i];
            params.add({
              "emp_checklist_assign_id": mAmHeaderQuestion.isEmpty
                  ? 0
                  : mAmHeaderQuestion[pos].empChecklistAssignId,
              "checklist_id": widget.activeCheckList.checklisTId,
              "checklist_item_mst_id": mAmHeaderQuestion.isEmpty
                  ? 0
                  : mAmHeaderQuestion[pos].checklisTItemMstId,
              "checklist_Answer_Id": /*mAmHeaderQuestion[pos]
                    .checkListDetails
                    .isEmpty
                ? 0
                :*/
                  mAmHeaderQuestion[pos].checkListDetails[0].checklisTAnswerId,
              "checklist_answer_option_id":
                  mAmHeaderQuestion[pos].checkListDetails.isEmpty
                      ? 0
                      : mAmHeaderQuestion[pos]
                          .checkListDetails[0]
                          .checklisTAnswerOptionId,
              "approved_by": 0,
              "approved_by_datetime": "",
              "reviewed_by": 0,
              "reviewed_by_datetime": "",
              "approved_by_remarks": "",
              "rejected_by": userId,
              "rejected_by_remarks": "$userId Rejected this",
              "rejected_by_datetime": datetime_,
              "reviewed_by_remarks": "",
            });
          }
        }
      }

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(params),
          )
          .timeout(const Duration(seconds: 10));
      print(response.statusCode);
      print(response.request);
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          showProgress = false;
        });
        // Get.off(checkListItemScreen());
        // Get.off();
        sendData();
      } else {
        _showRetryAlert(
            'Something went wrong\nStatusCode${response.statusCode}');

        setState(() {
          showProgress = false;
        });
      }
      setState(() {
        showProgress = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        showProgress = false;
      });
      /*if (tried < 1) {
        setState(() {
          tried += 1;
        });
        sendData__();
      }*/
      _showRetryAlert(Constants.networkIssue);
    }
  }

  Future<void> _showRetryAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(msg),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(22)),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white))),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(22)),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    sendData__();
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

  Future<void> sendData() async {
    setState(() {
      loading = true;
    });

    final payload =
        '{"emp_checklist_assign_id":${widget.activeCheckList.empChecklistAssignId}}';

     var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        '/RWASTAFFMOVEMENT_TEST/api/Employee/WorkFlowStatusEmp',
    );

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "emp_checklist_assign_id": widget.activeCheckList.empChecklistAssignId
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

        _showSuccessAlert(respo['message']);
      } else {
        setState(() {
          loading = false;
        });
        _showSuccessAlert(respo['message']);
      }
    } else {
      _showAlert('Something went wrong\nPlease contact IT suport');
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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => checkListScreen_lpd(
                          1,
                          widget.mGetActvityTypes,
                          widget.locationsList,
                          widget.checkList),
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
          content: Text(msg),
          actions: <Widget>[
            InkWell(
              onTap: () {
                // Navigator.of(context,rootNavigator: true).pop();
                Navigator.pop(contextt);
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

class Checklist {
  int checklistAssignId;
  int checklistItemMstId;
  int checklistId;
  String itemName;
  String startTime;
  String endTime;
  int itemWeightage;
  int mandatoryFlag;
  int activeFlag;
  int departmentRequired;
  int departmentRatingRequired;
  int storeRatingRequired;
  dynamic department;
  dynamic sectionId;
  int createdBy;
  String createdDatetime;
  int updatedBy;
  String checklistApplicableType;
  String checklistProgressStatus;
  String updatedByDatetime;

  Checklist({
    required this.checklistAssignId,
    required this.checklistItemMstId,
    required this.checklistId,
    required this.itemName,
    required this.startTime,
    required this.endTime,
    required this.itemWeightage,
    required this.mandatoryFlag,
    required this.activeFlag,
    required this.departmentRequired,
    required this.departmentRatingRequired,
    required this.storeRatingRequired,
    this.department,
    this.sectionId,
    required this.createdBy,
    required this.createdDatetime,
    required this.updatedBy,
    required this.checklistApplicableType,
    required this.checklistProgressStatus,
    required this.updatedByDatetime,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) => Checklist(
        checklistAssignId: json["checklist_assign_id"],
        checklistItemMstId: json["checklist_Item_Mst_Id"],
        checklistId: json["checklist_id"],
        itemName: json["item_name"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        itemWeightage: json["item_weightage"],
        mandatoryFlag: json["mandatory_flag"],
        activeFlag: json["active_flag"],
        departmentRequired: json["department_required"],
        departmentRatingRequired: json["department_rating_required"],
        storeRatingRequired: json["store_rating_required"],
        department: json["department"],
        sectionId: json["section_id"],
        createdBy: json["created_by"],
        createdDatetime: json["created_datetime"],
        updatedBy: json["updated_by"],
        checklistApplicableType: json["checklist_applicable_type"],
        checklistProgressStatus: json["checklist_progress_status"],
        updatedByDatetime: json["updated_by_datetime"],
      );

  Map<String, dynamic> toJson() => {
        "checklist_assign_id": checklistAssignId,
        "checklist_Item_Mst_Id": checklistItemMstId,
        "checklist_id": checklistId,
        "item_name": itemName,
        "start_time": startTime,
        "end_time": endTime,
        "item_weightage": itemWeightage,
        "mandatory_flag": mandatoryFlag,
        "active_flag": activeFlag,
        "department_required": departmentRequired,
        "department_rating_required": departmentRatingRequired,
        "store_rating_required": storeRatingRequired,
        "department": department,
        "section_id": sectionId,
        "created_by": createdBy,
        "created_datetime": createdDatetime,
        "updated_by": updatedBy,
        "checklist_applicable_type": checklistApplicableType,
        "checklist_progress_status": checklistProgressStatus,
        "updated_by_datetime": updatedByDatetime,
      };
}
