import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hng_flutter/data/opeartions/employee_weekoff_details.dart';
import 'package:hng_flutter/presentation/home/operations/calendar_page.dart';
import 'package:hng_flutter/submitCheckListScreen.dart';
import 'package:intl/intl.dart';

import '../../../data/employee_leaveapply_list.dart';
import '../../../data/opeartions/weekoff_entity.dart';
import '../../../provider/week_off_provider.dart';
import '../../week_off_apply_page.dart';

class DateSelectionPageWeekOff extends ConsumerStatefulWidget {
  final EmployeeLeaveAplylist employeeCode;

  const DateSelectionPageWeekOff(this.employeeCode, {super.key});

  @override
  ConsumerState<DateSelectionPageWeekOff> createState() =>
      _DateSelectionPageWeekOffState();
}

class _DateSelectionPageWeekOffState
    extends ConsumerState<DateSelectionPageWeekOff> {
  final List<DateTime> dates = [];
  final DateFormat dayFormatter = DateFormat('EE');
  final DateFormat dateFormatter = DateFormat('d MMMM yyyy');
  final List<String> leaveOptions = [
    "Select type",
    "Week Off",
    "Casual Leave",
    "Sick Leave",
    "Loss Of Pay",
  ];
  bool isChecked = false;
  List daySelected_ = [];
  String? dropdownText = '';
  List<String> selectedItemValue = [];
  List<String?> selectedValues = [];
  List<WeekoffEntity> selectedItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final currentDate = DateTime.now();
    for (int i = 0; i < 100; i++) {
      DateTime date = currentDate.add(Duration(days: i));
      dates.add(date);
    }
    selectedValues = List.generate(dates.length, (index) => leaveOptions.first);
    // Listen to the provider and handle disposal
    /*ref.listen(employeeWeekOfDetailsProvider, (previous, next) {
      // You can listen to changes and handle them here
    });*/
  }

  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final employeeWeekOffDetailsAsync =
        ref.watch(employeeWeekOfDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.employeeCode.empCode} - ${widget.employeeCode.empName}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: SafeArea(
          child: employeeWeekOffDetailsAsync.when(
              data: (snapShot) {
                if (snapShot != null && snapShot.statusCode != "201") {
                  final employeeWeekOffDetails = snapShot.weekoffList;
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Date',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Day',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Active Ind',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: employeeWeekOffDetails.length,
                            itemBuilder: (context, index) {
                              final weekOffDetails =
                                  employeeWeekOffDetails[index];
                              final date = dates[index];
                              final formattedDay = dayFormatter.format(date);
                              final formattedDate = dateFormatter.format(date);
                              daySelected_.add(weekOffDetails.activeInd);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      weekOffDetails.date,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      weekOffDetails.day,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Visibility(
                                      visible: false,
                                      child: DropdownButton(
                                        value: selectedValues[index],
                                        items: leaveOptions
                                            .map((String item) =>
                                                DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          selectedItems.add(WeekoffEntity(
                                            empCode:
                                                widget.employeeCode.empCode,
                                            // Replace with the actual empCode value
                                            date: date,
                                            leaveType: value ?? '',
                                            comment: '',
                                          ));
                                          setState(() {
                                            selectedValues[index] = value;
                                            /*      selectedItems.add({
                                    'emp': formattedDate,
                                    'date': formattedDate,
                                    'dropdownValue': value,
                                  });
*/

                                            // selectedItems.a
                                          });
                                        },
                                      ),
                                    ),
                                    Checkbox(
                                      // value:weekOffDetails.activeInd=="Y"?true:false,
                                      value: weekOffDetails.activeInd == "Y"
                                          ? true
                                          : daySelected_.isEmpty
                                              ? false
                                              : daySelected_.contains(index)
                                                  ? true
                                                  : false,
                                      onChanged: (bool? value) {


                                          Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  WeekoffPage(employeeWeekoffDetails: weekOffDetails, employeeWeekOffDetailsList: employeeWeekOffDetails,),),
                                        );

                                      /*  Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CalendarPage(weekOffDetails,
                                                      employeeWeekOffDetails),),
                                        );*/


                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Visibility(
                          visible: false,
                          child: ElevatedButton(
                              onPressed: () {
                                if (selectedItems.isNotEmpty) {
                                  for (int i = 0;
                                      i < selectedItems.length;
                                      i++) {
                                    final selectedItem = selectedItems[i];

                                    if (selectedItem.leaveType !=
                                        "Select type") {
                                      // Handle the condition when "Select type" is found for the dropdownValue
                                      // break; // If you want to stop iterating after finding the first occurrence
                                      break;
                                    } else {
                                      break;
                                    }
                                  }
                                } else {}
                              },
                              child: const Text(
                                'Submit',
                                style: TextStyle(fontSize: 16),
                              )),
                        )
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No details found'),
                  );
                }
              },
              error: (erro, sadfr) {
                // sadfr.toString()
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Something went wrong: $erro',
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(weekOffProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()))),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    // ref.invalidate(employeeWeekOfDetailsProvider);
    super.dispose();
  }

  void checkDateAndUpdateInd(
      List<EmployeeWeekoffDetails> employeeWeekOffDetails,
      EmployeeWeekoffDetails employeeWeekOffDetail)
  {
    List<EmployeeWeekoffDetails> temp = employeeWeekOffDetails;

    for (int i = 0; i < temp.length; i++) {
      if (temp[i].date == employeeWeekOffDetail.date &&
          temp[i].activeInd == "Y") {
        temp.removeAt(i);
        EmployeeWeekoffDetails tempDetais = EmployeeWeekoffDetails(
            empCode: employeeWeekOffDetail.empCode,
            date: employeeWeekOffDetail.date,
            day: employeeWeekOffDetail.day,
            leavetype: "N",
            activeInd: employeeWeekOffDetail.activeInd);

        temp.add(tempDetais);
      }
    }

    print("details");

    for (int j = 0; j < temp.length; j++) {
      final detaisl = temp[j];
      print(detaisl.activeInd);
    }

    /* Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CalendarPage(temp)),
                                        );*/
  }
}
