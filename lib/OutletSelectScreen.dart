import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hng_flutter/checkListScreen_lpd.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/checkListScreen.dart';
import 'package:hng_flutter/widgets/task_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'common/constants.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/Locations.dart';
import 'applicableScreen.dart';


///1= DILO,
///2= STORE AUDIT,
///3= LPD Audit,
///4= DILO EMPLOYEE
///5 = AM STORE AUDIT
///6= Virtual merchPage
class OutletSelectionScreen extends StatefulWidget {
  final GetActvityTypes checkList;

  const OutletSelectionScreen(this.checkList, {super.key});

  @override
  State<OutletSelectionScreen> createState() =>
      _OutletSelectionScreenState();
}

bool am = true;

class _OutletSelectionScreenState extends State<OutletSelectionScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationsData();
  }

  bool loading = false;
  TextEditingController searchController = TextEditingController();

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
                          widget.checkList.auditName,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => _runFilter(value),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(0),
                          isDense: true,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          filled: true,
                          hintStyle:
                              TextStyle(color: Colors.grey[800], fontSize: 13),
                          hintText: "Search by Outlet",
                          fillColor: Colors.white70),
                    ),
                  ),
                ),
                Expanded(
                  child: searchController.text.isNotEmpty ||
                          locationsList_Filter.isNotEmpty
                      ? ListView.builder(
                          itemCount: locationsList_Filter.length,
                          itemBuilder: (context, pos) {
                            return InkWell(
                              onTap: () {
                                print(widget.checkList.auditId);

                                if (widget.checkList.auditId == "3" ||
                                    widget.checkList.auditId == "5") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => applicableScreen(
                                              1,
                                              widget.checkList,
                                              locationsList_Filter[pos]
                                                  .locationCode,
                                            )),
                                  );
                                } else if (widget.checkList.auditId == "2" ||
                                    widget.checkList.auditId == "6") {
                                  //storeAudit//||widget.checkList.auditId == "4"
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => applicableScreen(
                                            1,
                                            widget.checkList,
                                            locationsList_Filter[pos]
                                                .locationCode)),
                                  );
                                } else if (widget.checkList.auditId == "4") {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => checkListScreen(
                                            1,
                                            widget.checkList,
                                            locationsList_Filter[pos]
                                                .locationCode)),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => checkListScreen(
                                            1,
                                            widget.checkList,
                                            locationsList_Filter[pos]
                                                .locationCode)),
                                  );
                                }
                              },
                              child: TaskCard(
                                  title: locationsList_Filter[pos].locationName,
                                  description: locationsList_Filter[pos].locationCode,
                                  currentCount: locationsList_Filter[pos].currentCount??0,
                                  pendingCount: locationsList_Filter[pos].pendingCount??0),
                            );
                          })
                      : ListView.builder(
                          itemCount: locationsList.length,
                          itemBuilder: (context, pos) {
                            return InkWell(
                              onTap: () {
                                print(widget.checkList.auditId);
                                if (widget.checkList.auditId == "3" ||
                                    widget.checkList.auditId == "5") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => applicableScreen(
                                              1,
                                              widget.checkList,
                                              locationsList[pos].locationCode,
                                            )),
                                  );
                                } else if (widget.checkList.auditId == "2" ||
                                    widget.checkList.auditId == "6") {
                                  //storeAudit
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => applicableScreen(
                                            1,
                                            widget.checkList,
                                            locationsList[pos].locationCode)),
                                  );
                                } else if (widget.checkList.auditId == "4") {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            checkListScreen_lpd(
                                                1,
                                                widget.checkList,
                                                locationsList[pos]
                                                    .locationCode)),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => checkListScreen(
                                            1,
                                            widget.checkList,
                                            locationsList[pos].locationCode)),
                                  );
                                }
                              },
                              child: TaskCard(
                                  title: locationsList[pos].locationName,
                                  description: locationsList[pos].locationCode,
                                  currentCount: locationsList[pos].currentCount??0,
                                  pendingCount: locationsList[pos].pendingCount??0),
                            );
                          }),
                ),
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
    );
  }

  List<Locations> locationsList = [];
  List<Locations> locationsList_Filter = [];

  Future<void> getLocationsData() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var locationCode = prefs.getString('locationCode') ?? '106';
      var userID = prefs.getString('userCode') ?? '105060';
      // String url ="${Constants.apiHttpsUrl}/Login/GetLocationApplicable/70001/${widget.checkList.auditId}";
      String url =
          "${Constants.apiHttpsUrl}/Login/GetLocationApplicable/$userID/${widget.checkList.auditId}";

      print(url);
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
      print(response.body);

      var responseData = json.decode(response.body);

      //Creating a list to store input data;
      locationsList = [];

      Iterable l = json.decode(response.body);
      locationsList =
          List<Locations>.from(l.map((model) => Locations.fromJson(model)));
      print("locationsList.length");
      print(locationsList.length);
      // locationsList_Filter = locationsList;

      // return locationsList;
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
          content: Text('Network issue\nPlease retry'),
// Please retry?'),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(5)),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white))),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(5)),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    getLocationsData();
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

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    print('enterKywo');
    print(enteredKeyword);
    // locationsList_Filter = [];
    locationsList_Filter.clear();
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = locationsList;
      setState(() {});
      return;
    }

    List<Locations> temp = [];
    locationsList.forEach((userDetail) {
      if (userDetail.locationCode.contains(enteredKeyword) ||
          userDetail.locationName
              .toString()
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase())) temp.add(userDetail);
    });

    // Refresh the UI
    setState(() {
      locationsList_Filter = temp;
    });
    print('enterKywoLength');
    print(locationsList_Filter.length);
    // print(locationsList_Filter[0].locationName);
  }
}
