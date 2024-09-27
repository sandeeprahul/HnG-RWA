import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../common/constants.dart';
import '../data/employee_leaveapply_list.dart';
import '../data/opeartions/employee_weekoff_entity.dart';

class WeekOffRepository {

  Future<List<EmployeeLeaveAplylist>?> getEmployeeList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '';

      String url =
          "${Constants.apiHttpsUrl}/Login/WeekoffEmployees/$userID";

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

        return employeeDetailsTemp;
      } else {
        // Return null or an empty list based on your requirement
        return [];
      }
    } catch (e) {
      print("Error:$e");
      // Rethrow the exception to handle it in the UI
      rethrow;
    }
  }

  Future<void> applyWeekOff( String empCode, List<dynamic> params) async {

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
        body: jsonEncode(params),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
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
        print(response.statusCode);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<EmployeeWeekoffEntity?> getEmployeeWeekOffDetails(String employeeCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '';

      String url =
          "${Constants.apiHttpsUrl}/Login/Listweekoff/$employeeCode";

      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      print(url);

      var responseData = json.decode(response.body);
      print(url);
      print(responseData);

      Map<String, dynamic> map = json.decode(response.body);
      final statusCode = map['statusCode'];
      if (statusCode == "200") {

        var responseData = json.decode(response.body);
        print(url);
        print(responseData);

        return EmployeeWeekoffEntity.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      print("Error:$e");
      rethrow;
    }
  }

}
