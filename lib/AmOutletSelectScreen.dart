import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hng_flutter/checkListItemScreen_Lpd.dart';
import 'package:hng_flutter/checkListScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'common/constants.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/GetActvityTypes.dart';
import 'data/Locations.dart';

class AmOutletSelectionScreen extends StatefulWidget {
  // const AmOutletSelectionScreen({Key? key}) : super(key: key);

 final GetActvityTypes checkList;

  // int checkassignId;
  // ActiveCheckList activeCheckList;

  AmOutletSelectionScreen(this.checkList);

  @override
  State<AmOutletSelectionScreen> createState() =>
      _AmOutletSelectionScreenState(this.checkList);
}

bool am = true;

class _AmOutletSelectionScreenState extends State<AmOutletSelectionScreen> {
  // int checkassignId;
  // ActiveCheckList activeCheckList;
  GetActvityTypes checkList;

  _AmOutletSelectionScreenState(this.checkList);

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
                          'LPD',
                          style: TextStyle(color: Colors.black),
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
                          contentPadding: EdgeInsets.all(0),
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
                            /*Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  checkListItemScreen_Lpd(2)),
                                        );*/
                          },
                          child: Container(
                            // color: Colors.white,
                            margin: const EdgeInsets.only(
                                left: 10, top: 10, right: 10),
                            padding: const EdgeInsets.only(
                                left: 10,
                                top: 20,
                                right: 10,
                                bottom: 15),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFFBDBDBD),
                                    blurRadius: 2)
                              ],
                              borderRadius:
                              BorderRadius.all(Radius.circular(5)),
                            ),
                            // height: 125,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt_outlined,
                                      size: 40,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15),
                                        child: Column(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment:
                                              Alignment.topLeft,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .only(
                                                    top: 2,
                                                    bottom: 2),
                                                child: Text(
                                                  locationsList_Filter[
                                                  pos]
                                                      .locationName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: 19),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment:
                                              Alignment.topLeft,
                                              child: Text(
                                                locationsList_Filter[
                                                pos]
                                                    .locationCode,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[400],
                                    )
                                  ],
                                ),
                                Container(
                                  height: 1,
                                  margin: EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 2, top: 2),
                                          child: Text(
                                            'Current',
                                            style: TextStyle(
                                                color:
                                                Color(0xFF757575)),
                                          ),
                                        ),
                                        Text(
                                          '3',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 25,
                                      width: 1,
                                      color: Colors.grey[300],
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              bottom: 2, top: 2),
                                          child: Text(
                                            'Pending',
                                            style: TextStyle(
                                                color:
                                                Color(0xFF757575)),
                                          ),
                                        ),
                                        Text(
                                          '3',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      })
                      : ListView.builder(
                      itemCount: locationsList.length,
                      itemBuilder: (context, pos) {
                        return InkWell(
                          onTap: () {
                            /* Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  checkListScreen(2)),
                                        );*/
                          },
                          child: Container(
                            // color: Colors.white,
                            margin: const EdgeInsets.only(
                                left: 10, top: 10, right: 10),
                            padding: const EdgeInsets.only(
                                left: 10,
                                top: 20,
                                right: 10,
                                bottom: 15),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFFBDBDBD),
                                    blurRadius: 2)
                              ],
                              borderRadius:
                              BorderRadius.all(Radius.circular(5)),
                            ),
                            // height: 125,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt_outlined,
                                      size: 40,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15),
                                        child: Column(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment:
                                              Alignment.topLeft,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .only(
                                                    top: 2,
                                                    bottom: 2),
                                                child: Text(
                                                  locationsList[pos]
                                                      .locationName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: 19),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment:
                                              Alignment.topLeft,
                                              child: Text(
                                                locationsList[pos]
                                                    .locationCode,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[400],
                                    )
                                  ],
                                ),
                                Container(
                                  height: 1,
                                  margin: EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 2, top: 2),
                                          child: Text(
                                            'Current',
                                            style: TextStyle(
                                                color:
                                                Color(0xFF757575)),
                                          ),
                                        ),
                                        Text(
                                          '3',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 25,
                                      width: 1,
                                      color: Colors.grey[300],
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              bottom: 2, top: 2),
                                          child: Text(
                                            'Pending',
                                            style: TextStyle(
                                                color:
                                                Color(0xFF757575)),
                                          ),
                                        ),
                                        Text(
                                          '3',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
            Visibility(
                visible: loading,
                child: Container(
                  color: Color(0x80000000),
                  child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.all(20),
                          height: 115,
                          width: 150,
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
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

  Future<List<Locations>> getLocationsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var locationCode = prefs.getString('locationCode') ?? '106';
      var userID = prefs.getString('userCode') ?? '105060';

      String url =
          "${Constants.apiHttpsUrl}/Login/GetLocationApplicable/$userID/${widget.checkList.auditId}";

      print(url);
      final response = await http.get(Uri.parse(url));
      print(response.body);

      var responseData = json.decode(response.body);

      //Creating a list to store input data;
      locationsList = [];

      Iterable l = json.decode(response.body);

      locationsList =
          List<Locations>.from(l.map((model) => Locations.fromJson(model)));

      print("locationsList.lengthfgffffffff");
      print(locationsList.length);
      // locationsList_Filter = locationsList;

      return locationsList;
    } catch (e) {
      locationsList = [];
      _showRetryAlert();

      return locationsList;
    }
  }

  Future<void> _showRetryAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text('Network issue\nPlease retry?'),
          actions: <Widget>[
/*
            Container(
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
            ),
*/
            Container(
              padding: EdgeInsets.all(15),

              decoration:
              const BoxDecoration(color: CupertinoColors.activeBlue),
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
    /*else {
      */ /*results = locationsList
          .where((user) =>
              user.locationCode.contains(enteredKeyword))
          .toList();*/ /*



      // we use the toLowerCase() method to make it case-insensitive
    }*/
    /*locationsList.forEach((element) {
      if (element.locationCode.contains(enteredKeyword)) {
        locationsList_Filter.add(element);
      }
    });*/

    List<Locations> temp = [];
    locationsList.forEach((userDetail) {
      if (userDetail.locationCode.contains(enteredKeyword))
        temp.add(userDetail);
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
