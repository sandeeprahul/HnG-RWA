import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'AmAcceptSelectionScreen.dart';
import 'common/constants.dart';
import 'data/ActiveCheckListEmployee.dart';
import 'data/ActiveCheckListModel.dart';
import 'OutletSelectScreen.dart';
import 'checkInOutScreenDilo.dart';
import 'checkListItemScreen.dart';


class checkListScreen extends StatefulWidget {
  // const checkListScreen({Key? key}) : super(key: key);

  final int type;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  //0=DILO,1=LPD,2=STORE AUDIT
  // ActiveCheckList activeCheckList;

  checkListScreen(this.type, this.mGetActvityTypes, this.locationsList);

  @override
  State<checkListScreen> createState() => _checkListScreenState(
      this.type, this.mGetActvityTypes, this.locationsList);
}

class _checkListScreenState extends State<checkListScreen>
    with WidgetsBindingObserver {
  int type;
  GetActvityTypes mGetActvityTypes;
  String locationsList;

  // ActiveCheckList activeCheckList;

  _checkListScreenState(this.type, this.mGetActvityTypes, this.locationsList);

  var isSelected = 0;
  var popupVisible = false;
  late int index_;
  bool loading = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("resumedCheckListScreen");
      fetchData();

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
    fetchData();
    getActiveCheckListData();
  }

  /*onWillPop: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OutletSelectionScreen(widget.mGetActvityTypes)),
        );
        return Future.value(true);
      },*/
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
                            // Get.back();
                            // sendbacktoOutletScreen();
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
                                // 'Current(${widget.mGetActvityTypes.currentCount})',
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
                              width: MediaQuery.of(context).size.width / 2,
                            ),
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
                                  color: isSelected == 1
                                      ? Colors.blue
                                      : Colors.black),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 7),
                              height: 1,
                              color: isSelected != 0
                                  ? Colors.blueAccent
                                  : Colors.white,
                              width: MediaQuery.of(context).size.width / 2,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        // checkListView(),
                        RefreshIndicator(
                          key: _refreshKey,
                          onRefresh: () async {
                            await fetchData();
                          },
                          child: FutureBuilder<List<ActiveCheckList>?>(
                              future: getActiveCheckListData(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  // Error occurred while fetching data
                                  return Center(
                                      child: Center(
                                          child:
                                              Text("Error: ${snapshot.error}")));
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // Handle other cases if needed
                                  return Center(
                                    child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                10,
                                        width:
                                            MediaQuery.of(context).size.width / 5,
                                        child: const CircularProgressIndicator()),
                                  );
                                } else if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  // final checkListData = snapshot.data!;

                                  List<ActiveCheckList> checkListarray =
                                      snapshot.data!;
                                  if (checkListarray.isEmpty) {
                                    return const Center(
                                        child: Text('No data available'));
                                  } else {
                                    return ListView.builder(
                                      itemCount: checkListarray.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        ActiveCheckList checkList =
                                            checkListarray[index];

                                        // final checkList = checkListData[index];
                                        String date = checkList.publishDate;
                                        DateTime parseDate =
                                            DateFormat("dd-MM-yyyy HH:mm:ss")
                                                .parse(date);
                                        var inputDate =
                                            DateTime.parse(parseDate.toString());
                                        var outputFormat =
                                            DateFormat('MMM dd yyyy');
                                        var outputDate = outputFormat
                                            .format(inputDate); //publish_date

                                        //starttime
                                        String start_time = checkList.startTime;
                                        DateTime start_time_ =
                                            DateFormat("dd-MM-yyyy HH:mm:ss")
                                                .parse(start_time);
                                        var startTime_ = DateTime.parse(
                                            start_time_.toString());
                                        var startTimeFormat =
                                            DateFormat('hh:mm a');
                                        var outputTime =
                                            startTimeFormat.format(startTime_);

                                        //outtime
                                        String endTime = checkList.endTime;
                                        DateTime endTime_ =
                                            DateFormat("dd-MM-yyyy HH:mm:ss")
                                                .parse(endTime);
                                        var endTime__ =
                                            DateTime.parse(endTime_.toString());
                                        // var startTimeFormat = DateFormat('hh:mm a');

                                        var enddTime =
                                            startTimeFormat.format(endTime__);

                                        return Visibility(
                                          visible: isSelected == 0
                                              ? checkList.checklist_Current_Status_Type ==
                                                      "C"
                                                  ? true
                                                  : false
                                              : checkList.checklistEditStatus ==
                                                      "P"
                                                  ? true
                                                  : false,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.08),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(12),
                                                  onTap: () {
                                                    setState(() {
                                                      index_ = index;
                                                    });
                                                    if (checkList.checklistEditStatus ==
                                                        "A") {
                                                      // checkList[0].checklistAssignId;
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AmAcceptSelectionScreen(
                                                                    checkList
                                                                        .checklistAssignId,
                                                                    checkList,
                                                                    widget
                                                                        .mGetActvityTypes,
                                                                    widget
                                                                        .locationsList)),
                                                        // builder: (context) => checkListItemScreen()),
                                                        // builder: (context) => HomeTemp()),
                                                      ).then((value) => () {
                                                        print("returnData");
                                                        print(value);
                                                        onReturnFromScreen();
                                                        getActiveCheckListData();
                                                      });
                                                    } else if (checkList
                                                        .checklistEditStatus ==
                                                        "R") {
                                                      // checklist_edit_status=="R" = edit
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AmAcceptSelectionScreen(
                                                                    checkList
                                                                        .checklistAssignId,
                                                                    checkList,
                                                                    widget
                                                                        .mGetActvityTypes,
                                                                    widget
                                                                        .locationsList)),
                                                      ).then((value) => () {
                                                        onReturnFromScreen();

                                                        getActiveCheckListData();
                                                      });
                                                    } else {
                                                      if (checkList.check_In_Flag ==
                                                          "1") {
                                                        // checkDistance_(
                                                        //     latt, lngg, lat_, lng_,v);
                                                        setState(() {
                                                          popupVisible = true;
                                                        });
                                                      } else {
                                                        if (type == 1) {
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    checkListItemScreen(
                                                                        checkList,
                                                                        widget
                                                                            .mGetActvityTypes,
                                                                        widget
                                                                            .locationsList),
                                                              )).then((value) => () {
                                                            onReturnFromScreen();

                                                            getActiveCheckListData();
                                                          });
                                                        } else if (type == 2) {
                                                          /* Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                checkListItemScreen_Lpd(
                                          activeCheckListLpd[0]),
                                                                          ));*/
                                                        } else if (type == 2) {}
                                                      }
                                                    }
                                                  }, // Add your onTap function
                                                splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Header Row
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // Status Indicator
                                                          Container(
                                                            width: 6,
                                                            height: 60,
                                                            decoration: BoxDecoration(
                                                              color: Theme.of(context).primaryColor,
                                                              borderRadius: BorderRadius.circular(3),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 16),

                                                          // Content
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                // Title with Date
                                                                Text(
                                                                  '${checkList.checklistName} • $outputDate',
                                                                  style: const TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: Colors.black87,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 8),

                                                                // Outlet Info
                                                                _buildInfoRow(
                                                                  icon: Icons.store_outlined,
                                                                  text: checkList.locationName,
                                                                ),

                                                                // Checklist No
                                                                _buildInfoRow(
                                                                  icon: Icons.list_alt_outlined,
                                                                  text: 'Checklist #${checkList.checklistAssignId}',
                                                                ),

                                                                // Time Range
                                                                _buildInfoRow(
                                                                  icon: Icons.access_time_outlined,
                                                                  text: '$outputTime - $enddTime',
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          // Arrow Icon
                                                          Icon(
                                                            Icons.arrow_forward_ios_rounded,
                                                            size: 18,
                                                            color: Colors.grey[400],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  return const Center(
                                    child:
                                        Text('No data available at this moment}'),
                                  );
                                }
                              }),
                        ),
                        Visibility(
                          visible: popupVisible,
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
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
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      'Location',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          popupVisible = false;
                                        });
                                        navigatecheckInOutScreenDilo(context);

                                        /* if (widget.mGetActvityTypes.auditId=="3") {
                                        */ /*  Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    checkInOutScreenDilo_Lpd(
                                                        checkListLpd[index_]),
                                              )).then((value) {
                                            getAcitiveCheckListData();
                                          });*/ /*
                                        } else if (type == 2) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    checkInOutScreenDilo(
                                                        checkList[index_]),
                                              ));
                                        }*/
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
                                          style: TextStyle(color: Colors.white),
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

  List<ActiveCheckList> checkList = [];
  List<ActiveCheckListEmployee> checkListLpd = [];
  List<ActiveCheckListEmployee> activeCheckListLpd = [];

  void onReturnFromScreen() {
    _refreshKey.currentState?.show();
  }

  List<ActiveCheckList> data = [];

  Future<void> fetchData() async {
    // Fetch your data and update the UI
    try {
      List<ActiveCheckList>? checkList = await getActiveCheckListData();
      setState(() {
        // Update the state with the new data
        data = checkList!;
      });
    } catch (e) {
      // Handle error as needed
    }
  }

  // Reusable Info Row Widget
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  Future<List<ActiveCheckList>?> getActiveCheckListData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var locationCode = widget.locationsList;
      var userID = prefs.getString('userCode') ?? '';
      var url;
      //replace your restFull API here.
      if (widget.mGetActvityTypes.auditId == "4") {
        url =
            "${Constants.apiHttpsUrl}/Employee/Active_CheckList/$locationCode/${widget.mGetActvityTypes.auditId}/$userID";
      } else {
        url =
            "${Constants.apiHttpsUrl}/CheckList/Active_CheckList/$locationCode/${widget.mGetActvityTypes.auditId}/$userID";
      }

      url =
          "${Constants.apiHttpsUrl}/CheckList/Active_CheckList/$locationCode/${widget.mGetActvityTypes.auditId}/$userID";
      print(url);
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      var responseData = json.decode(response.body);

      if(response.statusCode==200){
        checkList = [];
        checkList.clear();

        Iterable l = json.decode(response.body);

        List<ActiveCheckList> checkList_ = (responseData as List)
            .map((data) => ActiveCheckList.fromJson(data))
            .toList();
        checkList = checkList_;
/*
       if(widget.mGetActvityTypes.auditId == "4"){
        checkListEmployee  = List<ActiveCheckListEmployee>.from(
            l.map((model) => ActiveCheckListEmployee.fromJson(model)));
      }else{

       }*/

        return checkList_;
      }else{

        _showRetryAlert( "Something went wrong\n${response.statusCode}\nPlease contact it support");
        return null;
      }


      // yield checkList;
    } catch (e) {
      // _streamController.addError(e);
      _showRetryAlert(Constants.networkIssue);

      throw Exception("Failed to fetch data");
    }
  }

  Future<void> navigatecheckInOutScreenDilo(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => checkInOutScreenDilo(
              data[index_], this.mGetActvityTypes, this.locationsList),
        ));

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!mounted) return;

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    /*  ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$result')));*/
    /* if(result=="reload"){
      fetchData();
    }*/
  }

  Future<void> _showRetryAlert(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Alert!'),
          content:  Text(message),
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
            CustomElevatedButton(
                text: 'Retry',
                onPressed: () {
                  Navigator.of(contextt).pop();
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  void sendbacktoOutletScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => OutletSelectionScreen(widget.mGetActvityTypes)),
    );
  }
}
