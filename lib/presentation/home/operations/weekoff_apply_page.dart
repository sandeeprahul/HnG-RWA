import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/presentation/login/login_screen.dart';
import 'package:hng_flutter/repository/week_off_respository.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:hng_flutter/widgets/employee_details_list_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../data/employee_leaveapply_list.dart';
import '../../../provider/week_off_provider.dart';

class WeekOffApplyPage extends ConsumerStatefulWidget {
  const WeekOffApplyPage({Key? key}) : super(key: key);

  @override
  ConsumerState<WeekOffApplyPage> createState() => _WeekOffApplyPageState();
}

class _WeekOffApplyPageState extends ConsumerState<WeekOffApplyPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmployeeList();
  }

  bool loading = false;
  bool showDays = false;

  @override
  Widget build(BuildContext context) {
    final employeeListAsync = ref.watch(weekOffProvider);

    return Scaffold(
        body: SafeArea(
            child: employeeListAsync.when(
                data: (snapshot) {
                  if (snapshot != null && snapshot.isNotEmpty) {
                    final employeeList = snapshot;
                    return CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          collapsedHeight: 200,
                          pinned: true,
                          // title: Text('Week-Off apply'),
                          backgroundColor: Colors.orange,

                          centerTitle: false,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Hero(
                              tag: 'weekoff',
                              child: Image.asset(
                                'assets/weekoff_icon.png',
                                color: Colors.white,
                              ),
                            ),
                            collapseMode: CollapseMode.parallax,
                            titlePadding: const EdgeInsetsDirectional.only(
                              start: 20,
                              bottom: 16.0,
                              // top: 10
                            ),
                            title: const Text(
                              'Week-Off apply',
                            ),
                          ),
                        ),
                        SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                          final sno = index + 1;
                          // final employeeList = snapshot.data;
                          final employeeDetails = employeeList[index];
                          return EmployeeDetailsListWidget(
                              employeeDetails, sno);
                        }, childCount: employeeList.length)),
                      ],
                    );
                  } else {
                    return CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          collapsedHeight: 200,
                          pinned: true,
                          // title: Text('Week-Off apply'),
                          backgroundColor: Colors.orange,

                          centerTitle: false,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Hero(
                              tag: 'weekoff',

                              child: Image.asset(
                                'assets/weekoff_icon.png',
                                color: Colors.white,
                              ),
                            ),
                            collapseMode: CollapseMode.parallax,
                            titlePadding: const EdgeInsetsDirectional.only(
                              start: 20,
                              bottom: 16.0,
                              // top: 10
                            ),
                            title: const Text(
                              'Week-Off apply',
                            ),
                          ),
                        ),
                        SliverList(
                            delegate: SliverChildListDelegate([
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Employees list is empty',

                              style: TextStyle(
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ]))
                      ],
                    );
                  }
                },
                error: (Object error, StackTrace stackTrace) {
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Text(Constants.networkIssue,textAlign: TextAlign.center,style: Theme.of(context).textTheme.titleMedium,),
                        const SizedBox(height: 8,),

                        CustomElevatedButton(text: 'Retry', onPressed: (){                            ref.refresh(weekOffProvider);
                        }),

                      ],
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()))));
  }

  List<EmployeeLeaveAplylist> employeeDetails = [];

  void getEmployeeList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '';

      String url =
          "${Constants.apiHttpsUrl}/Login/WeekoffEmployees/2009459";

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      print(url);

      var responseData = json.decode(response.body);
      print(url);
      print(responseData);

      Map<String, dynamic> map = json.decode(response.body);
      final statusCode = map['statusCode'];
      if (statusCode == "200") {
        List<dynamic> data = map['employeelist'];

        List<EmployeeLeaveAplylist> employeeDetailsTemp = [];

        data.forEach((element) {
          employeeDetailsTemp.add(EmployeeLeaveAplylist.fromJson(element));
        });

        // yield employeeDetails;
      }
    } catch (e) {
      print("Error:$e");

      // yield null;
    }
    // return null;
  }

  Future<void> _showRetryAlert(String msg) async {
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
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 35, right: 35, top: 15, bottom: 15),
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            InkWell(
              onTap: () {
                // Navigator.of(context,rootNavigator: true).pop();
                Navigator.pop(contextt);
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 35, right: 35, top: 15, bottom: 15),
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        );
      },
    );
  }

  applyWeekoff() async {
    setState(() {
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();

     var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        '/RWASTAFFMOVEMENT_TEST/api/Login/weekoff',
    );

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          [
            {"empCode": "2009459", "date": "2023-07-10", "leaveType": "weekoff"}
          ],
        ),
      );

      if (response.statusCode == 200) {
        var respo = jsonDecode(response.body);
        print(respo);

        // "statusCode": "201",
        if (respo['statusCode'] == "200") {
          setState(() {
            loading = false;
          });
          _showAlert(respo['message']);
        } else if (respo['statusCode'] == "201") {
          setState(() {
            loading = false;
          });
          _showAlert(respo['message']);
        }
      } else if (response.statusCode == 201) {
        setState(() {
          loading = false;
        });
        _showAlert("Something went wrong");
      } else {
        setState(() {
          loading = false;
        });
        _showAlert("Something went wrong");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showAlert("Something went wrong");
    }
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

  @override
  void dispose() {
    ref.invalidate(weekOffProvider);
    super.dispose();
  }
}
