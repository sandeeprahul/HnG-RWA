import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hng_flutter/data/ActiveCheckListModel.dart';
import 'package:hng_flutter/AmOutletSelectScreen.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/OutletSelectScreen.dart';
import 'package:hng_flutter/attendanceCntroller.dart';
import 'package:hng_flutter/checkListScreen.dart';
import 'package:hng_flutter/widgets/image_preview.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'common/constants.dart';
import 'data/Attendence.dart';
import 'HomeScreen.dart';
import 'data/employee_details_entity.dart';

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
    getAcitiveCheckListData();

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
            stream: getAcitiveCheckListData(),
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
                          padding: const EdgeInsets.only(left: 16, right: 16),
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
                              left: 16, right: 16, top: 20, bottom: 10),
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
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 75,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
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
                                    borderRadius: BorderRadius.circular(10.0),
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
                return const Center(
                  child: Text(''),
                );
              }
            }),
      ),
    );
  }

  Widget item(
    int pos,
    BuildContext context,
    Employeedetail employeeDetail,
  ) {
    return SizedBox(
      child: Container(
        // color: Colors.white,
        margin: const EdgeInsets.only(left: 16, top: 10, right: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0xFFBDBDBD), blurRadius: 2)],
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: employeeDetail.check_in_selfie_url == ""
                  ? const CircleAvatar()
                  : FutureBuilder<String>(
                      future: getImageDataFromFirebase(pos, employeeDetail),
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
                                          employeeDetail.employeeCode),
                                      fullscreenDialog: true));
                            },
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data ?? ''),
                            ),
                          );
                        }
                      }),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        employeeDetail.employeeName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      employeeDetail.employeeCode,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              employeeDetail.attendanceStatus,
              style: TextStyle(
                  fontSize: 12,
                  color: employeeDetail.attendanceStatus == "Not Checked In"
                      ? Colors.redAccent
                      : Colors.lightBlueAccent),
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

  Stream<List<Attendance?>> getAcitiveCheckListData() async* {
    try{
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
    }catch(ee){
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
