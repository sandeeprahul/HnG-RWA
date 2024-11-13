import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../common/constants.dart';
import '../data/employee_leaveapply_list.dart';
import '../data/opeartions/store_transfer_entity.dart';
import '../data/opeartions/weekoff_entity.dart';

class StoreTransferRepository {

  Future<StoreTransferData?> getStoreTransferData(String employeeCode) async {
    try {


      String url =
          "${Constants.apiHttpsUrl}/Login/TemporaryTransfer/$employeeCode";

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      print(url);

      var responseData = json.decode(response.body);
      print(url);
      print(responseData);

      return StoreTransferData.fromJson(responseData);
    } catch (e) {
      if (kDebugMode) {
        print("Error:$e");
      }
      // Rethrow the exception to handle it in the UI
      rethrow;
    }
  }


  Future<void> transferEmployee(
      List<WeekoffEntity> selectedDates, String empCode) async
  {
     var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        '/RWASTAFFMOVEMENT_TEST/api/Login/weekoff',
    );

    try {
      //date

      final requestBody = selectedDates.map((date) {
        return [ {
          "empCode": date.empCode,
          "date": '${date.date.year}-${date.date.month}-${date.date.day}', // Convert DateTime to String format
          "leaveType": date.leaveType,
        }];
      }).toList();
      var params =[];
      for(int i = 0;i<selectedDates.length;i++){
        final details = selectedDates[i];
        params.add({
          "empCode": empCode,
          "date": '${details.date.year}-${details.date.month}-${details.date.day}', // Convert DateTime to String format
          "leaveType": details.leaveType,
        });
      }
      print(params);

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

  Future<String> sendUpdatedLocation( String empCode, Map<String, Object> params) async {



    try
    {
       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWASTAFFMOVEMENT_TEST/api/Login/TrasnferUpdate',
      );
      print(url);

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(params),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var respo = jsonDecode(response.body);
        print(url);
        print(respo);

        // "statusCode": "201",
        if (respo['statusCode'] == "200") {
          print(respo['statusCode']);
          return "200";
        } else if (respo['statusCode'] == "201") {
          return "201";
        }
      } else if (response.statusCode == 201) {
        print(response.statusCode);
        return "201";

      } else {
        return "404";

        print(response.statusCode);
      }
    }
    catch (e)
    {

      print(e);
      // rethrow;
      // return "404";

      throw "404";
    }
    throw "";

  }

}
