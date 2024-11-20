import 'dart:convert';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hng_flutter/data/ActiveCheckListAm.dart';
import 'package:hng_flutter/data/ActiveCheckListLpd.dart';
import 'package:hng_flutter/data/ActiveCheckListStoreAudit.dart';
import 'package:hng_flutter/data/HeaderQuesLpd.dart';
import 'package:hng_flutter/data/HeaderQuesStoreAudit.dart';
import 'package:hng_flutter/submitCheckListScreen_AM.dart';
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
import 'data/ActiveCheckListModel.dart';
import 'data/HeaderQuesStoreAM.dart';
import 'data/LPDSection.dart';

class AmAcceptSelectionScreen_AM extends StatefulWidget {
  // const AmAcceptSelectionScreen({Key? key}) : super(key: key);
  // int id;
  final ActiveCheckListAm activeCheckList;
  final LPDSection mLpdChecklist;

  AmAcceptSelectionScreen_AM(this.activeCheckList, this.mLpdChecklist);

  @override
  State<AmAcceptSelectionScreen_AM> createState() =>
      _AmAcceptSelectionScreen_AMState(
          this.activeCheckList, this.mLpdChecklist);
}

class _AmAcceptSelectionScreen_AMState
    extends State<AmAcceptSelectionScreen_AM> {
  ActiveCheckListAm activeCheckList;
  LPDSection mLpdChecklist;

  _AmAcceptSelectionScreen_AMState(this.activeCheckList, this.mLpdChecklist);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // myFuture  = getData();
    getData();
    getDataCheckList();
    nonCompFlag_O.clear();

    clearData();
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

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/json.txt'; // 3
    print('filepath');
    print(filePath);
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
    super.dispose();
    // users.clear();
    headerQuestionSelected.clear();
    // headerQuestion.clear();
    headerQuestionSelected_.clear();
    mAmHeaderQuestion_notSelected.clear();
    mAmHeaderQuestion.clear();
    clearData();

  }

  clearData() {
    mAmHeaderQuestion = [];
    mAmHeaderQuestion_notSelected = [];
    headerQuestionSelected = [];
    headerQuestionSelected_ = [];
    overallScore = [];
    nonCompFlag = [];
    nonCompFlag_O = [];
    pendingCount = 0;
    CompltedCount = 0;
    complanceFlgLength = 0;
  }



  @override
  Widget build(BuildContext context) {
    String date = widget.activeCheckList.publishDate;
    DateTime parseDate = DateFormat("dd-MM-yyyy HH:mm:ss").parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('MMM dd yyyy');
    var outputDate = outputFormat.format(inputDate); //publish_date

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
        backgroundColor: Colors.grey[50],
        body: WillPopScope(
          onWillPop: (){
            if(showCheckListDetails==true){
              setState(() {
                showCheckListDetails = false;
              });
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
                              'AM',
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
                                padding: const EdgeInsets.only(left: 15, top: 10),
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
                                            '${widget.activeCheckList.amChecklistAssignId}',
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
                              Text(
                                '${overallScore.length}/${mAmHeaderQuestion.length}',
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
                              if(showSelectAll ==false){
                                setState(() {
                                  showSelectAll = true;
                                  // signleSelection = false;
                                });
                              }else{
                                setState(() {
                                  showSelectAll = false;
                                  // signleSelection = false;
                                });
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
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

                                        for (int i = 0;
                                            i < mAmHeaderQuestion.length;
                                            i++) {
                                          setState(() {
                                            // selectedHeaderQues = headerQuestion;
                                            headerQuestionSelected_.add(i);
                                            mAmHeaderQuestion_notSelected
                                                .remove(i);
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
                                  style:
                                      TextStyle(fontSize: 12, color: Colors.grey),
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
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: ListView.builder(
                          key: _listKey,
                          itemCount: mAmHeaderQuestion.length,
                          itemBuilder: (context, pos) {
                            /*   var time = snapshot.data[pos].updatedByDatetime;
                                        int idx = time.indexOf(" ");
                                        List parts = [
                                          time.substring(0, idx).trim(),
                                          time.substring(idx + 1).trim()
                                        ];
                                        var time_ = parts[1];
*/
                            // String startTime = time_;
                            DateTime parseDate =
                                new DateFormat("dd-MM-yyyy hh:mm:ss").parse(
                                    mAmHeaderQuestion[pos].updatedByDatetime);
                            var inputDate = DateTime.parse(parseDate.toString());
                            var outputFormat = DateFormat('hh:mm a');
                            var time_ = outputFormat.format(inputDate);

                            // var time_ = 'timw';
                            return InkWell(
                              onTap: () {
                                setData(pos);

                                setState(() {
                                  index_ = pos;

                                  showCheckListDetails = true;
                                });

                                /*  // checkLocation();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      submitCheckListScreen(snapshot
                                                          .data[pos]
                                                          .checkListItemMstId
                                                          .toString())),
                                            );*/
                              },
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      Visibility(
                                        visible: showSelectAll,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
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
                                                  selectedAll = false;
                                                  showcheckBox = false;
                                                });

                                                print('headerQuestionSelected');
                                                print(headerQuestionSelected_);
                                                // }
                                              },
                                              icon: Icon(
                                                headerQuestionSelected_.isEmpty
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
                                          color: Colors.white,
                                          margin: const EdgeInsets.only(
                                              bottom: 10, left: 15, right: 15),
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 10,
                                              right: 10,
                                              bottom: 15),
                                          child: Stack(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    mAmHeaderQuestion[pos]
                                                        .itemName,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey[600]),
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
                                                      Text(
                                                          '${mAmHeaderQuestion[pos].updatedBy} - ${mAmHeaderQuestion[pos].updated_By_Name}',
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          mAmHeaderQuestion[pos]
                                                              .checklistProgressStatus,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.green)),
                                                      Text(' ' + time_,
                                                          style: const TextStyle(
                                                              fontSize: 12)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Positioned(
                                                right: 1,
                                                top: 15,
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: checklist_Header_Status == "E" ||
                                                checklist_Header_Status == "R" || checklist_Header_Status == "A"
                                            ? true
                                            : false,
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 35, top: 10),
                                        child: CircleAvatar(
                                          radius: 4.5,
                                          backgroundColor: mAmHeaderQuestion[pos]
                                                      .non_compliance_flag ==
                                                  "1"
                                              ? Colors.red
                                              : mAmHeaderQuestion[pos]
                                                          .non_compliance_flag ==
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
                          }),
                    )),
                  ],
                ),
                Visibility(
                  visible: checklist_Header_Status == "A"? showSelectAll==true?true:false:true,
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
                              const Expanded(
                                child: Text(''),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(15),
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
                                            mAmHeaderQuestion.length != 0
                                                ? checkListName
                                                : '',
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
                                              children: [
                                                /*  Text(
                                                  mAmHeaderQuestion[0].updatedBy.toString(),
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Colors
                                                          .grey[600]),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),*/
                                                Row(
                                                  children: [
                                                    const CircleAvatar(
                                                      radius: 10,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                        mAmHeaderQuestion
                                                                    .length !=
                                                                0
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
                                                                    .length !=
                                                                0
                                                            ? checklistProgressStatus
                                                            : '',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.green)),
                                                    Text(
                                                        mAmHeaderQuestion
                                                                    .length !=
                                                                0
                                                            ? ' $updatedByDatetime'
                                                            : '',
                                                        style: const TextStyle(
                                                            fontSize: 12)),
                                                  ],
                                                ),
                                              ],
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                Text(mAmHeaderQuestion.length != 0
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
                                                  mAmHeaderQuestion.length != 0
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
                                                const Text(
                                                  'ATTACH PROOF',
                                                  style: TextStyle(
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
                                          visible: answer_TypeId, //answer_type_id
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Please enter Seal Number',
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
                                            : headerQuestion[index_]
                                                            .checklistEditStatus ==
                                                        "R" ||
                                                    headerQuestion[index_]
                                                            .checklistEditStatus ==
                                                        "A"
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
                                                        submitCheckListScreen_AM(
                                                            headerQuestion[
                                                                index_],
                                                            widget
                                                                .activeCheckList,
                                                            1,
                                                            widget
                                                                .mLpdChecklist)),
                                              ).then((value) {
                                                getData();
                                                getDataCheckList();
                                              });
                                            },
                                            child: Container(
                                              width: 70,
                                              padding: const EdgeInsets.all(7),
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
                                                      size: 15,
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
                                      fontSize: 18, fontWeight: FontWeight.bold),
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
                                            color: Colors.green.withOpacity(0.5),
                                            margin:
                                                const EdgeInsets.only(right: 10),
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
                                            margin:
                                                const EdgeInsets.only(right: 10),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${nonCompFlag_O.length}',
                                          style: const TextStyle(
                                              fontSize: 20, color: Colors.green),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$CompltedCount',
                                          style: const TextStyle(
                                              fontSize: 20, color: Colors.green),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                              color: Colors.white, fontSize: 14),
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

  // late final Future myFuture = getData();

  // List<HeaderQuestion> headerQuestion = [];
  List<AmHeaderQuestion> mAmHeaderQuestion = [];
  List mAmHeaderQuestion_notSelected = [];
  List<HeaderQuestion> headerQuestionSelected = [];
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
          "${Constants.apiHttpsUrl}/AreaManager/$type/${widget.activeCheckList.amChecklistAssignId}";
      final response = await http.get(Uri.parse(url));

      var responseData = json.decode(response.body);
      mAmHeaderQuestion = [];

      Iterable l = json.decode(response.body);
      mAmHeaderQuestion = List<AmHeaderQuestion>.from(
          l.map((model) => AmHeaderQuestion.fromJson(model)));

      overallScore = [];
      nonCompFlag = [];
      nonCompFlag_O = [];


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

        if (mAmHeaderQuestion[i].non_compliance_flag == "1") {
          nonCompFlag.add(i);
          setState(() {
            complanceFlgLength = mAmHeaderQuestion.length - nonCompFlag.length;
          });
        }
        if (mAmHeaderQuestion[i].non_compliance_flag == "0") {
          nonCompFlag_O.add(i);
        }
      }

      print('amHQlen');
      print(mAmHeaderQuestion.length);

      // answer_type_id
      // return mAmHeaderQuestion;
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  List<HeaderQuesStoreAM> headerQuestion = [];
  String checklist_Header_Status = '';

  Future<void> getDataCheckList() async {
    try {
      setState(() {
        loading = true;
      });
      //replace your restFull API here.//api/CheckList/HeaderQuestion/46
      final prefs = await SharedPreferences.getInstance();

      var userID = prefs.getString('userCode') ?? '105060';
      String url =
          "${Constants.apiHttpsUrl}/AreaManager/HeaderQuestion/${widget.activeCheckList.amChecklistAssignId}/${widget.mLpdChecklist.sectionId}/$userID";

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));

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
        // checklist_Current_Stats = map['checklist_Current_Stats'];
        checklist_Header_Status = map['checklist_Header_Status'];
      });
      print(checklist_Header_Status);
      /*List<HeaderQuestion> users = data.cast<HeaderQuestion>();
    headerQuestion = users;*/
      data.forEach((element) {
        headerQuestion.add(HeaderQuesStoreAM.fromJson(element));
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

      print('asdjkfnadskjfnasdjk');
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
    }
  }

  bool loading = false;

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
    if (mAmHeaderQuestion.length != 0) {
      // for (int i = 0; i < mAmHeaderQuestion.length; i++) {
      for (int j = 0; j < mAmHeaderQuestion[i].checkListDetails.length; j++) {
        checkListName = mAmHeaderQuestion[i].itemName;
        updatedByDatetime = mAmHeaderQuestion[i].updatedByDatetime;
        checklistProgressStatus = mAmHeaderQuestion[i].checklistProgressStatus;
        checkListName = mAmHeaderQuestion[i].itemName;
        updatedBy_ = mAmHeaderQuestion[i].updatedBy.toString();
        // if (mAmHeaderQuestion[i].checkListDetails[j].answerTypeId == 3) {
        //   if (mAmHeaderQuestion[i]
        //       .checkListDetails[j]
        //       .checklistDetailImages
        //       .isNotEmpty) {
        //     print(mAmHeaderQuestion[i]
        //         .checkListDetails[j]
        //         .checklistDetailImages[0]
        //         .imageUrl);
        //
        //     setState(() {
        //       attachProof = true;
        //       attachProofImg = mAmHeaderQuestion[i]
        //           .checkListDetails[j]
        //           .checklistDetailImages[0]
        //           .imageUrl;
        //     });
        //   }
        // }
        if (mAmHeaderQuestion[i].checkListDetails[j].image_Name != "") {
          final prefs = await SharedPreferences.getInstance();

          var locationCode = widget.activeCheckList.locationCode;

          // var locationCode = prefs.getString('locationCode') ?? '106';
          /* final storageRef = FirebaseStorage.instanceFor(
                  bucket: "gs://hng-offline-marketing.appspot.com")
              .ref();*/

          /*   final imageUrl = await storageRef
              .child(
                  "$locationCode/QuesAns/${mAmHeaderQuestion[i].checkListDetails[j].image_Name}")
              .getDownloadURL();*/
          // final storageRef = FirebaseStorage.instance.ref();
          final storageRef = FirebaseStorage.instanceFor(
                  bucket: "gs://hng-offline-marketing.appspot.com")
              .ref();

          print(
              'imageUrl $locationCode->${mAmHeaderQuestion[i].checkListDetails[j].image_Name}');

          final imageUrl = await storageRef
              .child(
                  "$locationCode/QuesAns/${mAmHeaderQuestion[i].checkListDetails[j].image_Name}")
              .getDownloadURL();
          setState(() {
            attachProof = true;
            attachProofImg = imageUrl;
          });

          print('imageUrl->$imageUrl');
          // Clipboard.setData(ClipboardData(text: imageUrl));
        }

        if (mAmHeaderQuestion[i].checkListDetails[j].answerTypeId == 1) {
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
      '/RWA_GROOMING_API/api/AreaManager/QuestionUpdate',
      );

      var params = [];
      //
      // if (headerQuestionSelected_.isNotEmpty ||
      //     mAmHeaderQuestion_notSelected.isNotEmpty) {
      //   print(headerQuestionSelected_.length);
      //   for (int i = 0; i < headerQuestionSelected_.length; i++) {
      //     print('headerQuestionSelected_[i]');
      //     print(headerQuestionSelected_[i]);
      //     int pos = headerQuestionSelected_[i];
      //     params.add({
      //       "am_checklist_assign_id": mAmHeaderQuestion.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[pos].checklistAssignId,
      //       "checklist_id": widget.activeCheckList.checklisTId,
      //       "checklist_item_mst_id": mAmHeaderQuestion.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[pos].checklisTItemMstId,
      //       "checklist_Answer_Id": mAmHeaderQuestion[pos]
      //               .checkListDetails
      //               .isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[pos].checkListDetails[0].checklisTAnswerId,
      //       "checklist_answer_option_id":
      //           mAmHeaderQuestion[pos].checkListDetails.isEmpty
      //               ? 0
      //               : mAmHeaderQuestion[pos]
      //                   .checkListDetails[0]
      //                   .checklisTAnswerOptionId,
      //       "approved_by": userId,
      //       // "approved_by": 0,
      //       // "approved_by_datetime": "",
      //       "approved_by_datetime": datetime_,
      //       "reviewed_by": 0,
      //       "reviewed_by_datetime": "",
      //       // "approved_by_remarks": "",
      //       "approved_by_remarks": "Approved by $userId",
      //       "rejected_by": 0,
      //       "rejected_by_remarks": "",
      //       "rejected_by_datetime": "",
      //       "reviewed_by_remarks": "",
      //     });
      //   }
      //
      //   for (int i = 0; i < mAmHeaderQuestion_notSelected.length; i++) {
      //     print('mAmHeaderQuestion_notSelected[i]');
      //     print(mAmHeaderQuestion_notSelected[i]);
      //     int pos = mAmHeaderQuestion_notSelected[i];
      //     params.add({
      //       "lpd_checklist_assign_id": mAmHeaderQuestion.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[pos].checklistAssignId,
      //       "checklist_id": widget.activeCheckList.checklisTId,
      //       "checklist_item_mst_id": mAmHeaderQuestion.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[pos].checklisTItemMstId,
      //       "checklist_Answer_Id": mAmHeaderQuestion[pos]
      //               .checkListDetails
      //               .isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[pos].checkListDetails[0].checklisTAnswerId,
      //       "checklist_answer_option_id":
      //           mAmHeaderQuestion[pos].checkListDetails.isEmpty
      //               ? 0
      //               : mAmHeaderQuestion[pos]
      //                   .checkListDetails[0]
      //                   .checklisTAnswerOptionId,
      //       "approved_by": 0,
      //       "approved_by_datetime": "",
      //       "reviewed_by": 0,
      //       "reviewed_by_datetime": "",
      //       "approved_by_remarks": "",
      //       "rejected_by": userId,
      //       "rejected_by_remarks": "$userId Rejected this",
      //       "rejected_by_datetime": datetime_,
      //       "reviewed_by_remarks": "",
      //     });
      //   }
      // } else if (selectAll) {
      //   for (int i = 0; i < mAmHeaderQuestion.length; i++) {
      //     // print('mAmHeaderQuestion[i]');
      //     // print(mAmHeaderQuestion[i]);
      //     // int pos = mAmHeaderQuestion[i];
      //     params.add({
      //       "lpd_checklist_assign_id": mAmHeaderQuestion.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[i].checklistAssignId,
      //       "checklist_id": widget.activeCheckList.checklisTId,
      //       "checklist_item_mst_id": mAmHeaderQuestion.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[i].checklisTItemMstId,
      //       "checklist_Answer_Id": mAmHeaderQuestion[i].checkListDetails.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[i].checkListDetails[0].checklisTAnswerId,
      //       "checklist_answer_option_id":
      //           mAmHeaderQuestion[i].checkListDetails.isEmpty
      //               ? 0
      //               : mAmHeaderQuestion[i]
      //                   .checkListDetails[0]
      //                   .checklisTAnswerOptionId,
      //       "approved_by": userId,
      //       "approved_by_datetime": datetime_,
      //       "reviewed_by": 0,
      //       "reviewed_by_datetime": datetime_,
      //       "approved_by_remarks": "Approved by $userId",
      //       "rejected_by": 0,
      //       "rejected_by_remarks": "",
      //       "rejected_by_datetime": "",
      //       "reviewed_by_remarks": "",
      //     });
      //   }
      // } else if (!selectAll) {
      //   for (int i = 0; i < mAmHeaderQuestion.length; i++) {
      //     // print('mAmHeaderQuestion[i]');
      //     // print(mAmHeaderQuestion[i]);
      //     // int pos = mAmHeaderQuestion[i];
      //     params.add({
      //       "checklist_assign_id": mAmHeaderQuestion.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[i].checklistAssignId,
      //       "checklist_id": widget.activeCheckList.checklisTId,
      //       "checklist_item_mst_id": mAmHeaderQuestion.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[i].checklisTItemMstId,
      //       "checklist_Answer_Id": mAmHeaderQuestion[i].checkListDetails.isEmpty
      //           ? 0
      //           : mAmHeaderQuestion[i].checkListDetails[0].checklisTAnswerId,
      //       "checklist_answer_option_id":
      //           mAmHeaderQuestion[i].checkListDetails.isEmpty
      //               ? 0
      //               : mAmHeaderQuestion[i]
      //                   .checkListDetails[0]
      //                   .checklisTAnswerOptionId,
      //       "approved_by": 0,
      //       "approved_by_datetime": "",
      //       "reviewed_by": 0,
      //       "reviewed_by_datetime": "",
      //       "approved_by_remarks": "",
      //       "rejected_by": userId,
      //       "rejected_by_remarks": "$userId Rejected this",
      //       "rejected_by_datetime": datetime_,
      //       "reviewed_by_remarks": "",
      //     });
      //   }
      // }

      if (selectedAll) {
        for (int i = 0; i < mAmHeaderQuestion.length; i++) {
          // print('mAmHeaderQuestion[i]');
          // print(mAmHeaderQuestion[i]);
          // int pos = mAmHeaderQuestion[i];
          params.add({
            "lpd_checklist_assign_id": mAmHeaderQuestion.isEmpty
                ? 0
                : mAmHeaderQuestion[i].checklistAssignId,
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
            "am_checklist_assign_id": mAmHeaderQuestion.isEmpty
                ? 0
                : mAmHeaderQuestion[i].checklistAssignId,
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
          print("headerQuestionSelected_.length");
          print(headerQuestionSelected_.length);
          for (int i = 0; i < headerQuestionSelected_.length; i++) {
            // print('mAmHeaderQuestion[i]');
            // print(mAmHeaderQuestion[i]);
            int pos = headerQuestionSelected_[i];
            params.add({
              "am_checklist_assign_id": mAmHeaderQuestion.isEmpty
                  ? 0
                  : mAmHeaderQuestion[pos].checklistAssignId,
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
              "am_checklist_assign_id": mAmHeaderQuestion.isEmpty
                  ? 0
                  : mAmHeaderQuestion[pos].checklistAssignId,
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
        // } else {
        //   for (int i = 0; i < mAmHeaderQuestion.length; i++) {
        //     // print('mAmHeaderQuestion[i]');
        //     // print(mAmHeaderQuestion[i]);
        //     // int pos = mAmHeaderQuestion[i];
        //     params.add({
        //       "store_checklist_assign_id": mAmHeaderQuestion.isEmpty
        //           ? 0
        //           : mAmHeaderQuestion[i].storeChecklistAssignId,
        //       "checklist_id": widget.activeCheckList.checklisTId,
        //       "checklist_item_mst_id": mAmHeaderQuestion.isEmpty
        //           ? 0
        //           : mAmHeaderQuestion[i].checklisTItemMstId,
        //       "checklist_Answer_Id": mAmHeaderQuestion[i].checkListDetails[0].checklisTAnswerId,
        //       "checklist_answer_option_id":
        //           mAmHeaderQuestion[i].checkListDetails.isEmpty
        //               ? 0
        //               : mAmHeaderQuestion[i]
        //                   .checkListDetails[0]
        //                   .checklisTAnswerOptionId,
        //       "approved_by": 0,
        //       "approved_by_datetime": "",
        //       "reviewed_by": 0,
        //       "reviewed_by_datetime": "",
        //       "approved_by_remarks": "",
        //       "rejected_by": userId,
        //       "rejected_by_remarks": "$userId Rejected this",
        //       "rejected_by_datetime": datetime_,
        //       "reviewed_by_remarks": "",
        //     });
        //   }
        // }
      }

      print('URLLLL $url');
      print(params);
      // saveFile(params.toString());
      // log(params.toString());
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(params),
      );
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
        setState(() {
          showProgress = false;
        });
      }
    } catch (e) {
      setState(() {
        showProgress = false;
      });
      /*if (tried < 1) {
        setState(() {
          tried += 1;
        });
        sendData__();
      }*/
      _showRetryAlert();
    }
  }

  bool selectedAll = false;

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
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
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
        '{"checklist_assign_id":${widget.activeCheckList.amChecklistAssignId}}';

     var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        '/RWA_GROOMING_API/api/AreaManager/WorkFlowStatus',
    );

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "am_checklist_assign_id": widget.activeCheckList.amChecklistAssignId
      }),
    );

    print(response.body);
    print(response.request);
    print(response.statusCode);
    var respo = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        loading = true;
      });
      if (respo['statusCode'] == "200") {
        setState(() {
          loading = false;
        });

        // if()
        _showSuccessAlert('Checklist Successfully Submitted for Review');
        // Navigator.pop(context);
      } else {
        /* setState(() {
          loading = false;
        });*/
        _showAlert(respo['message']);
      } // Navigator.pop(context);
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
          content: Text('$msg'),
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
