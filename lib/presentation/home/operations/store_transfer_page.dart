import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hng_flutter/presentation/login/login_screen.dart';
import 'package:hng_flutter/repository/week_off_respository.dart';
import 'package:hng_flutter/widgets/employee_details_list_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../common/constants.dart';
import '../../../data/employee_leaveapply_list.dart';
import '../../../data/opeartions/employee_list_transfer.dart';
import '../../../provider/store_transfer_provider.dart';
import '../../../provider/week_off_provider.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/employee_transfer_details_widget.dart';

class StoreTransferPage extends ConsumerStatefulWidget {
  final bool isPermanent;

  const StoreTransferPage(this.isPermanent, {super.key});

  @override
  ConsumerState<StoreTransferPage> createState() => _StoreTransferPageState();
}

class _StoreTransferPageState extends ConsumerState<StoreTransferPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getEmployeeList();
  }

  bool loading = false;
  bool showDays = false;

  @override
  Widget build(BuildContext context) {
    final storeTransferData = ref.watch(storeTransferProvider);

    return Scaffold(
        body: SafeArea(
            child: storeTransferData.when(
                data: (snapshot) {
                  if (snapshot != null && snapshot.statusCode != "201") {
                    final employeeList = snapshot;
                    if (employeeList.employeelist.isNotEmpty) {
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
                                  tag: widget.isPermanent
                                      ? 'transfer'
                                      : 'transfer2',
                                  child: const Icon(
                                    Icons.transfer_within_a_station,
                                    color: Colors.white,
                                    size: 56,
                                  )),
                              collapseMode: CollapseMode.parallax,
                              titlePadding: const EdgeInsetsDirectional.only(
                                start: 20,
                                bottom: 16.0,
                                // top: 10
                              ),
                              title: Text(
                                widget.isPermanent
                                    ? 'Permanent Store Transfer'
                                    : 'Temporary Store Transfer',
                              ),
                            ),
                          ),
                          SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                            final sno = index + 1;
                            // final employeeList = snapshot.data;
                            final employeeDetails =
                                employeeList.employeelist[index];
                            return EmployeeTransferDetailsListWidget(
                                    employeeDetails,
                                    employeeList,
                                    widget
                                        .isPermanent) /*EmployeeDetailsListWidget(
                                  employeeDetails.empCode, sno)*/
                                ;
                          }, childCount: employeeList.employeelist.length)),
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
                                  tag: widget.isPermanent
                                      ? 'transfer'
                                      : 'transfer2',
                                  child: const Icon(
                                    Icons.transfer_within_a_station,
                                    color: Colors.white,
                                    size: 56,
                                  )),
                              collapseMode: CollapseMode.parallax,
                              titlePadding: const EdgeInsetsDirectional.only(
                                start: 20,
                                bottom: 16.0,
                                // top: 10
                              ),
                              title: Text(
                                widget.isPermanent
                                    ? 'Permanent Store Transfer'
                                    : 'Temporary Store Transfer',
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
                                tag: widget.isPermanent
                                    ? 'transfer'
                                    : 'transfer2',
                                child: const Icon(
                                  Icons.transfer_within_a_station,
                                  color: Colors.white,
                                  size: 56,
                                )),
                            collapseMode: CollapseMode.parallax,
                            titlePadding: const EdgeInsetsDirectional.only(
                              start: 20,
                              bottom: 16.0,
                              // top: 10
                            ),
                            title: const Text(
                              'Temporary Store Transfer',
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
                        Text(
                          Constants.networkIssue,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        CustomElevatedButton(
                            text: 'Retry',
                            onPressed: () {
                              ref.refresh(storeTransferProvider);
                            }),
                      ],
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()))));
  }

  List<Employeelist> employeeDetails = [];

  Future<void> _showRetryAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(msg),
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

  @override
  void dispose() {
    ref.invalidate(storeTransferProvider);
    super.dispose();
  }
}
