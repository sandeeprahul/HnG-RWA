import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'data/DepartmentIssues.dart';
import 'data/TicketResponse.dart';
import 'data/wecare_location.dart';

class WeCareScreen extends StatefulWidget {
  const WeCareScreen({Key? key}) : super(key: key);

  @override
  State<WeCareScreen> createState() => _WeCareScreenState();
}

class _WeCareScreenState extends State<WeCareScreen> {
  bool weCareLocationPopup = false;
  String weCareLocation = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIssueList();
    fetchLocations();
    setState(() {
      caseNu = '';
      popup = false;
      issue = 'Select Department';
    });
    departmentIssues.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: const Text(
          'Wecare',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  'Do you want to register this an issue in wecare and create a ticket?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Subject',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: subjectCntrl,
                  decoration: InputDecoration(
                    hintText: 'Enter subject of ticket',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Prority',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 15, bottom: 15, left: 15, right: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text('Select priority'),
                      Text('P1'),
                      Icon(Icons.keyboard_arrow_down_sharp)
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Department',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      popup = true;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(issue), //issue
                        const Icon(Icons.keyboard_arrow_down_sharp)
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      weCareLocationPopup = true;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(weCareLocation), //issue
                        const Icon(Icons.keyboard_arrow_down_sharp)
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                //issue
                const Text(
                  'Issue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    if (departmentIssues.isNotEmpty) {
                      setState(() {
                        issuePopup = true;
                      });
                    } else {
                      _showAlert("Please select department");
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(issue_)), //issue
                        const Icon(Icons.keyboard_arrow_down_sharp)
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: descitionCntrl,
                  maxLines: null,
                  minLines: 4,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Enter ticket discription',
                    hintMaxLines: 5,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: MaterialButton(
              onPressed: () {
                if (subjectCntrl.text.isEmpty) {
                  _showAlert('Please fill details');
                } else if (descitionCntrl.text.isEmpty) {
                  _showAlert('Please fill details');
                } else if (issue == 'Select department') {
                  _showAlert('Please select department');
                } else if (issue_ == 'Select issue') {
                  _showAlert('Please select issue');
                }else if (selectedWeCareLocation==null){
                  _showAlert('Please select location');

                } else {
                  sendData();
                }
              },
              minWidth: double.infinity,
              height: 50,
              color: Colors.blue,
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Visibility(
            visible: popup,
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5),
              child: Container(
                margin: const EdgeInsets.all(30),
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Stack(
                        children: [
                          const Center(
                            child: Text(
                              'Select department',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    popup = false;
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.close),
                                )),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      // height: 400,
                      child: departmentIssues.isEmpty
                          ? const Text('No data')
                          : ListView.separated(
                              itemCount: departmentIssues.length,
                              itemBuilder: (context, pos) {
                                return ListTile(
                                    // dense: true,

                                    onTap: () {
                                      setState(() {
                                        popup = false;
                                        issue =
                                            departmentIssues[pos].department;
                                        departmentIndex = pos;
                                        issue_ = "Select issue";
                                      });
                                      print(departmentIssues[pos].department);
                                    },
                                    title:
                                        Text(departmentIssues[pos].department));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider();
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: weCareLocationPopup,
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5),
              child: Container(
                margin: const EdgeInsets.all(30),
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Stack(
                        children: [
                          const Center(
                            child: Text(
                              'Select Location',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    weCareLocationPopup = false;
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.close),
                                )),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      // height: 400,
                      child: wecareLocations.isEmpty
                          ? const Text('No data')
                          : ListView.separated(
                              itemCount: wecareLocations.length,
                              itemBuilder: (context, pos) {
                                if (wecareLocations[pos].weCareFlag != "1") {
                                  return ListTile(
                                      onTap: () {
                                        setState(() {
                                          weCareLocationPopup = false;
                                          selectedWeCareLocation =
                                              wecareLocations[pos];
                                          weCareLocation =
                                              wecareLocations[pos].locationName;
                                        });
                                      },
                                      title: Text(
                                          wecareLocations[pos].locationName));
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider();
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: issuePopup,
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5),
              child: Container(
                margin: const EdgeInsets.all(30),
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Stack(
                        children: [
                          const Center(
                            child: Text(
                              'Select issue',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    issuePopup = false;
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.close),
                                )),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      // height: MediaQuery,
                      child: issue == "Select department"
                          ? const Text('No data')
                          : departmentIssues.length == 0
                              ? const Text('No data')
                              : ListView.separated(
                                  itemCount: departmentIssues[departmentIndex]
                                      .issues
                                      .length,
                                  itemBuilder: (context, pos) {
                                    return ListTile(
                                        // dense: true,

                                        onTap: () {
                                          setState(() {
                                            issuePopup = false;
                                            issue_ = departmentIssues[
                                                    departmentIndex]
                                                .issues[pos];
                                          });
                                        },
                                        title: Text(
                                            departmentIssues[departmentIndex]
                                                .issues[pos]));
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider();
                                  },
                                ),
                    ),
                  ],
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
    );
  }

  Future<void> _showAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Alert'),
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

  TextEditingController descitionCntrl = TextEditingController();
  TextEditingController subjectCntrl = TextEditingController();

  List<DepartmentIssues> departmentIssues = [];
  List<TicketResponse> ticketRes = [];
  List<WeCareLocation> wecareLocations = [];
  WeCareLocation? selectedWeCareLocation;
  var popup = false;
  var issuePopup = false;
  var issue = 'Select department';
  var issue_ = 'Select issue';
  int departmentIndex = 0;

  getIssueList() async {
    try {
      setState(() {
        loading = true;
      });
      var url = Uri.https(
        'hgnew.bpm360.net',
        'get_departments_api.php',
      );
      //https://hgnew.bpm360.net/get_departments_api.php
      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "BPM360": {
                "api_key": "e6010eb878872c6b32a40d92518132ed",
                "username": "jsaravanan"
              }
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        Map<String, dynamic> map = json.decode(response.body);
        departmentIssues = [];
        List<dynamic> data = map["Data"];
        for (var element in data) {
          departmentIssues.add(DepartmentIssues.fromJson(element));
        }
      } else {
        setState(() {
          loading = false;
        });
        _showAlert("${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showAlert(Constants.networkIssue);
    }
  }

  Future<List<WeCareLocation>> fetchLocations() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '';
      String url =
          "${Constants.apiHttpsUrl}/Login/getlocationwecare/$userID"; //
      print("URL->$url");
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        final data = json.decode(response.body);
        wecareLocations = [];
        final List<dynamic> locationList = data['locations'];
        for (var element in data['locations']) {
          wecareLocations.add(WeCareLocation.fromJson(element));
        }
        print("wecareLocations--->${wecareLocations.length}");
      /*  for (int i = 0; i < wecareLocations.length; i++) {
          if (wecareLocations[i].weCareFlag == "1") {
            setState(() {
              weCareLocation = wecareLocations[i].locationName;
              selectedWeCareLocation =
              wecareLocations[i];
            });
          }
          break;
        }*/
        return locationList
            .map((location) => WeCareLocation.fromJson(location))
            .toList();
      } else {
        setState(() {
          loading = false;
        });
        _showAlert('Failed to load locations: ${response.statusCode}');
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showAlert(e.toString());
      throw Exception('Failed to fetch locations due to a network issue');
    }
  }

  bool loading = false;

  Future<void> sendData() async {
    setState(() {
      loading = true;
    });
    try {
      SharedPreferences pref = await SharedPreferences.getInstance(); //userCode

      var locationCode = pref.getString('locationCode');
      var user_name = pref.getString('user_name');
      var wecare_userid = pref.getString('wecare_userid');
      var wecare_location_code = pref.getString('wecare_location_code');

      var url = Uri.https(
        'hgnew.bpm360.net',
        '/create_ticket_api.php',
      );

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "BPM360": {
            "api_key": "e6010eb878872c6b32a40d92518132ed",
            "username": selectedWeCareLocation!.weCareUserId
          },
          "data": {
            "subject": subjectCntrl.text.toString(),
            "status": "Open",
            "store_code": selectedWeCareLocation!.weCareLocationCode,
            //"HG_$locationCode"
            "department_name": issue,
            "issue_name": issue_,
            "priority": "P1",
            "description": descitionCntrl.text.toString()
          }
        }),
      );

      var SendingJson = json.encode({
        "BPM360": {
          "api_key": "e6010eb878872c6b32a40d92518132ed",
          "username": selectedWeCareLocation!.weCareUserId
        },
        "data": {
          "subject": subjectCntrl.text.toString(),
          "status": "Open",
          "store_code": selectedWeCareLocation!.weCareLocationCode,
          //"HG_$locationCode"
          "department_name": issue,
          "issue_name": issue_,
          "priority": "P1",
          "description": descitionCntrl.text.toString()
        }
      });
      print(SendingJson);

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });


        TicketResponse temp;
        Map<String, dynamic> map = json.decode(response.body);
        if(map['status']!="Failure"){
          var message = map['Message'];
          Get.snackbar(
            "Alert!",
            "$message",
            snackPosition: SnackPosition.TOP,
          );
          List<dynamic> data = map["Tickets"];
          data.forEach((element) {
            ticketRes.add(TicketResponse.fromJson(element));
          });

          _showSuccessAlert('$message: ${ticketRes[0].caseNumber}'); //Case_Number
          /*{"Result":"Success","Message":"Existing [Ticket No: 172621] Open","Tickets":[{"Date_Entered":"2023-06-05 16:41:21","Subject":"Test","StoreName":"FW_952_Indira Nagar  100 Feet","Case_Number":"172621","Status":"Open","Department_Name":"Test Department","Issue":"","Description":"\n"}]}*/
          // Navigator.pop(context);
        }else{
          setState(() {
            loading = false;
          });
          _showAlert("${map["message"]}\nStoreCode: ${map["provided_store_code"]}");

        }

      } else {
        setState(() {
          loading = false;
        });
        print(response.body);
        print(response.statusCode);

        // _showRetryAlert();
        _showAlert(response.body);
      }
    } catch (e) {
      print(e);

      setState(() {
        loading = false;
      });
      _showAlert(e.toString());
    }
  }

  var caseNu = '';

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

  Future<void> _showRetryAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: const Text(Constants.networkIssue),
// Please retry?'),
          actions: <Widget>[
            CustomElevatedButton(
              text: 'Retry',
              onPressed: () {
                Navigator.of(context).pop();
                // _showRetryAlert();
                // submitCheckList();
                sendData();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    /*if(this.mounted){
      setState(() {
        caseNu = '';
        loading = false;
        popup = false;
        issue = '';
      });
      departmentIssues.clear();
    }*/
  }
}
