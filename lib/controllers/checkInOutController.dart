

import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../data/UserLocations.dart';
import 'package:http/http.dart' as http;

class CheckInOutController extends GetxController{

  RxList<UserLocations> userLocations = RxList<UserLocations>();

  RxBool isLoading = false.obs;
  RxBool _showLocationListBool = false.obs;

  RxBool get getShowLocationListBool => _showLocationListBool;

  set setShowLocationListBool(RxBool value) {
    _showLocationListBool = value;
  }




  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  Future<List<UserLocations>> fetchLocations() async {
    isLoading.value = true;
    print("fetchLocations");

    final pref  = await SharedPreferences.getInstance();
    var userid = pref.getString("userCode");
    final url = '${Constants.apiHttpsUrl}/Login/GetLocation/$userid'; // Replace with your API endpoint URL

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var responses = jsonDecode(response.body);
      print("Url->$url res=$responses");

      if(responses['statusCode']=="200"&&responses['status']=="success"){
        final List<dynamic> jsonList = responses['locations'];

        final List<UserLocations> locations = jsonList
            .map((json) => UserLocations.fromJson(json))
            .toList();
        print("locations.length"+locations.length.toString());

        if(locations.length>1){
        }

        userLocations.assignAll(locations);

        update();
        isLoading.value = false;

        return locations;
      }else {
        isLoading.value = false;

        throw Exception('Failed to fetch locations');

      }

    } else {
      isLoading.value = false;

      throw Exception('Failed to fetch locations');
    }
  }
}