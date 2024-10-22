// weekoff_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../data/opeartions/employee_weekoff_details.dart';


class WeekoffService {
  Future<void> submitWeekOff(List<dynamic> params) async {
    var url = Uri.https('RWAWEB.HEALTHANDGLOWONLINE.CO.IN', '/RWASTAFFMOVEMENT_TEST/api/Login/weekoff');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(params),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit week-off: ${response.statusCode}');
    }
  }

  List<dynamic> formatParams(List<EmployeeWeekoffDetails> detailsList) {
    return detailsList.map((details) {
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(details.date);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      return {
        "empCode": details.empCode,
        "date": formattedDate,
        "leaveType": details.leavetype,
        "activeInd": details.activeInd,
      };
    }).toList();
  }
}
