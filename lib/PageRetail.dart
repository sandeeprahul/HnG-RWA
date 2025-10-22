import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/data/ActiveCheckListModel.dart';
import 'package:hng_flutter/AmOutletSelectScreen.dart';
import 'package:hng_flutter/data/GetActvityTypes.dart';
import 'package:hng_flutter/OutletSelectScreen.dart';
import 'package:hng_flutter/checkListScreen.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';
import 'widgets/task_card.dart';

class PageRetail extends StatefulWidget {
  const PageRetail({Key? key}) : super(key: key);

  @override
  State<PageRetail> createState() => _PageRetailState();
}

bool am = false;
var status_ = false;

class _PageRetailState extends State<PageRetail> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getActiveCheckListData();
    // getData();
  }

  bool loading = false;

  // late final Future myFuture = getAcitiveCheckListData();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ListView.builder(
              itemCount: checkList.isEmpty ? 0 : checkList.length,
              itemBuilder: (BuildContext context, int pos) {
                // return item(pos);
                return TaskCard(
                  title: checkList[pos].auditName,
                  description: checkList[pos].description,
                  imageUrl: checkList[pos].apiUrl ?? '',
                  currentCount: checkList[pos].currentCount,
                  pendingCount: checkList[pos].pendingCount,
                  onTap: () {
                    print(checkList[pos].auditId);
                    if (checkList[pos].auditId == "1" || checkList[pos].auditId == "4") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OutletSelectionScreen(checkList[pos])), //checkListScreen
                      ).then((value) => () {
                        getActiveCheckListData();
                      });
                    }
                    else if (checkList[pos].auditId == "2") {
                      //storeaudit
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OutletSelectionScreen(checkList[pos])),
                      ).then((value) => () {
                        getActiveCheckListData();
                      });
                      /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => checkListScreen(
                  checkList[pos].checklistAssignId, checkList[pos])),
        );*/
                    }
                    else if (checkList[pos].auditId == "3") {
                      //LPD
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OutletSelectionScreen(checkList[pos])), //checkListScreen
                      ).then((value) => () {
                        getActiveCheckListData();
                      });
                    }
                    else if (checkList[pos].auditId == "5") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OutletSelectionScreen(checkList[pos])), //checkListScreen
                      ).then((value) => () {
                        getActiveCheckListData();
                      });
                    }else{
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OutletSelectionScreen(checkList[pos])), //checkListScreen
                      ).then((value) => () {
                        getActiveCheckListData();
                      });
                    }
                  },
                );
              }),
        ),
        Center(
          child: Visibility(
              visible: loading, child: const CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget itemdd(int pos) {
    return InkWell(
      onTap: () {
        print(checkList[pos].auditId);
        if (checkList[pos].auditId == "1" || checkList[pos].auditId == "4") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OutletSelectionScreen(checkList[pos])), //checkListScreen
          ).then((value) => () {
                getActiveCheckListData();
              });
        }
        else if (checkList[pos].auditId == "2") {
          //storeaudit
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OutletSelectionScreen(checkList[pos])),
          ).then((value) => () {
                getActiveCheckListData();
              });
          /* Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => checkListScreen(
                    checkList[pos].checklistAssignId, checkList[pos])),
          );*/
        }
        else if (checkList[pos].auditId == "3") {
          //LPD
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OutletSelectionScreen(checkList[pos])), //checkListScreen
          ).then((value) => () {
                getActiveCheckListData();
              });
        }
        else if (checkList[pos].auditId == "5") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OutletSelectionScreen(checkList[pos])), //checkListScreen
          ).then((value) => () {
                getActiveCheckListData();
              });
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OutletSelectionScreen(checkList[pos])), //checkListScreen
          ).then((value) => () {
            getActiveCheckListData();
          });
        }
      },
      child: Container(
        // color: Colors.white,
        margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
        padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0xFFBDBDBD), blurRadius: 2)],
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        // height: 120,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: checkList[pos].apiUrl == ""
                      ? const Icon(
                          Icons.task,
                          size: 30,
                        )
                      : Image.network(
                          checkList[pos].apiUrl ??
                              'https://health-and-glow-dev.s3.ap-south-1.amazonaws.com/1580384272.png',
                          scale: 2,
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Text(
                              checkList[pos].auditName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 19),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            checkList[pos].description,
                            style: const TextStyle(
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
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              width: double.infinity,
              color: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Current'),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        '${checkList[pos].currentCount}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                    color: Colors.grey[350],
                    width: 1,
                  ),
                  Column(
                    children: [
                      const Text('Pending'),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        '${checkList[pos].pendingCount}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // SizedBox(height: 5,)
          ],
        ),
      ),
    );
  }
  Widget item(int pos) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          print(checkList[pos].auditId);
          if (checkList[pos].auditId == "1" || checkList[pos].auditId == "4") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OutletSelectionScreen(checkList[pos])), //checkListScreen
            ).then((value) => () {
              getActiveCheckListData();
            });
          }
          else if (checkList[pos].auditId == "2") {
            //storeaudit
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OutletSelectionScreen(checkList[pos])),
            ).then((value) => () {
              getActiveCheckListData();
            });
            /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => checkListScreen(
                  checkList[pos].checklistAssignId, checkList[pos])),
        );*/
          }
          else if (checkList[pos].auditId == "3") {
            //LPD
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OutletSelectionScreen(checkList[pos])), //checkListScreen
            ).then((value) => () {
              getActiveCheckListData();
            });
          }
          else if (checkList[pos].auditId == "5") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OutletSelectionScreen(checkList[pos])), //checkListScreen
            ).then((value) => () {
              getActiveCheckListData();
            });
          }else{
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OutletSelectionScreen(checkList[pos])), //checkListScreen
            ).then((value) => () {
              getActiveCheckListData();
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: checkList[pos].apiUrl.isEmpty
                        ? Icon(
                      Icons.task,
                      size: 28,
                      color: Theme.of(context).primaryColor,
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        checkList[pos].apiUrl ??
                            'https://health-and-glow-dev.s3.ap-south-1.amazonaws.com/1580384272.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkList[pos].auditName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          checkList[pos].description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusColumn(
                      context,
                      'Current',
                      checkList[pos].currentCount.toString(),
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey[200],
                  ),
                  Expanded(
                    child: _buildStatusColumn(
                      context,
                      'Pending',
                      checkList[pos].pendingCount.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStatusColumn(BuildContext context, String label, String count) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  List<GetActvityTypes> checkList = [];

  void logoutUser(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Version mismatch occurred!'),
          content: const Text('Please update to latest app version'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cl

                Fluttertoast.showToast(
                    msg: "Please wait while logging out user");
                final prefs = await SharedPreferences.getInstance();
                prefs.clear(); // ose the dialog
                await SystemChannels.platform
                    .invokeMethod('SystemNavigator.pop');
                if (Platform.isIOS) {
                  exit(0);
                } else {
                  await SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop');
                }
              },
              child: const Text('Logout',style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  Future<void> getActiveCheckListData() async {
    try {
      String? isUpdated = "";
      isUpdated = await getVersion();

      if (isUpdated == null) {
      } else if (isUpdated == Constants.appVersionString) {
        setState(() {
          loading = true;
        });

        final prefs = await SharedPreferences.getInstance();
        locationCode = prefs.getString('locationCode') ?? '106';
        var userID = prefs.getString('userCode') ?? '105060';

        // String url = "${Constants.apiHttpsUrl}/Login/GetActvityTypes/70001";
        String url = "${Constants.apiHttpsUrl}/Login/GetActvityTypes/$userID";
        final response =
            await http.get(Uri.parse(url)).timeout(const Duration(seconds: 60));

        print(url);
        checkList = [];

        Iterable l = json.decode(response.body);
        checkList = List<GetActvityTypes>.from(
            l.map((model) => GetActvityTypes.fromJson(model)));

        setState(() {
          loading = false;
        });
      }  else if (isUpdated!=Constants.appVersionString) {
        logoutUser(context);
      }
      else {
        setState(() {
          loading = false;
        });
        _showRetryAlert(isUpdated);
      }
    } catch (e) {
      if (mounted && loading == true) {
        setState(() {
          loading = false;
        });
      }
      _showRetryAlert(Constants.networkIssue);
    }
  }

  Future<void> _showRetryAlert(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(message),
          actions: <Widget>[
            CustomElevatedButton(
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            CustomElevatedButton(
                text: 'Retry',
                onPressed: () {
                  Navigator.of(context).pop();
                  getActiveCheckListData();
                }),
          ],
        );
      },
    );
  }

  Future<void> _showRetryAlertGetVersion() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: const Text(Constants.networkIssue),
// Please retry?',),
          actions: <Widget>[
            CustomElevatedButton(
                text: 'Retry',
                onPressed: () {
                  Navigator.of(context).pop();
                  // getVersion();
                  getActiveCheckListData();
                }),
          ],
        );
      },
    );
  }

  Future<String?> getVersion() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      locationCode = prefs.getString('locationCode') ?? '106';
      var userID = prefs.getString('userCode') ?? '105060';

      String url = "${Constants.apiHttpsUrl}/Login/Checkversion/$userID";
      print(url);

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 300));
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        var respo = jsonDecode(response.body);

        if (respo['statusCode'] == "200") {
          setState(() {
            loading = false;
          });
          if (respo['message'] == Constants.appVersionString) {
            setState(() {
              loading = false;
            });
            return Constants.appVersionString;
          } else {
            setState(() {
              loading = false;
            });
            return "1";
          }
        } else if (respo['statusCode'] == "201") {
          setState(() {
            loading = false;
          });
          _showRetryAlert(respo['message']);
          return respo['message'];
        }
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showRetryAlertGetVersion();
      return "1";
    } finally {
      setState(() {
        loading = false;
      });
    }
    return null;
  }
}
