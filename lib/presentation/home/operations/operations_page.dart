import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/presentation/home/operations/store_transfer_page.dart';
import 'package:hng_flutter/presentation/home/operations/store_visit/store_visit_page.dart';
import 'package:hng_flutter/presentation/home/operations/support_team_page.dart';
import 'package:hng_flutter/presentation/home/operations/weekoff_apply_page.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/opeartions/audit.dart';
import '../../../helper/StringUtils.dart';
import '../../../provider/store_transfer_provider.dart';
import '../../../provider/week_off_provider.dart';
import 'package:http/http.dart' as http;

import '../../dashboard_page.dart';
import '../../week_off_employee_list_page.dart';
import 'employees_leave_apply_page.dart';

class PageSurvey extends ConsumerStatefulWidget {
  const PageSurvey({super.key});

  @override
  ConsumerState<PageSurvey> createState() => _PageSurveyState();
}

class _PageSurveyState extends ConsumerState<PageSurvey> {
  List<Audit> auditData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child:
                CircularProgressIndicator()) // Show loading indicator while fetching
        : (auditData.isNotEmpty
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: auditData.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (BuildContext context, int index) {
                  final audit = auditData[index];
                  final formattedAuditName =
                      StringUtils.formatWithSpaces(audit.auditName);

                  return ElevatedButton(
                    onPressed: () {
                      if (audit.auditId == 101) {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  EmployeeListScreen(formattedAuditName: formattedAuditName,),
                            // builder: (context) => const WeekOffEmployeeListPage(),
                          ),
                        );
                      } else if (audit.auditId == 102) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              // fullscreenDialog: true,
                              builder: (context) =>
                                  const SupportTeamPage()), //true permanent//false temporary
                        );
                      } else if (audit.auditId == 103) {
                        sendTOStoreTransferPage(false);
                      } else if (audit.auditId == 104) {
                        sendTOStoreTransferPage(true);
                      } else if (audit.auditId == 105) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              // fullscreenDialog: true,
                              builder: (context) => StoreVisitPage(
                                  1)), //true permanent//false temporary
                        );
                      }
                      else if (audit.auditId == 107) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // fullscreenDialog: true,
                              builder: (context) => const WebViewExample()),
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (audit.auditId == 101)
                          Center(
                            child: Image.asset(
                              'assets/weekoff_icon.png',
                              // color: Colors.white,
                              scale: 2,
                            ),
                          )
                        else if (audit.auditId == 102)
                          const Center(
                              child: Icon(
                            Icons.headset_mic_outlined,
                            // color: Colors.white,
                            size: 60,
                          ))
                        else if (audit.auditId == 103)
                          const Center(
                              child: Icon(
                            Icons.transfer_within_a_station,
                            // color: Colors.white,
                            size: 60,
                          ))
                        else if (audit.auditId == 104)
                          const Center(
                              child: Icon(
                            Icons.transfer_within_a_station,
                            // color: Colors.white,
                            size: 60,
                          ))
                        else if (audit.auditId == 105)
                          const Center(
                              child: Icon(
                            Icons.store,
                            // color: Colors.white,
                            size: 60,
                          ))  else if (audit.auditId == 106)
                          const Center(
                              child: Icon(
                            Icons.map_outlined,
                            // color: Colors.white,
                            size: 60,
                          ))  else if (audit.auditId == 107)
                                    const Center(
                                        child: Icon(
                                          Icons.dashboard,
                                          // color: Colors.white,
                                          size: 60,
                                        )),

                        const SizedBox(
                          height: 5,
                        ),
                        Center(
                            child: Text(
                          formattedAuditName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ],
                    ),
                  );
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No data available.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchData, // Retry fetching data
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ));
  }

  Future<void> sendTOStoreTransferPage(bool isPermanant) async {
    final prefs = await SharedPreferences.getInstance();

    var userCode = await prefs.getString('userCode');
    ref.read(employeeCodeProviderStoreTransfer.notifier).state = userCode!;

    Navigator.push(
      context,
      MaterialPageRoute(
          // fullscreenDialog: true,
          builder: (context) =>
              StoreTransferPage(isPermanant)), //true permanent//false temporary
    );
  }

  bool isLoading = true;

  Future<void> fetchData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      var userid = pref.getString("userCode");
      // var userid = '70002';
      final url =
          '${Constants.apiHttpsUrl}/Login/GetOpertaionfiler/$userid'; // Replace with your API endpoint URL

      print("URL OPERATIONS-> $url");
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> parsedResponse = json.decode(response.body);
        setState(() {
          auditData =
              parsedResponse.map((json) => Audit.fromJson(json)).toList();
          isLoading = false; // Data has been fetched, loading is complete
        });
      } else {
        showAlert(context, '${response.statusCode}',
            'An error occurred while fetching data.');
        isLoading = false; // Data has been fetched, loading is complete

        throw Exception('Failed to load data');
      }
    } catch (e) {
      showAlert(context, 'Network Error', Constants.networkIssue);
      isLoading = false; // Data has been fetched, loading is complete

      print(e);
      throw Exception('Failed to load data');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'OK',
            ),
            CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                fetchData();
              },
              text: 'Retry',
            ),
          ],
        );
      },
    );
  }
}
