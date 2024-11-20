// weekoff_page.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import '../data/opeartions/employee_weekoff_details.dart';
import '../data/opeartions/weekoff_entity.dart';
import '../widgets/selected_dates_list_widget.dart';

class WeekoffPage extends StatefulWidget {
  final EmployeeWeekoffDetails employeeWeekoffDetails;
  final List<EmployeeWeekoffDetails> employeeWeekOffDetailsList;

  const WeekoffPage({
    super.key,
    required this.employeeWeekoffDetails,
    required this.employeeWeekOffDetailsList,
  });

  @override
  _WeekoffPageState createState() => _WeekoffPageState();
}

class _WeekoffPageState extends State<WeekoffPage> {
  List<String> selectedDate_ = [];
  List<WeekoffEntity> _selectedDates = [];
  Map<DateTime, List<Color>> customColorsMap = {};
  bool showProgress = false;

  @override
  void initState() {
    super.initState();
    populateCustomColorsMap(widget.employeeWeekOffDetailsList);
  }

  void populateCustomColorsMap(List<EmployeeWeekoffDetails> list) {
    customColorsMap.clear();
    for (var item in list) {
      _addDateToCustomColors(item.date);
    }
  }

  void _addDateToCustomColors(String dateString) {
    try {
      List<String> dateParts = dateString.split('-');
      if (dateParts.length != 3) return; // Skip invalid date format

      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);

      DateTime date = DateTime(year, month, day);
      customColorsMap[date] = [Colors.red];
    } catch (e) {
      print("Error processing date for: $dateString - $e");
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
    DateTime dateTime = DateTime.parse(formattedDate);

    if (_isDateAlreadySelected(selectedDay)) {
      _removeDate(selectedDay);
    } else {
      _confirmDateSelection(selectedDay, formattedDate, dateTime);
    }
  }

  bool _isDateAlreadySelected(DateTime day) {
    return _selectedDates.any((date) => isSameDay(day, date.date));
  }

  void _removeDate(DateTime selectedDay) {
    setState(() {
      _selectedDates.removeWhere((date) => isSameDay(date.date, selectedDay));
      selectedDate_.remove(DateFormat('yyyy-MM-dd').format(selectedDay));
    });
  }

  void _confirmDateSelection(
      DateTime selectedDay, String formattedDate, DateTime dateTime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: Text('You selected $formattedDate for Week-Off'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addSelectedDate(formattedDate, dateTime);
              _onDateConfirmed(dateTime);
              applyWeekOff_(); // Call applyWeekOff_() here
// Call your function here
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _onDateConfirmed(DateTime dateTime) {
    // Implement the desired functionality here
    print("Date confirmed: ${dateTime.toIso8601String()}");

    // You can also trigger any further actions or API calls here
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

        // Update the date format to YYYY-MM-DD
        temp.add(EmployeeWeekoffDetails(
          empCode: _selectedDates[0].empCode,
          date:
              '${_selectedDates[0].date.year}-${_selectedDates[0].date.month.toString().padLeft(2, '0')}-${_selectedDates[0].date.day.toString().padLeft(2, '0')}',
          day: widget.employeeWeekoffDetails.day,
          leavetype: "",
          activeInd: "Y",
        ));

        var params = [];
        for (int i = 0; i < temp.length; i++) {
          final details = temp[i];

          // Ensure the date is always formatted as YYYY-MM-DD
          String formattedDate =
              details.date; // Assuming the date is already corrected above
          params.add({
            "empCode": details.empCode,
            "date": formattedDate,
            "leaveType": details.leavetype,
            "activeInd": details.activeInd,
          });
        }

        if (kDebugMode) {
          print("weekoff $params");
        }

        applyWeekOff(widget.employeeWeekoffDetails.empCode, params);
      }

      Get.snackbar("Success", 'Leave apply success',
          colorText: Colors.white,
          backgroundColor: Colors.black,
          snackPosition: SnackPosition.BOTTOM);
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
      showProgress = true; // Show progress when starting the API call
    });

    var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/Login/weekoff',
    );

    try {
      // Make the API call
      var response = await http
          .post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(params),
      )
          .timeout(const Duration(seconds: 5));

      // Check the response status
      if (response.statusCode == 200) {
        var respo = jsonDecode(response.body);
        print(respo);

        // Check status code in response body
        if (respo['statusCode'] == "200" || respo['statusCode'] == "201") {
          print('Status Code: ${respo['statusCode']}');
          print('Message: ${respo['message']}');

          // Success handling
          Get.snackbar(
            "Success",
            'Leave applied successfully',
            colorText: Colors.white,
            backgroundColor: Colors.black,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          print('Unexpected status code: ${respo['statusCode']}');
        }
      } else {
        // Handle HTTP error responses
        print('HTTP Error: ${response.statusCode}');
        Fluttertoast.showToast(msg: 'Failed to apply leave. Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
      Fluttertoast.showToast(msg: 'Network issue\nPlease submit again');
    } finally {
      // Ensure progress indicator is hidden after the call
      setState(() {
        showProgress = false;
      });
    }
  }

  void _addSelectedDate(String formattedDate, DateTime dateTime) {
    setState(() {
      _selectedDates.add(
        WeekoffEntity(
          empCode: widget.employeeWeekoffDetails.empCode,
          date: dateTime,
          leaveType: "Week-Off",
          comment: "Y",
        ),
      );
      selectedDate_.add(formattedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    String dateString = widget.employeeWeekoffDetails.date;
    List<String> dateParts = dateString.split('-');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    final DateTime focusedDay = DateTime(year, month, day);
    final DateTime firstDay = DateTime(year, month, day);
    final DateTime lastDay = firstDay.add(const Duration(days: 7));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.employeeWeekoffDetails.empCode} - Apply leave',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: showProgress
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  eventLoader: (date) =>
                      customColorsMap.containsKey(date) ? [date] : [],
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, _) {
                      return customColorsMap.containsKey(date)
                          ? Container(
                              decoration: BoxDecoration(
                                color: customColorsMap[date]![0],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : null;
                    },
                  ),
                ),
                SelectedDatesList(selectedDates: _selectedDates),
                // Use the new widget
              ],
            ),
    );
  }

  bool _isDaySelected(DateTime day) {
    return _selectedDates.any((date) => isSameDay(day, date.date));
  }


}
