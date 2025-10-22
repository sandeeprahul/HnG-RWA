import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hng_flutter/checkListItemScreen.dart';
import 'package:hng_flutter/data/ActiveCheckListLpd.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/data/Locations.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AmAcceptSelectionScreen.dart';
import '../OutletSelectScreen.dart';
import '../checkInOutScreenDilo.dart';
import '../checkListItem_virtualMerch_page.dart';
import '../common/constants.dart';
import '../data/ActiveCheckListEmployee.dart';
import '../data/ActiveCheckListModel.dart';
import '../data/activeCheckList_virtualMerch_entity.dart';


class VirtualMerchCheckListPage extends StatefulWidget {
  // const checkListScreen({Key? key}) : super(key: key);

  final int type;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  //0=DILO,1=LPD,2=STORE AUDIT
  // ActiveCheckList activeCheckList;

  VirtualMerchCheckListPage(this.type, this.mGetActvityTypes, this.locationsList);

  @override
  State<VirtualMerchCheckListPage> createState() => _VirtualMerchCheckListPageState(
      this.type, this.mGetActvityTypes, this.locationsList);
}

class _VirtualMerchCheckListPageState extends State<VirtualMerchCheckListPage>
    with WidgetsBindingObserver {
  int type;
  GetActvityTypes mGetActvityTypes;
  String locationsList;

  // ActiveCheckList activeCheckList;

  _VirtualMerchCheckListPageState(this.type, this.mGetActvityTypes, this.locationsList);

  var isSelected = 0;
  var popupVisible = false;
  late int index_;
  bool loading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
          onWillPop: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OutletSelectionScreen(widget.mGetActvityTypes)),
            );
            return Future.value(true);
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
                              // Navigator.pop(context);
                              sendbacktoOutletScreen();
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
                            child: FutureBuilder<List<ActiveCheckListVirtualMerchEntity>?>(
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

                                    List<ActiveCheckListVirtualMerchEntity> checkListarray =
                                    snapshot.data!;
                                    if (checkListarray.isEmpty) {
                                      return const Center(
                                          child: Text('No data available'));
                                    } else {
                                      return ListView.builder(
                                        itemCount: checkListarray.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                              ActiveCheckListVirtualMerchEntity checkList =
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
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  index_ = index;
                                                });
                                                if (checkList.checklistEditStatus ==
                                                    "A") {
                                                  // checkList[0].checklistAssignId;
                                                  // Navigator.pushReplacement(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //       builder: (context) =>
                                                  //           AmAcceptSelectionScreen(
                                                  //               checkList
                                                  //                   .checklistAssignId,
                                                  //               checkList,
                                                  //               widget
                                                  //                   .mGetActvityTypes,
                                                  //               widget
                                                  //                   .locationsList)),
                                                  //   // builder: (context) => checkListItemScreen()),
                                                  //   // builder: (context) => HomeTemp()),
                                                  // ).then((value) => () {
                                                  //   print("returnData");
                                                  //   print(value);
                                                  //   onReturnFromScreen();
                                                  //   getActiveCheckListData();
                                                  // });
                                                } else if (checkList
                                                    .checklistEditStatus ==
                                                    "R") {
                                                  // checklist_edit_status=="R" = edit
                                                  // Navigator.pushReplacement(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //       builder: (context) =>
                                                  //           AmAcceptSelectionScreen(
                                                  //               checkList
                                                  //                   .checklistAssignId,
                                                  //               checkList,
                                                  //               widget
                                                  //                   .mGetActvityTypes,
                                                  //               widget
                                                  //                   .locationsList)),
                                                  // ).then((value) => () {
                                                  //   onReturnFromScreen();
                                                  //
                                                  //   getActiveCheckListData();
                                                  // });
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
                                                                checkListItemVirtualMerchPage(
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
                                              },
                                              child: Container(
                                                // color: Colors.white,
                                                margin: const EdgeInsets.only(
                                                    left: 10, top: 10, right: 10),
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    top: 20,
                                                    right: 20,
                                                    bottom: 20),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Color(0xFFBDBDBD),
                                                        blurRadius: 2)
                                                  ],
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(5)),
                                                ),
                                                // height: 85,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 15,
                                                                right: 25),
                                                            child: Column(
                                                              // mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                                  child: Text(
                                                                    '${checkList.checklistName} for $outputDate',
                                                                    // 'DILO MORNING STORE for Jan 20 2023',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        17,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                                  child: Text(
                                                                    'Outlet name : ${checkList.locationName} ',
                                                                    style:
                                                                    const TextStyle(
                                                                      fontSize: 13,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 7,
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                                  child: Text(
                                                                    'Checklist No: ${checkList.vm_assign_id}',
                                                                    style:
                                                                    const TextStyle(
                                                                      fontSize: 13,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 7,
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                                  child: Text(
                                                                    'Time : $outputTime - $enddTime',
                                                                    style:
                                                                    const TextStyle(
                                                                      fontSize: 12,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                          const EdgeInsets.only(
                                                              right: 15),
                                                          height: 40,
                                                          width: 1,
                                                          color: CupertinoColors
                                                              .systemGrey3,
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
                                            ),
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
          ),
        ));
  }

  List<ActiveCheckListVirtualMerchEntity> checkList = [];
  List<ActiveCheckListEmployee> checkListLpd = [];
  List<ActiveCheckListEmployee> activeCheckListLpd = [];

  void onReturnFromScreen() {
    _refreshKey.currentState?.show();
  }

  List<ActiveCheckListVirtualMerchEntity> data = [];

  Future<void> fetchData() async {
    // Fetch your data and update the UI
    try {
      List<ActiveCheckListVirtualMerchEntity>? checkList = await getActiveCheckListData();
      setState(() {
        // Update the state with the new data
        data = checkList!;
      });
    } catch (e) {
      // Handle error as needed
    }
  }

  final GlobalKey<RefreshIndicatorState> _refreshKey =
  GlobalKey<RefreshIndicatorState>();

  Future<List<ActiveCheckListVirtualMerchEntity>?> getActiveCheckListData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var locationCode = widget.locationsList;
      var userID = prefs.getString('userCode') ?? '';
      var url;
      //replace your restFull API here.

//VirtualMerchandiser/Active_CheckList/{locationcode}/{auditid}/{userId}
      url =
      "${Constants.apiHttpsUrl}/VirtualMerchandiser/Active_CheckList/$locationCode/${widget.mGetActvityTypes.auditId}/$userID";

      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 300));
      var responseData = json.decode(response.body);

      if(response.statusCode==200){
        checkList = [];
        checkList.clear();

        Iterable l = json.decode(response.body);

        List<ActiveCheckListVirtualMerchEntity> checkList_ = (responseData as List)
            .map((data) => ActiveCheckListVirtualMerchEntity.fromJson(data))
            .toList();
        checkList = checkList_;
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
    //11 dec 2023
  /*  final result = Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => checkInOutScreenDilo(
              data[index_], this.mGetActvityTypes, this.locationsList),
        ));*/

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
