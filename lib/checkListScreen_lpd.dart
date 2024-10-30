import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hng_flutter/data/ActiveCheckListLpd.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/data/GetChecklist.dart';
import 'package:hng_flutter/storeAuditCheckListScreen.dart';
import 'package:hng_flutter/tem.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'AmAcceptSelectionScreen.dart';
import 'AmAcceptSelectionScreen_Employee.dart';
import 'AmAcceptSelectionScreen_LPD.dart';
import 'checkListItemScreenExmployee.dart';
import 'common/constants.dart';
import 'data/ActiveCheckListAm.dart';
import 'data/ActiveCheckListEmployee.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/ActiveCheckListStoreAudit.dart';
import 'PageHome.dart';
import 'amCheckListScreen.dart';
import 'checkInOutScreenDilo.dart';
import 'checkInOutScreenEmployee.dart';
import 'checkInOutScreenLPD.dart';
import 'checkInOutScreenStoreAudit.dart';
import 'checkListItemScreen.dart';
import 'checkListItemScreen_Lpd.dart';
import 'imageUploadScreen.dart';
import 'lpdCheckListScreen.dart';
import 'mainCntrl.dart';

class checkListScreen_lpd extends StatefulWidget {
  // const checkListScreen({Key? key}) : super(key: key);

  final int type;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  // LPDSection mLpdChecklist;

  //0=DILO,1=LPD,2=STORE AUDIT
  // ActiveCheckList activeCheckList;

  checkListScreen_lpd(this.type, this.mGetActvityTypes, this.locationsList);

  // checkListScreen_lpd(this.type, this.mGetActvityTypes, this.locationsList, this. mLpdChecklist);

  @override
  State<checkListScreen_lpd> createState() =>
      _checkListScreen_lpdState(
          this.type, this.mGetActvityTypes, this.locationsList);
}

class _checkListScreen_lpdState extends State<checkListScreen_lpd>
    with WidgetsBindingObserver {
  int type;
  GetActvityTypes mGetActvityTypes;
  String locationsList;

  _checkListScreen_lpdState(this.type,
      this.mGetActvityTypes,
      this.locationsList,);

  var isSelected = 0;
  var popupVisible = false;
  late int index_;
  bool loading = false;

  @override
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
                            widget.mGetActvityTypes.auditName,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSelected = 0;
                          });
                        },
                        child: Column(
                          children: [
                            Text('Current',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: isSelected == 0
                                        ? Colors.blue
                                        : Colors.black)),
                            Container(
                              margin: const EdgeInsets.only(top: 7),
                              height: 1,
                              color: isSelected == 0
                                  ? Colors.blueAccent
                                  : Colors.white,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2,
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSelected = 1;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              'Pending',
                              // 'Pending(${widget.mGetActvityTypes.pendingCount})',
                              style: TextStyle(
                                  fontSize: 18,
                                  color:
                                  isSelected == 1 ? Colors.blue : Colors.black),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 7),
                              height: 1,
                              color: isSelected != 0
                                  ? Colors.blueAccent
                                  : Colors.white,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        checkListViewLpd(),
                        Visibility(
                          visible: popupVisible,
                          child: Container(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            color: const Color(0xFF80808080),
                            child: Center(
                              child: Container(
                                height: 185,
                                width: double.infinity,
                                margin: const EdgeInsets.all(15),
                                padding: const EdgeInsets.all(20),
                                decoration:
                                const BoxDecoration(color: Colors.white),
                                child: Column(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.map_pin_ellipse,
                                      size: 50,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Text(
                                      'Check-in at the',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      'Location',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          popupVisible = false;
                                        });

                                        if (widget.mGetActvityTypes.auditId ==
                                            "3") {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    checkInOutScreenLPD(
                                                      checkListLpd[index_],
                                                      widget.mGetActvityTypes,
                                                      widget.locationsList,
                                                    ),
                                              )).then((value) {
                                            getAcitiveCheckListData();
                                          });
                                        } else if (widget
                                            .mGetActvityTypes.auditId ==
                                            "2") {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    checkInOutScreenStoreAudit(
                                                      checkListStoreAudit[index_],
                                                      widget.mGetActvityTypes,
                                                      widget.locationsList,
                                                    ),
                                              )).then((value) {
                                            getAcitiveCheckListData();
                                          });
                                        } else if (widget
                                            .mGetActvityTypes.auditId ==
                                            "4") {
                                       /*   Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => checkListItemScreenEmployee(
                                                    checkListEmployee[index_],
                                                    widget.mGetActvityTypes,
                                                    widget.locationsList,
                                                    0),
                                              ));*/
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                 CheckListPage(
                                                  activeCheckList: checkListEmployee[index_],
                                                  isEdit: 0,
                                                  locationsList: widget.locationsList,
                                                  mGetActivityTypes: widget.mGetActvityTypes,
                                                  sendingToEditAmHeaderQuestion: 0,
                                                  checkListItemMstId: "${checkListEmployee[index_].checklisTId}",),
                                              )).then((value) {
                                            getAcitiveCheckListData();
                                          });
                                          //remove in production

                                        /*  Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                checkInOutScreenEmployee(
                                                    checkListEmployee[index_],
                                                    widget.mGetActvityTypes,
                                                    widget.locationsList,
                                                    ),
                                          )).then((value) {
                                        getAcitiveCheckListData();
                                      });*/
                                          //106042324000002
                                        } else if (widget
                                            .mGetActvityTypes.auditId ==
                                            "5") {
                                          /*  Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    checkInOutScreenAm(
                                                        checkListAm[index_],
                                                        widget.mGetActvityTypes,
                                                        widget.locationsList,
                                                        widget.checkList),
                                              )).then((value) {
                                            getAcitiveCheckListData();
                                          });*/

                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    amCheckListScreen(
                                                        1,
                                                        widget.mGetActvityTypes,
                                                        widget.locationsList,
                                                        checkListAm[index_]),
                                              )).then((value) =>
                                              () {
                                            getAcitiveCheckListData();
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 15),
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        child: const Center(
                                            child: Text(
                                              'Check In',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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
                  ))
            ],
          ),
        ));
  }

  Widget checkListViewLpd() {
    print(" widget.mGetActvityTypes.auditId");
    print(widget.mGetActvityTypes.auditId);
    return widget.mGetActvityTypes.auditId == "3"
        ? lpdList()
        : widget.mGetActvityTypes.auditId == "2"
        ? storeAuditList()
        : widget.mGetActvityTypes.auditId == "5"
        ? amList()
        : widget.mGetActvityTypes.auditId == "4"
        ? empList()
        : const Text('Something went wrong');
  }

  Widget lpdList() {
    return checkListLpd.length == 0
        ? const Padding(
      padding: EdgeInsets.all(10.0),
      child: Center(child: Text('No records found')),
    )
        : ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        String date = checkListLpd[index].publishDate;
        DateTime parseDate =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(date);
        var inputDate = DateTime.parse(parseDate.toString());
        var outputFormat = DateFormat('MMM dd yyyy');
        var outputDate = outputFormat.format(inputDate); //publish_date

        //starttime
        String start_time = checkListLpd[index].startTime;
        DateTime start_time_ =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(start_time);
        var startTime_ = DateTime.parse(start_time_.toString());
        var startTimeFormat = DateFormat('hh:mm a');
        var outputTime = startTimeFormat.format(startTime_);

        //outtime
        String endTime = checkListLpd[index].endTime;
        DateTime endTime_ =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(endTime);
        var endTime__ = DateTime.parse(endTime_.toString());
        // var startTimeFormat = DateFormat('hh:mm a');

        var enddTime = startTimeFormat.format(endTime__);

        return InkWell(
          onTap: () {
            setState(() {
              index_ = index;
            });

            if (checkListLpd[index].checklistEditStatus == "A") {
              // checkList[0].checklistAssignId;
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        lpdCheckListScreen(
                            1,
                            widget.mGetActvityTypes,
                            widget.locationsList,
                            checkListLpd[index]),
                  )).then((value) =>
                  () {
                getAcitiveCheckListData();
              });
            } else if (checkListLpd[index].checklistEditStatus == "R") {
              // checklist_edit_status=="R" = edit

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        lpdCheckListScreen(
                            1,
                            widget.mGetActvityTypes,
                            widget.locationsList,
                            checkListLpd[index]),
                  )).then((value) =>
                  () {
                getAcitiveCheckListData();
              });
            } else {
              if (checkListLpd[index].check_In_Flag == "1") {
                setState(() {
                  popupVisible = true;
                });
              }
            }
          },
          child: Container(
            // color: Colors.white,
            margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
            padding: const EdgeInsets.only(
                left: 10, top: 20, right: 20, bottom: 20),
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
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 15, right: 25),
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${checkListLpd[index]
                                    .checklistName} for $outputDate',
                                // 'DILO MORNING STORE for Jan 20 2023',
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Outlet name : ${checkListLpd[index]
                                    .locationName} ',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Checklist No: ${checkListLpd[index]
                                    .lpdChecklistAssignId}',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Time : $outputTime - $enddTime',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      height: 40,
                      width: 1,
                      color: CupertinoColors.systemGrey3,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
      itemCount: checkListLpd.length,
    );
  }

  Widget empList() {
    return checkListEmployee.length == 0
        ? const Padding(
      padding: EdgeInsets.all(10.0),
      child: Center(child: Text('No records found')),
    )
        : ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        String date = checkListEmployee[index].publishDate;
        DateTime parseDate =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(date);
        var inputDate = DateTime.parse(parseDate.toString());
        var outputFormat = DateFormat('MMM dd yyyy');
        var outputDate = outputFormat.format(inputDate); //publish_date

        //starttime
        String start_time = checkListEmployee[index].startTime;
        DateTime start_time_ =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(start_time);
        var startTime_ = DateTime.parse(start_time_.toString());
        var startTimeFormat = DateFormat('hh:mm a');
        var outputTime = startTimeFormat.format(startTime_);

        //outtime
        String endTime = checkListEmployee[index].endTime;
        DateTime endTime_ =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(endTime);
        var endTime__ = DateTime.parse(endTime_.toString());
        // var startTimeFormat = DateFormat('hh:mm a');

        var enddTime = startTimeFormat.format(endTime__);

        return InkWell(
          onTap: () {
            setState(() {
              index_ = index;
            });

            if (checkListEmployee[index].checklistEditStatus == "A") {
              // checkList[0].checklistAssignId;
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AmAcceptSelectionScreen_Employee(
                          checkListEmployee[index],
                          widget.mGetActvityTypes,
                          widget.locationsList,
                          widget.type,
                        ),
                  )).then((value) =>
                  () {
                getAcitiveCheckListData();
              });
            } else if (checkListEmployee[index].checklistEditStatus ==
                "R") {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AmAcceptSelectionScreen_Employee(
                            checkListEmployee[index],
                            widget.mGetActvityTypes,
                            widget.locationsList,
                            widget.type),
                  )).then((value) =>
                  () {
                getAcitiveCheckListData();
              });
            } else {
              if (checkListEmployee[index].checkinFlag == "1") {
                setState(() {
                  popupVisible = true;
                });
              }
            }
          },
          child: Container(
            // color: Colors.white,
            margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
            padding: const EdgeInsets.only(
                left: 10, top: 20, right: 20, bottom: 20),
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
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 15, right: 25),
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${checkListEmployee[index]
                                    .checklistName} for $outputDate',
                                // 'DILO MORNING STORE for Jan 20 2023',
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Outlet name : ${checkListEmployee[index]
                                    .locationName} ',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Checklist No: ${checkListEmployee[index]
                                    .empChecklistAssignId}',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Time : $outputTime - $enddTime',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      height: 40,
                      width: 1,
                      color: CupertinoColors.systemGrey3,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
      itemCount: checkListEmployee.length,
    );
  }

  Widget storeAuditList() {
    return checkListStoreAudit.length == 0
        ? const Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('No records found'),
    )
        : ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        String date = checkListStoreAudit[index].publishDate;
        DateTime parseDate =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(date);
        var inputDate = DateTime.parse(parseDate.toString());
        var outputFormat = DateFormat('MMM dd yyyy');
        var outputDate = outputFormat.format(inputDate); //publish_date

        //starttime
        String start_time = checkListStoreAudit[index].startTime;
        DateTime start_time_ =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(start_time);
        var startTime_ = DateTime.parse(start_time_.toString());
        var startTimeFormat = DateFormat('hh:mm a');
        var outputTime = startTimeFormat.format(startTime_);

        //outtime
        String endTime = checkListStoreAudit[index].endTime;
        DateTime endTime_ =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(endTime);
        var endTime__ = DateTime.parse(endTime_.toString());
        // var startTimeFormat = DateFormat('hh:mm a');

        var enddTime = startTimeFormat.format(endTime__);

        return InkWell(
          onTap: () {
            setState(() {
              index_ = index;
            });

            if (checkListStoreAudit[index].checklistEditStatus == "A") {
              // checkList[0].checklistAssignId;
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        storeAuditCheckListScreen(
                            1,
                            widget.mGetActvityTypes,
                            widget.locationsList,
                            checkListStoreAudit[index]),
                  )).then((value) =>
                  () {
                getAcitiveCheckListData();
              });
            } else if (checkListStoreAudit[index].checklistEditStatus ==
                "R") {
              // checklist_edit_status=="R" = edit

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        storeAuditCheckListScreen(
                            1,
                            widget.mGetActvityTypes,
                            widget.locationsList,
                            checkListStoreAudit[index]),
                  )).then((value) =>
                  () {
                getAcitiveCheckListData();
              });
            } else {
              if (checkListStoreAudit[index].check_In_Flag == "1") {
                setState(() {
                  popupVisible = true;
                });
              }
            }
          },
          child: Container(
            // color: Colors.white,
            margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
            padding: const EdgeInsets.only(
                left: 10, top: 20, right: 20, bottom: 20),
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
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 15, right: 25),
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${checkListStoreAudit[index]
                                    .checklistName} for $outputDate',
                                // 'DILO MORNING STORE for Jan 20 2023',
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Outlet name : ${checkListStoreAudit[index]
                                    .locationName} ',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Checklist No: ${checkListStoreAudit[index]
                                    .store_checklist_assign_id}',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Time : $outputTime - $enddTime',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      height: 40,
                      width: 1,
                      color: CupertinoColors.systemGrey3,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
      itemCount: checkListStoreAudit.length,
    );
  }

  Widget amList() {
    return checkListAm.length == 0
        ? const Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('No records found'),
    )
        : ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        String date = checkListAm[index].publishDate;
        DateTime parseDate =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(date);
        var inputDate = DateTime.parse(parseDate.toString());
        var outputFormat = DateFormat('MMM dd yyyy');
        var outputDate = outputFormat.format(inputDate); //publish_date

        //starttime
        String start_time = checkListAm[index].startTime;
        DateTime start_time_ =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(start_time);
        var startTime_ = DateTime.parse(start_time_.toString());
        var startTimeFormat = DateFormat('hh:mm a');
        var outputTime = startTimeFormat.format(startTime_);

        //outtime
        String endTime = checkListAm[index].endTime;
        DateTime endTime_ =
        DateFormat("dd-MM-yyyy HH:mm:ss").parse(endTime);
        var endTime__ = DateTime.parse(endTime_.toString());
        // var startTimeFormat = DateFormat('hh:mm a');

        var enddTime = startTimeFormat.format(endTime__);

        return InkWell(
          onTap: () {
            setState(() {
              index_ = index;
            });

            if (checkListAm[index].checklistEditStatus == "A") {
              // checkList[0].checklistAssignId;
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        amCheckListScreen(
                            1,
                            widget.mGetActvityTypes,
                            widget.locationsList,
                            checkListAm[index]),
                  )).then((value) =>
                  () {
                getAcitiveCheckListData();
              });
            } else if (checkListAm[index].checklistEditStatus == "R") {
              // checklist_edit_status=="R" = edit

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        amCheckListScreen(
                            1,
                            widget.mGetActvityTypes,
                            widget.locationsList,
                            checkListAm[index]),
                  )).then((value) =>
                  () {
                getAcitiveCheckListData();
              });
            } else {
              if (checkListAm[index].check_In_Flag == "1") {
                setState(() {
                  popupVisible = true;
                });
              }
            }
          },
          child: Container(
            // color: Colors.white,
            margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
            padding: const EdgeInsets.only(
                left: 10, top: 20, right: 20, bottom: 20),
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
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 15, right: 25),
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${checkListAm[index]
                                    .checklistName} for $outputDate',
                                // 'DILO MORNING STORE for Jan 20 2023',
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Outlet name : ${checkListAm[index]
                                    .locationName} ',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Checklist No: ${checkListAm[index]
                                    .amChecklistAssignId}',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Time : $outputTime - $enddTime',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      height: 40,
                      width: 1,
                      color: CupertinoColors.systemGrey3,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
      itemCount: checkListAm.length,
    );
  }

  // List<ActiveCheckList> checkList = [];
  List<ActiveCheckListLpd> checkListLpd = [];
  List<ActiveCheckListStoreAudit> checkListStoreAudit = [];
  List<ActiveCheckListAm> checkListAm = [];
  List<ActiveCheckListEmployee> checkListEmployee = [];

  // List<ActiveCheckListLpd> activeCheckListLpd = [];

  Future<void> getAcitiveCheckListData() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var locationCode = widget.locationsList;
      var userID = prefs.getString('userCode') ?? '105060';
      var url;
      //replace your restFull API here.

      if (widget.mGetActvityTypes.auditId == "3") {
        url =
        "${Constants
            .apiHttpsUrl}/lpdaudit/Active_CheckList/$locationCode/${widget
            .mGetActvityTypes.auditId}/$userID";
      } else if (widget.mGetActvityTypes.auditId == "2") {
        url =
        "${Constants
            .apiHttpsUrl}/StoreAudit/Active_CheckList/$locationCode/${widget
            .mGetActvityTypes.auditId}/$userID";
      } else if (widget.mGetActvityTypes.auditId == "5") {
        url =
        "${Constants
            .apiHttpsUrl}/AreaManager/Active_CheckList/$locationCode/${widget
            .mGetActvityTypes.auditId}/$userID";
      } else if (widget.mGetActvityTypes.auditId == "4") {
        url =
        "${Constants
            .apiHttpsUrl}/Employee/Active_CheckList/$locationCode/${widget
            .mGetActvityTypes.auditId}/$userID";
      }

      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      print(url);
      print(response.body);

      var responseData = json.decode(response.body);

      checkListLpd = [];
      checkListStoreAudit = [];
      checkListAm = [];
      checkListEmployee = [];

      Iterable l = json.decode(response.body);
      if (widget.mGetActvityTypes.auditId == "3") {
        checkListLpd = List<ActiveCheckListLpd>.from(
            l.map((model) => ActiveCheckListLpd.fromJson(model)));
      } else if (widget.mGetActvityTypes.auditId == "2") {
        checkListStoreAudit = List<ActiveCheckListStoreAudit>.from(
            l.map((model) => ActiveCheckListStoreAudit.fromJson(model)));
      } else if (widget.mGetActvityTypes.auditId == "5") {
        checkListAm = List<ActiveCheckListAm>.from(
            l.map((model) => ActiveCheckListAm.fromJson(model)));
      } else if (widget.mGetActvityTypes.auditId == "4") {
        checkListEmployee = List<ActiveCheckListEmployee>.from(
            l.map((model) => ActiveCheckListEmployee.fromJson(model)));
      }
      print('checkListEmployee');
      print(checkListEmployee.length);

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
          content: const Text('Network issue\nPlease retry'),
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
            Container(
              padding: const EdgeInsets.all(15),
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

//   Future<List<ActiveCheckListLpd>> getAcitiveCheckListLPDData() async {
//     final prefs = await SharedPreferences.getInstance();
//     var locationCode = prefs.getString('locationCode') ?? '106';
//     var userID = prefs.getString('userCode') ?? '105060';
//     var url;
//     //replace your restFull API here.

//
//     print(url);
//     final response = await http.get(Uri.parse(url));
//     print(response.body);
//
//     var responseData = json.decode(response.body);
//
//     //Creating a list to store input data;
//     activeCheckListLpd = [];
//
//     if (type == 2) {
//       Iterable l = json.decode(response.body);
//       activeCheckListLpd = List<ActiveCheckListLpd>.from(
//           l.map((model) => ActiveCheckListLpd.fromJson(model)));
//       print("lpd;list.length");
//       print(checkList.length);
//     }
//
// /*
//     for (var singleUser in responseData) {
//       ActiveCheckList user = ActiveCheckList(
//         checklistAssignId: singleUser["checklist_assign_id"],
//         regionCode: singleUser["region_code"],
//         regionName: singleUser["region_name"],
//         locationCode: singleUser["location_code"],
//         locationName: singleUser["location_name"],
//         publishDate: singleUser["publish_date"],
//         id: singleUser["id"],
//         auditType: singleUser["audit_type"],
//         iconUrl: singleUser["icon_url"],
//         apiRefType: singleUser["api_ref_type"],
//         weCareFlag: singleUser["we_care_flag"],
//         nonComplianceFlag: singleUser["non_compliance_flag"],
//         posBosFlag: singleUser["pos_bos_flag"],
//         checkinFlag: singleUser["checkin_flag"],
//         locationFlag: singleUser["location_flag"],
//         sectionFlag: singleUser["section_flag"],
//         frequencyFlag: singleUser["frequency_flag"],
//         activeFlag: singleUser["active_flag"],
//         checklisTId: singleUser["checklisT_ID"],
//         auditTypeId: singleUser["audit_type_id"],
//         checklistName: singleUser["checklist_name"],
//         startDate: singleUser["start_date"],
//         endDate: singleUser["end_date"],
//         startTime: singleUser["start_time"],
//         endTime: singleUser["end_time"],
//         empCutoffTime: singleUser["emp_cutoff_time"],
//         managerCutoffTime: singleUser["manager_cutoff_time"],
//         publishFlag: singleUser["publish_flag"],
//         checklistApplicableType: singleUser["checklist_applicable_type"],
//         checklistProgressStatus: singleUser["checklist_progress_status"],
//       );
//
//       //Adding user to the list.
//       checkList.add(user);
//     }*/
//     return activeCheckListLpd;
//   }
}