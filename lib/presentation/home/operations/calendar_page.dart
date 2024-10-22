import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hng_flutter/data/employee_leaveapply_list.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../common/constants.dart';
import '../../../data/opeartions/employee_weekoff_details.dart';
import '../../../data/opeartions/employee_weekoff_entity.dart';
import '../../../data/opeartions/weekoff_entity.dart';
import '../../../provider/week_off_provider.dart';
import '../../../repository/week_off_respository.dart';

class CalendarPage extends ConsumerStatefulWidget {
  final EmployeeWeekoffDetails employeeWeekoffDetails;
  final List<EmployeeWeekoffDetails> employeeWeekOffDetailsList;

  const CalendarPage(
      this.employeeWeekoffDetails, this.employeeWeekOffDetailsList,
      {super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

TextEditingController leaveTypeTextController = TextEditingController();

class _CalendarPageState extends ConsumerState<CalendarPage> {
  // final List<DateTime> _selectedDates = [];
  final List<WeekoffEntity> _selectedDates = [];

  Map<DateTime, List<Color>> customColorsMap = {};

  void populateCustomColorsMap(List<EmployeeWeekoffDetails> list) {
    customColorsMap.clear();

    for (var item in list) {
      try {
        String dateString = item.date;
        List<String> dateParts = dateString.split('-');

        if (dateParts.length != 3) {
          // Invalid date format
          print("Invalid date format for: $dateString");
          continue; // Skip this entry
        }

        int day = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int year = int.parse(dateParts[2]);

        // Ensure the date is valid and handle invalid date cases
        DateTime date = DateTime(year, month, day);

        // Add the date to the customColorsMap with red color
        customColorsMap[date] = [Colors.red];
      } catch (e) {
        // Handle any parsing or date errors
        print("Error processing date for: ${item.date} - $e");
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    populateCustomColorsMap(widget.employeeWeekOffDetailsList);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.employeeWeekoffDetails.date);

    String dateString = widget.employeeWeekoffDetails.date;
    List<String> dateParts = dateString.split('-');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    const CalendarFormat calendarFormat = CalendarFormat.month;
    final DateTime focusedDay = DateTime(year, month, day);
    final DateTime firstDay = DateTime(year, month, day);
    final DateTime lastDay = firstDay.add(const Duration(days: 7));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.employeeWeekoffDetails.empCode} - Apply leave',
          //${widget.employeeWeekoffDetails.}
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!showProgress)
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Select Date to apply week-off',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                TableCalendar(
                  selectedDayPredicate: _isDaySelected,
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(color: Colors.white),
                  ),
                  onDaySelected: _onDaySelected,
                  focusedDay: focusedDay,
                  firstDay: firstDay,
                  lastDay: lastDay,
                  eventLoader: (date) {
                    // Return a list of events for the specific dates you want to highlight
                    if (widget.employeeWeekOffDetailsList.contains(date)) {
                      return [date];
                    }
                    return [];
                  },
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, _) {
                      if (customColorsMap.containsKey(date)) {
                        return Container(
                          decoration: BoxDecoration(
                            color: customColorsMap[date]![0],
                            // Use the first color in the list
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Fallback to the default selected style
                        return null;
                      }
                    },
                  ),
                ),
                Visibility(
                  visible: false,
                  child: Expanded(
                    child: ListView.builder(
                        itemCount: _selectedDates.length,
                        itemBuilder: (context, index) {
                          final details = _selectedDates[index];
                          final dayName = DateFormat('EEE').format(
                              details.date); // Get day name (e.g., "Mon")
                          final monthName =
                              DateFormat('MMM').format(details.date);
                          return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 10),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                  '${index + 1}.$dayName ${details.date.day} $monthName ${details.date.year} - ${details.leaveType} '));
                        }),
                  ),
                ),
              ],
            )
          else
            const Visibility(
                child: Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(),
              ),
            )),

/*          Visibility(
            visible: false,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    if (_selectedDates.isEmpty) {
                      Fluttertoast.showToast(
                          msg: 'Please select date and submit');
                    } else {
                      applyWeekOff_();
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('SUBMIT'),
                    ],
                  )),
            ),
          )*/
        ],
      ),
    );
  }

  void applyWeekOff_() async {
    try {
      // Call the applyWeekoff method in your repository and pass _selectedDates

      if (widget.employeeWeekOffDetailsList
          .contains(widget.employeeWeekoffDetails)) {
        print(widget.employeeWeekOffDetailsList.length);

        List<EmployeeWeekoffDetails> temp = widget.employeeWeekOffDetailsList;
        print(
            '${widget.employeeWeekoffDetails.activeInd} ${widget.employeeWeekoffDetails.leavetype}');
        temp.remove(widget.employeeWeekoffDetails);
        print(widget.employeeWeekOffDetailsList.length);
        temp.add(EmployeeWeekoffDetails(
            empCode: _selectedDates[0].empCode,
            date:
                '${_selectedDates[0].date.day}-${_selectedDates[0].date.month}-${_selectedDates[0].date.year} ',
            day: widget.employeeWeekoffDetails.day,
            leavetype: leaveTypeTextController.text.toString(),
            activeInd: "Y"));

        var params = [];
        for (int i = 0; i < temp.length; i++) {
          final detais = temp[i];
          params.add({
            "empCode": widget.employeeWeekoffDetails.empCode,
            "date": detais.date, // Convert DateTime to String format
            "leaveType": detais.leavetype,
            "activeInd": detais.activeInd,
          });
        }
        if (kDebugMode) {
          print("weekoff $params");
        }

        applyWeekOff(widget.employeeWeekoffDetails.empCode, params);
      }

      // If the operation is successful, you can perform any additional actions here
      Fluttertoast.showToast(msg: 'Leave apply success');
      _selectedDates.clear();

      Navigator.pop(context);
    } catch (e) {
      _selectedDates.clear();
      // Handle any errors that occurred during the API call
      Fluttertoast.showToast(
        msg: 'Network issue\nPlease submit again',
      );
    }
  }

  Future<void> applyWeekOff(String empCode, List<dynamic> params) async {
    setState(() {
      showProgress = true;
    });
    var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWASTAFFMOVEMENT_TEST/api/Login/weekoff',
    );

    try {
      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(params),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          showProgress = true;
        });
        var respo = jsonDecode(response.body);
        print(respo);

        // "statusCode": "201",
        if (respo['statusCode'] == "200") {
          print(respo['statusCode']);
          print(respo['message']);
        } else if (respo['statusCode'] == "201") {
          print(respo['statusCode']);
          print(respo['message']);
        }
      } else if (response.statusCode == 201) {
        setState(() {
          showProgress = true;
        });
        print(response.statusCode);
      } else {
        setState(() {
          showProgress = false;
        });
        print(response.statusCode);
      }
    } catch (e) {
      setState(() {
        showProgress = false;
      });
      print(e);
      rethrow;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _selectedDates.clear();

    super.dispose();
  }

  bool showProgress = false;

  List<String> selectedDate_ = [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final selectedDayValue = selectedDay.day;
    print(" selectedDayValue $selectedDay");
    // String formattedDate = DateFormat('EEE d\'\'th \' MMMM y').format(selectedDay);
    // String formattedDate = DateFormat('EEE d\'\'th \' MMMM y','en_US').format(selectedDay);
    // String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
    String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDay);

    print(" formated date -> $formattedDate");

    selectedDate_.add(formattedDate);
    _selectedDates.add(
      WeekoffEntity(
        empCode: 'Employee Code',
        date: selectedDay,
        leaveType: "Week-Off",
        // Initialize with an empty value or provide a default value
        comment:
            "Y", // Initialize with an empty value or provide a default value
      ),
    );

    final isAlreadySelected =
        _selectedDates.any((date) => isSameDay(date.date, selectedDay));

    /* setState(() {
      if (_selectedDates.contains(selectedDay)) {
        _selectedDates.remove(selectedDay);
      } else {
        _selectedDates.add(selectedDay.day );
      }
    });*/
    final selectedDate = ref.read(selectedDatesProvider).firstWhere(
          (date) => date.date.isAtSameMomentAs(selectedDay),
          orElse: () => WeekoffEntity(
            empCode: widget.employeeWeekoffDetails.empCode,
            date: selectedDay,
            leaveType: 'Leave Type',
            comment: widget.employeeWeekoffDetails.activeInd,
          ),
        );

    showDialog(
      context: context,
      builder: (contextt) => AlertDialog(
        title: const Text("Are you sure?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You selected $formattedDate  for Week-Off'),
            const SizedBox(height: 10),
            /*    TextField(
              onChanged: (value) {
                selectedDate.comment = value;
              },
              decoration: const InputDecoration(hintText: "Enter comment..."),
            ),*/
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(contextt).pop();

              _selectedDates
                  .removeWhere((date) => isSameDay(date.date, selectedDay));

              ref
                  .read(selectedDatesProvider.notifier)
                  .removeSelectedDate(selectedDay);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(contextt).pop();
              setState(() {
                /* _selectedDates.add(
                        WeekoffEntity(
                          empCode: 'Employee Code',
                          date: selectedDay,
                          leaveType: selectedDate.leaveType,
                          // Initialize with an empty value or provide a default value
                          comment:
                          "Y", // Initialize with an empty value or provide a default value
                        ),
                      );*/
              });
              ref
                  .read(selectedDatesProvider.notifier)
                  .addSelectedDate(selectedDate);
              print("_selectedDates.length${_selectedDates.length}");
              print("_selectedDates dat${_selectedDates[0].date}");
              print("selectedDate_.length${selectedDate_[0]}");

              /*   for (int i = 0; i <= _selectedDates.length; i++) {
                      print("Selected Dates${_selectedDates[i].leaveType}");
                    }*/
              applyWeekOff_();
            },
            child: const Text("Confirm?"),
          ),
        ],
      ),
    );
  }

  bool _isDaySelected(DateTime day) {
    return _selectedDates.any((date) => isSameDay(day, date.date));
  }
}
