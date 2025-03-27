import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/widgets/order_list_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../common/progress_dialog.dart';
import '../controllers/delivery_controller.dart';
import '../controllers/order_controller.dart';
import '../data/UserLocations.dart';
import 'order_details_screen.dart';

class OutForDeliveryScreen extends StatefulWidget {
  final int type;

  const OutForDeliveryScreen({super.key, required this.type});

  @override
  State<OutForDeliveryScreen> createState() => _OutForDeliveryScreenState();
}

class _OutForDeliveryScreenState extends State<OutForDeliveryScreen> {

  final OrderController orderController = Get.put(OrderController());

  UserLocations? selectedLocation;
  TextEditingController searchController = TextEditingController();
  List<UserLocations> filteredLocations = [];
  bool loading = false;
  List<UserLocations> userLocations = [];
  String statusText = "Loading..";

  Future<List<UserLocations>?> fetchLocations() async {
    try {
      setState(() {
        loading = true;
        statusText = "Fetching Locations..";
      });

      final pref = await SharedPreferences.getInstance();
      var userid = pref.getString("userCode");
      final url = '${Constants.apiHttpsUrl}/Login/GetLocation/$userid';

      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var responses = jsonDecode(response.body);

        if (responses['statusCode'] == "200" &&
            responses['status'] == "success") {
          final List<dynamic> jsonList = responses['locations'];

          userLocations.clear();
          filteredLocations.clear;
          final List<UserLocations> locations =
          jsonList.map((json) => UserLocations.fromJson(json)).toList();
/*
        print("locations.length" + locations.length.toString());
*/

          userLocations = locations;
          filteredLocations = userLocations;
          if (filteredLocations.length == 1 || filteredLocations.isNotEmpty) {
            setState(() {
              loading = false;
            });
            // print("$userLocations[0].latitude");
          }
          if (locations.isNotEmpty) {
            showLocationPopup(context, locations);
          }

          setState(() {
            loading = false;
            // selectedLocation = userLocations[0];
          });

          return locations;
        } else {
          setState(() {
            loading = false;
            statusText =
            "Fetching location error..\nStatus Code: ${responses['statusCode']}";
          });
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pop(context);
          });

          throw Exception('Failed to fetch locations');
        }
      } else {
        setState(() {
          loading = false;
          statusText =
          "Fetching location error..\nStatus Code: ${response.statusCode}";
        });
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context);
        });
        throw Exception('Failed to fetch locations');
      }
    } catch (e) {
      setState(() {
        loading = false;
        statusText = Constants.networkIssue;
      });
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    }
    return null;
  }

  void filterSearch(String query) {
    setState(() {
      filteredLocations = userLocations
          .where((location) =>
      location.locationName
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          location.locationCode.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void showLocationPopup(BuildContext context, List<UserLocations> locations) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select a Location"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: locations.isEmpty
                ? const Center(child: Text("No locations available"))
                : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(fontSize: 15),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: filterSearch,
                  ),
                ),
                const SizedBox(height: 10,),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      var location = filteredLocations[index];
                      return Card(
                        child: ListTile(
                          title: Text(location.locationName),
                          subtitle: Text("Code: ${location.locationCode}"),
                          onTap: () async {
                            print("Code: ${location.locationCode}");
                            Navigator.pop(context); // Close popup
                            await checkDistanceAndProceed(context, location);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  /// **Check distance & perform next action**
  Future<void> checkDistanceAndProceed(
      BuildContext context, UserLocations location) async
  {
    double userLat, userLng;

    // Get user location
    try {
      setState(() {
        loading = true;
        statusText = 'Calculating distance..';
      });
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLat = position.latitude;
      userLng = position.longitude;
    } catch (e) {
      setState(() {
        loading = false;
        statusText = 'Error calculating distance';
      });
      Get.snackbar("Failure", "Failed to get location");
      return;
    } finally {
      setState(() {
        loading = false;
        statusText = '';
      });
    }

    // Calculate distance
    double distance = Geolocator.distanceBetween(
      userLat,
      userLng,
      double.parse(location.latitude),
      double.parse(location.longitude),
    );

    if (distance <= 100.0) {
      // Max 100 meters

      Get.snackbar("Failure", "You are near the store");

      // **Call your method after successful selection**
      onLocationSelected(location);
    } else {
      orderController.isError.value = true;
      orderController.isLoading.value = false;
      Get.snackbar(
        "Alert!", "You are too far (${distance.toStringAsFixed(2)} meters)",
        backgroundColor: Colors.red,colorText: Colors.white,);
      // Navigator.of(context).pop();
    }
  }

  /// **Example method called after successful selection**
  void onLocationSelected(UserLocations selectedLocation) {
    print("Proceed with location: ${selectedLocation.locationCode}");
    // Perform next actions like fetching orders, etc.
    orderController.fetchOrders(selectedLocation.locationCode);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLocations();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 0 ? 'Update Out For Delivery' : "Delivery Update",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: loading?Center(child: Text(statusText),):Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: Icon(Icons.document_scanner_outlined),
                  border: UnderlineInputBorder()),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (orderController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (orderController.isError.value) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Failed to load orders"),
                      SizedBox(height: 10),
                      // ElevatedButton(
                      //   onPressed: () => orderController.fetchOrders(),
                      //   child: const Text("Retry"),
                      // ),
                    ],
                  ),
                );
              } else {
                return OrderListWidget(
                    orders: orderController.orders,
                    onOrderTap: (order) {
                      if (widget.type == 0) {
                        showDeliveryPopup(order);
                      } else {
                        showOutForDeliveryPopup(order);
                      }
                    });
              }
            }),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.orange)),
            child: Row(
              children: [
                const Expanded(
                  child: Center(child: Text('ClearAll')),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange,
                    child: const Center(
                        child: Text(
                      'Filter',
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showDeliveryPopup(Map<String, dynamic> order) {
    final DeliveryController controller = Get.put(DeliveryController());

    TextEditingController nameController = TextEditingController();
    TextEditingController mobileController = TextEditingController();
    TextEditingController minutesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Order ID: ${order['orderId']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            buildTextField('Delivery Executive Name', nameController),
            const SizedBox(height: 12),
            buildTextField('Delivery Executive Mobile No', mobileController),
            const SizedBox(height: 12),
            buildTextField('Estimated Minutes For Delivery', minutesController),
            const SizedBox(height: 20),

            // Using Obx to observe loading state
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.submitDeliveryDetails(
                            name: nameController.text,
                            mobile: mobileController.text,
                            minutes: int.tryParse(minutesController.text) ?? 0,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    // minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Out For Delivery',
                          style: TextStyle(color: Colors.white),
                        ),
                )),
          ],
        ),
      ),
      barrierDismissible: false, // Prevent accidental dismissal
    );
  }

  void showOutForDeliveryPopup(Map<String, dynamic> order) {
    final DeliveryController controller = Get.put(DeliveryController());

    TextEditingController nameController = TextEditingController();
    TextEditingController mobileController = TextEditingController();
    TextEditingController minutesController = TextEditingController();
    TextEditingController otpController = TextEditingController(); // OTP Field

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Order ID: ${order['orderId']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            buildTextField('Delivered to Person Name', nameController),
            const SizedBox(height: 12),
            buildTextField('Delivered to Mobile No', mobileController),
            const SizedBox(height: 4),

            // Send OTP Button
            ElevatedButton(
              onPressed: () => controller.sendOtp(
                  mobileController.text, nameController.text, order['orderId']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Send OTP',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16),

            buildTextField('Verify Otp', otpController),
            const SizedBox(height: 4),

            ElevatedButton(
              onPressed: () => controller.verifyOtp(otpController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Verify OTP',
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Final Out For Delivery Button (Only visible if OTP is verified)
            ElevatedButton(
              onPressed:controller.otpVerified.value? () {
                controller.submitDelivered(
                  orderId: order['orderId'],
                  mobile: mobileController.text,
                  name: nameController.text,
                );
              }:null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Delivered',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Value',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }
}
