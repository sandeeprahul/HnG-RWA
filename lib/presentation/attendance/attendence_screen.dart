import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/data/ActiveCheckListModel.dart';
import 'package:hng_flutter/AmOutletSelectScreen.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/OutletSelectScreen.dart';
import 'package:hng_flutter/attendanceCntroller.dart';
import 'package:hng_flutter/checkListScreen.dart';
import 'package:hng_flutter/extensions/string_extension.dart';
import 'package:hng_flutter/widgets/image_preview.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/Attendence.dart';
import '../../HomeScreen.dart';
import '../../data/employee_details_entity.dart';

class AttendenceScreen extends StatefulWidget {
  const AttendenceScreen({Key? key}) : super(key: key);

  @override
  State<AttendenceScreen> createState() => _AttendenceScreenState();
}

bool am = false;
var status_ = false;

class _AttendenceScreenState extends State<AttendenceScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkList = [];
    checkList.clear();
    // getDeviceConfig();
    getActiveCheckListData();

    // getAcitiveCheckListData();
  }

  final AttendanceController attendanceController =
      Get.put(AttendanceController());

  TextEditingController searchController = TextEditingController();
  var showImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Attendance?>>(
            stream: getActiveCheckListData(),
            builder: (builder, snapshot) {
              if (snapshot.hasData) {
                final attendanceList = snapshot.data!;
                return Stack(
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
                                  'My team activities',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        'My Team',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Container(
                                        height: 1,
                                        width: 75,
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Visibility(
                                      visible: false,
                                      child: Text(
                                        'Approvals',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )),
                                ],
                              )),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 20, bottom: 10),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Team Statistics for Today',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16,right: 8,top: 8,bottom: 8),
                          child: SizedBox(
                            height: 75,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Text(
                                        attendanceList.isEmpty
                                            ? ''
                                            : attendanceList[0]!
                                                .employeedetails
                                                .length
                                                .toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const Text(
                                        'My Team',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Text(
                                        attendanceList.isEmpty
                                            ? ''
                                            : attendanceList[0]!.presentcnt,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const Text(
                                        'Present',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Text(
                                        attendanceList.isEmpty
                                            ? ''
                                            : attendanceList[0]!
                                                .absentcnt
                                                .toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const Text(
                                        'Absent',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(
                                      right: 20, left: 20),
                                  decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Text(
                                        attendanceList.isEmpty
                                            ? ''
                                            : attendanceList[0]!.weekoffcnt,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const Text(
                                        'WeekOff',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(
                                    right: 20,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Text(
                                        attendanceList.isEmpty
                                            ? ''
                                            : attendanceList[0]!.leavecnt,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const Text(
                                        'Leaves',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical:8,horizontal: 16 ),
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: attendanceController.searchController,
                              enabled: false,
                              // onChanged: (value) => _runFilter(value),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(0),
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  filled: true,
                                  hintStyle: TextStyle(
                                      color: Colors.grey[800], fontSize: 13),
                                  hintText: "Search for an employee",
                                  fillColor: Colors.white70),
                            ),
                          ),
                        ),
                        Expanded(
                          child: attendanceList.isEmpty
                              ? const Text('No Records')
                              : attendanceList[0]!.employeedetails.isEmpty
                                  ? const Text('No Records')
                                  : ListView.builder(
                                      // physics: const BouncingScrollPhysics(),
                                      itemCount: attendanceList[0]!
                                          .employeedetails
                                          .length,
                                      itemBuilder:
                                          (BuildContext context, int pos) {
                                        return item(
                                            pos,
                                            context,
                                            attendanceList[0]!
                                                .employeedetails[pos]);
                                      }),
                        ),
                        const SizedBox(
                          height: 15,
                        )
                      ],
                    ),
                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Center(child: Text("${snapshot.error}"));
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        Constants.networkIssue,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18))),
                        onPressed: () async {
                          Navigator.pop(context);
                          // await getActiveCheckListData();
                        },

                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Retry'),
                        ))
                  ],
                );
              }
            }),
      ),
    );
  }

  Widget item(
    int pos,
    BuildContext context,
    Employeedetail employeedetail,
  ) {
    return SizedBox(
      child: Container(
        // color: Colors.white,
        margin: const EdgeInsets.only(left: 16, top: 10, right: 16),
        padding: const EdgeInsets.only(top: 10, left: 6, right: 6),
        decoration:  BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey[200]!,offset: const Offset(2, 2))],
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
              ),
              child: employeedetail.check_in_selfie_url == ""
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CircleAvatar(
                        radius: 28,
                        child: Text(employeedetail.employeeName.getInitials()),
                      ),
                    )
                  : FutureBuilder<String>(
                      future: getImageDataFromFirebase(pos, employeedetail),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // While the future is loading, you can return a loading indicator or placeholder widget.
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // If an error occurred while loading the data, you can handle and display the error.
                          return const CircleAvatar();
                        } else {
                          return InkWell(
                            onTap: () {
                              // showAlertDialog(context, snapshot.data ?? '');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImagePreview(
                                          snapshot.data!,
                                          employeedetail.employeeCode),
                                      fullscreenDialog: true));
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  NetworkImage(snapshot.data ?? ''),
                            ),
                          );
                        }
                      }),
            ),
            Expanded(
              // flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      employeedetail.employeeName,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Stack(
                    children: [
                      Text(
                        '${employeedetail.locationCode} - ${employeedetail.designation}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              color: employeedetail.attendanceStatus ==
                                  "Not Checked In"
                                  ? Colors.redAccent
                                  : Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            employeedetail.attendanceStatus,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Visibility(
                    visible: employeedetail.attendanceStatus == "Not Checked In"
                        ? false
                        : true,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Container(height: 1,width: ,),
                          // const Divider(),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Transform.rotate(
                                      angle: 120,
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        size: 12,
                                        color: Colors.blue,
                                      )),
                                  Text(employeedetail.checkintime,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.green)),
                                ],
                              ),
                              const SizedBox(
                                width: 50,
                              ),
                              Row(
                                children: [
                                  Transform.rotate(
                                      angle: 200,
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        size: 12,
                                        color: Colors.blue,
                                      )),
                                  Text(
                                      employeedetail.checkouttime.isEmpty
                                          ? '--:--'
                                          : employeedetail.checkouttime,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.green)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const Spacer(),
            Visibility(
              visible: false,
              child: Expanded(
                child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.blue)),
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Column(
                    children: [
                      // Container(height: 1,width: ,),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RichText(
                                text: TextSpan(children: <TextSpan>[
                              const TextSpan(
                                  text: '  IN',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.black)),
                              TextSpan(
                                  // text: '\n9:40 AM',
                                  text: '\n${employeedetail.checkintime} ',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black)),
                            ])),
                            Container(
                              height: 25,
                              color: Colors.black,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 1,
                            ),
                            RichText(
                                text: TextSpan(children: <TextSpan>[
                              const TextSpan(
                                text: ' OUT',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.black),
                              ),
                              TextSpan(
                                  // text: '\n9:40 AM',
                                  //
                                  text: '\n${employeedetail.checkouttime}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black)),
                            ]))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Column(
            children: [
              Expanded(child: Image.network(imageUrl)),
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          /* actions: [
            ElevatedButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],*/
        );
      },
    );
  }

  List<Attendance> checkList = [];

  Stream<List<Attendance?>> getActiveCheckListData() async* {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '';
      String url =
          "${Constants.apiHttpsUrl}/Attendance/GetEmployeeAttendanceStatus/$userID";

      print(url);
      final response = await http.get(Uri.parse(url));
      checkList = [];
      Iterable l = json.decode(response.body);
      checkList =
          List<Attendance>.from(l.map((model) => Attendance.fromJson(model)));

      // checkList.addAll(checkList);

      yield checkList;
    } catch (ee) {
      print("getAcitiveCheckListData$ee");
    }
  }

  Future<String> getImageDataFromFirebase(
      int pos, Employeedetail employeedetail) async {
    try {
      final imageUrl = await FirebaseStorage.instanceFor(
              bucket: "gs://hng-offline-marketing.appspot.com")
          .ref()
          .child(
              "${employeedetail.locationCode}/attendance/${employeedetail.check_in_selfie_url}")
          .getDownloadURL();
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "";
    }
  }
}

//[
//   {
//     "id": 1,
//     "audit_Type": "DILO",
//     "api_Ref_Type": "dilo_based_audit_list",
//     "icon_Url": "https://health-and-glow-dev.s3.ap-south-1.amazonaws.com/1580384272.png",
//     "we_Care_Flag": "1",
//     "non_Compliance_Flag": "1",
//     "pos_Bos_Flag": "1",
//     "location_Flag": "0",
//     "checkin_Flag": "1",
//     "section_Flag": "0",
//     "checkList_Id": "46",
//     "audit_Type_Id": "1",
//     "checklist_Name": "DILO MORNING STORE",
//     "start_Date": "2022-11-29T00:00:00",
//     "end_Date": "2022-12-31T00:00:00",
//     "emp_Cutoff_Time": "30-11-2022 11:35:00",
//     "manager_Cutoff_Time": "30-11-2022 13:30:00",
//     "publish_Flag": "0",
//     "frequency_Flag": "1"
//   }
