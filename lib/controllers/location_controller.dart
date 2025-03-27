import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../common/constants.dart';
import '../data/UserLocations.dart';
import '../data/order_model.dart';



class LocationController extends GetxController {
  var loading = false.obs;
  var statusText = ''.obs;
  var userLocations = <UserLocations>[].obs;
  var filteredLocations = <UserLocations>[].obs;
  UserLocations? selectedLocation;
  var showLocationList = false.obs;
  var orders = <Order>[].obs;
  double? userLat;
  double? userLng;
  final double maxDistance = 100.0; // Define max distance in meters

  @override
  void onInit() {
    fetchLocations();
    super.onInit();
  }

  /// Fetch user locations from API
  Future<void> fetchLocations() async {
    try {
      loading.value = true;
      statusText.value = "Fetching Locations..";

      final pref = await SharedPreferences.getInstance();
      var userId = pref.getString("userCode");
      final url = '${Constants.apiHttpsUrl}/Login/GetLocation/$userId';

      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var responses = jsonDecode(response.body);

        if (responses['statusCode'] == "200" && responses['status'] == "success") {
          final List<dynamic> jsonList = responses['locations'];

          userLocations.assignAll(jsonList.map((json) => UserLocations.fromJson(json)).toList());
          filteredLocations.assignAll(userLocations);

          if (filteredLocations.isNotEmpty) {
            showLocationList.value = true;
          }
        } else {
          statusText.value = "Fetching location error.. Status Code: ${responses['statusCode']}";
          Get.snackbar("Error", statusText.value);
        }
      } else {
        statusText.value = "Fetching location error.. Status Code: ${response.statusCode}";
        Get.snackbar("Error", statusText.value);
      }
    } catch (e) {
      statusText.value = Constants.networkIssue;
      Get.snackbar("Network Issue", Constants.networkIssue);
    } finally {
      loading.value = false;
    }
  }

  /// Set selected location
  void selectLocation(UserLocations location) {
    selectedLocation = location;
    userLat = double.parse(location.latitude);
    userLng = double.parse(location.longitude);
  }

  /// Get current location of the user
  Future<void> getCurrentLocation() async {
    try {
      loading.value = true;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLat = position.latitude;
      userLng = position.longitude;
    } catch (e) {
      Get.snackbar("Error", "Failed to get location");
    } finally {
      loading.value = false;
    }
  }

  /// Check distance from selected location
  Future<void> checkDistance() async {
    if (selectedLocation == null || userLat == null || userLng == null) {
      Get.snackbar("Error", "Please select a location first");
      return;
    }

    try {
      loading.value = true;
      statusText.value = "Calculating distance..";

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double currentLat = position.latitude;
      double currentLng = position.longitude;

      double distance = Geolocator.distanceBetween(
        currentLat,
        currentLng,
        userLat!,
        userLng!,
      );

      if (distance <= maxDistance) {
        statusText.value = "You are near the store.";
        Get.snackbar("Success", statusText.value);
        fetchOrders();
      } else {
        statusText.value = "You are outside of store\n${distance.toStringAsFixed(2)} meters far.";
        Fluttertoast.showToast(
            msg: statusText.value,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to calculate distance");
    } finally {
      loading.value = false;
    }
  }

  /// Fetch orders from API
  Future<void> fetchOrders() async {
    try {
      loading.value = true;
      statusText.value = "Fetching orders..";

      const url = '${Constants.apiHttpsUrl}/Orders/GetOrders';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var responses = jsonDecode(response.body);

        if (responses['statusCode'] == "200" && responses['status'] == "success") {
          final List<dynamic> jsonList = responses['orders'];
          orders.assignAll(jsonList.map((json) => Order.fromJson(json)).toList());

          Get.snackbar("Success", "Orders fetched successfully");
        } else {
          statusText.value = "Fetching orders failed.. Status Code: ${responses['statusCode']}";
          Get.snackbar("Error", statusText.value);
        }
      } else {
        statusText.value = "Fetching orders failed.. Status Code: ${response.statusCode}";
        Get.snackbar("Error", statusText.value);
      }
    } catch (e) {
      statusText.value = Constants.networkIssue;
      Get.snackbar("Network Issue", Constants.networkIssue);
    } finally {
      loading.value = false;
    }
  }

  /// Filter locations based on search query
  void filterSearch(String query) {
    filteredLocations.assignAll(userLocations
        .where((location) =>
    location.locationName.toLowerCase().contains(query.toLowerCase()) ||
        location.locationCode.toLowerCase().contains(query.toLowerCase()))
        .toList());
  }
}
