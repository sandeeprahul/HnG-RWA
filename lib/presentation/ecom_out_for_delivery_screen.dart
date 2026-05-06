import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/widgets/order_list_widget.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../common/constants.dart';
import '../controllers/delivery_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/ecom_order_details_controller.dart';
import '../data/UserLocations.dart';

class EcomOutForDeliveryScreen extends StatefulWidget {
  final int type; // 0 for RTS -> OFD, 1 for OFD -> Delivered
  final String orderType; // e.g., "Standard", "Express"

  const EcomOutForDeliveryScreen({
    super.key,
    required this.type,
    required this.orderType,
  });

  @override
  State<EcomOutForDeliveryScreen> createState() => _EcomOutForDeliveryScreenState();
}

class _EcomOutForDeliveryScreenState extends State<EcomOutForDeliveryScreen> {
  late EcomOrderDetailsController ecomController;
  UserLocations? selectedLocation;
  List<UserLocations> userLocations = [];
  List<UserLocations> filteredLocations = [];
  bool isLoadingLocations = false;
  String statusText = "";

  @override
  void initState() {
    super.initState();
    ecomController = Get.isRegistered<EcomOrderDetailsController>()
        ? Get.find<EcomOrderDetailsController>()
        : Get.put(EcomOrderDetailsController());

    _fetchStoreLocations();
  }

  Future<void> _fetchStoreLocations() async {
    setState(() {
      isLoadingLocations = true;
      statusText = "Fetching Locations...";
    });

    try {
      final pref = await SharedPreferences.getInstance();
      var userid = pref.getString("userCode");
      final url = '${Constants.apiHttpsUrl}/Login/GetLocation/$userid';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['statusCode'] == "200" && data['status'] == "success") {
          final List<dynamic> jsonList = data['locations'];
          setState(() {
            userLocations = jsonList.map((json) => UserLocations.fromJson(json)).toList();
            filteredLocations = userLocations;
            isLoadingLocations = false;
          });

          if (userLocations.isNotEmpty) {
            _showLocationSelector();
          }
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching locations");
      setState(() { isLoadingLocations = false; });
    }
  }

  void _showLocationSelector() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Select Store", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: "Search store...",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) {
                  setState(() {
                    filteredLocations = userLocations.where((l) => 
                      l.locationName.toLowerCase().contains(val.toLowerCase()) || 
                      l.locationCode.contains(val)).toList();
                  });
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index) {
                    final loc = filteredLocations[index];
                    return ListTile(
                      title: Text(loc.locationName, style: GoogleFonts.outfit()),
                      subtitle: Text("Code: ${loc.locationCode}"),
                      onTap: () {
                        Navigator.pop(context);
                        _verifyProximityAndFetch(loc);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyProximityAndFetch(UserLocations location) async {
    setState(() {
      isLoadingLocations = true;
      statusText = "Verifying proximity...";
    });

    var status = await Permission.location.status;
    if (!status.isGranted) status = await Permission.location.request();

    if (!status.isGranted) {
      Fluttertoast.showToast(msg: "Location permission required");
      setState(() { isLoadingLocations = false; });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double distance = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        double.parse(location.latitude), double.parse(location.longitude),
      );

      if (distance <= 1000.0) {
        setState(() {
          selectedLocation = location;
          isLoadingLocations = false;
        });
        _fetchOrders();
      } else {
        setState(() { isLoadingLocations = false; });
        _showAccessDeniedDialog(distance);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Location verification failed");
      setState(() { isLoadingLocations = false; });
    }
  }

  void _showAccessDeniedDialog(double distance) {
    Get.defaultDialog(
      title: "Access Restricted",
      middleText: "You are ${distance.toStringAsFixed(0)}m away. Please be within 1km of the store.",
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  Future<void> _fetchOrders() async {
    if (selectedLocation == null) return;
    
    final OrderController orderController = Get.isRegistered<OrderController>() 
        ? Get.find<OrderController>() 
        : Get.put(OrderController(widget.type));

    String apiStatus = widget.type == 0 ? "READY_TO_SHIP" : "OUT_FOR_DELIVERY";
    orderController.fetchEcomOrders(selectedLocation!.locationCode, widget.orderType, apiStatus);
  }

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.isRegistered<OrderController>() 
        ? Get.find<OrderController>() 
        : Get.put(OrderController(widget.type));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 0 ? 'ECOM: Out For Delivery' : 'ECOM: Handover Update',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoadingLocations
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.orange),
                const SizedBox(height: 16),
                Text(statusText, style: GoogleFonts.outfit()),
              ],
            ))
          : Obx(() {
              if (orderController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (orderController.orders.isEmpty) {
                return Center(child: Text("No orders found", style: GoogleFonts.outfit()));
              }
              return OrderListWidget(
                orders: orderController.orders,
                onOrderTap: (order) {
                  if (widget.type == 0) {
                    _showOutForDeliveryPopup(order);
                  } else {
                    _showHandedOverPopup(order);
                  }
                },
              );
            }),
    );
  }

  void _showOutForDeliveryPopup(Map<String, dynamic> order) {
    final DeliveryController deliveryController = Get.put(DeliveryController());
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final minsController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text("Assign Delivery", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPopupField("Executive Name", nameController),
              const SizedBox(height: 12),
              _buildPopupField("Mobile Number", mobileController, isPhone: true),
              const SizedBox(height: 12),
              _buildPopupField("Estimated Mins", minsController, isPhone: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          Obx(() => ElevatedButton(
            onPressed: deliveryController.isLoading.value ? null : () {
              if (nameController.text.isEmpty || mobileController.text.length != 10) {
                Fluttertoast.showToast(msg: "Please enter valid details");
                return;
              }
              deliveryController.submitDeliveryDetails(
                name: nameController.text,
                mobile: mobileController.text,
                minutes: int.tryParse(minsController.text) ?? 30,
                orderId: order['orderId'],
                locationCode: selectedLocation!.locationCode,
              ).then((_) {
                _fetchOrders();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: deliveryController.isLoading.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text("Update OFD", style: GoogleFonts.outfit(color: Colors.white)),
          )),
        ],
      ),
    );
  }

  void _showHandedOverPopup(Map<String, dynamic> order) {
    Get.dialog(
      AlertDialog(
        title: Text("Hand Over to Customer", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to mark Order ${order['orderId']} as Handed Over to Customer?", style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          Obx(() => ElevatedButton(
            onPressed: ecomController.isLoading.value ? null : () async {
              bool success = await ecomController.updateHandedOverToCustomer(order['orderId']);
              if (success) {
                Get.back();
                _fetchOrders();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: ecomController.isLoading.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text("Confirm Handover", style: GoogleFonts.outfit(color: Colors.white)),
          )),
        ],
      ),
    );
  }

  Widget _buildPopupField(String label, TextEditingController controller, {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
