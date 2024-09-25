import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hng_flutter/data/employee_details_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../common/constants.dart';

class SurveyController extends ChangeNotifier {

  List<Employeedetail> employeeDetails = [];

  Future<List<Employeedetail>?> getEmployeeList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userID = prefs.getString('userCode') ?? '';

      String url =
          "${Constants.apiHttpsUrl}/Login/WeekoffEmployees/$userID";

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));

      var responseData = json.decode(response.body);
      print(url);
      print(responseData);

      Map<String, dynamic> map = json.decode(response.body);
      final statusCode = map['statusCode'];
      if(statusCode=="200"){

        List<dynamic> data = map['employeelist'];


        data.forEach((element) {
          employeeDetails.add(Employeedetail.fromJson(element));
        });

        return employeeDetails;
      }


    } catch (e) {
      print("Error:$e");
      return null;
    } finally {

    }
    return null;
  }
}
