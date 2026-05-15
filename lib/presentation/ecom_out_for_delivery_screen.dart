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
  final String screenStatusName;

  const EcomOutForDeliveryScreen({
    super.key,
    required this.type,
    required this.orderType,
    required this.screenStatusName,
  });

  @override
  State<EcomOutForDeliveryScreen> createState() =>
      _EcomOutForDeliveryScreenState();
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

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['statusCode'] == "200" && data['status'] == "success") {
          final List<dynamic> jsonList = data['locations'];
          setState(() {
            userLocations =
                jsonList.map((json) => UserLocations.fromJson(json)).toList();
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
      setState(() {
        isLoadingLocations = false;
      });
    }
  }

  void _showLocationSelector() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Select Store",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                    filteredLocations = userLocations
                        .where((l) =>
                            l.locationName
                                .toLowerCase()
                                .contains(val.toLowerCase()) ||
                            l.locationCode.contains(val))
                        .toList();
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
                      title:
                          Text(loc.locationName, style: GoogleFonts.outfit()),
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
      setState(() {
        isLoadingLocations = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        double.parse(location.latitude),
        double.parse(location.longitude),
      );

      if (distance >= 100.0) {
        setState(() {
          selectedLocation = location;
          isLoadingLocations = false;
        });
        _fetchOrders();
      } else {
        setState(() {
          isLoadingLocations = false;
        });
        _showAccessDeniedDialog(distance);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Location verification failed");
      setState(() {
        isLoadingLocations = false;
      });
    }
  }

  void _showAccessDeniedDialog(double distance) {
    Get.defaultDialog(
      title: "Access Restricted",
      middleText:
          "You are ${distance.toStringAsFixed(0)}m away. Please be within 100 meters of the store.",
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

    String apiStatus;

    // Logic to determine the EXACT status string for the API
    switch (widget.type) {
      case 0: // RTS -> Out for Delivery
        apiStatus = "Out for Delivery";
        break;
      case 1: // OFD -> Delivered or Handed Over
        // If screen name is 'Handed Over to Customer', we might be viewing history
        // otherwise we are looking for 'Out for Delivery' orders to process
        apiStatus = (widget.screenStatusName == "Handed Over to Customer")
            ? "Handed Over to Customer"
            : "Delivered";
        break; //
      case 2: // Specific Ready to Ship View
        apiStatus = "Ready to Ship";
        break;
      case 3: // Ready to Pick
        apiStatus = "Ready to Pick";
        break;
      default:
        apiStatus = widget.screenStatusName;
    }

    print(
        "Fetching Orders for Location: ${selectedLocation!.locationCode}, Type: ${widget.type}, API Status: $apiStatus");
    print(
        "Fetching Orders for Location: ${selectedLocation!.locationCode}, Type: ${widget.type}, API Status: ${widget.orderType}");

    // Call the controller with the mapped status
    await orderController.fetchEcomOrders(
        selectedLocation!.locationCode, widget.orderType, apiStatus);

    // orderController.fetchEcomOrders(selectedLocation!.locationCode, widget.orderType, widget.screenStatusName=="Ready to Ship"?"Ready to Ship":widget.screenStatusName);
    // orderController.fetchEcomOrders(selectedLocation!.locationCode, widget.orderType, widget.screenStatusName=="Ready to Ship"?"Ready to Pick":widget.screenStatusName);
  }

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController(widget.type));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.screenStatusName} - ${widget.orderType}",
          style: GoogleFonts.outfit(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoadingLocations
          ? Center(
              child: Column(
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
                return Center(
                    child:
                        Text("No orders found", style: GoogleFonts.outfit()));
              }
              return OrderListWidget(
                orders: orderController.orders,
                onOrderTap: (order) {
                  if (widget.type == 2 ||
                      widget.screenStatusName == "Ready to Ship") {
                    // Screen for assigning executive
                    _showOutForDeliveryPopup(order);
                  }
                  if (widget.type == 1 ||
                      widget.screenStatusName == "Delivered") {
                    // Screen for assigning executive
                    // _showOutForDeliveryPopup(order);
                    Get.snackbar("Info", "Order already delivered to customer",
                        backgroundColor: Colors.blue, colorText: Colors.white);
                  } else if (widget.type == 0 ||
                      widget.screenStatusName == "Out for Delivery") {
                    // Screen for OTP verification and delivery
                    _showHandedOverPopup(order);
                  } else if (widget.screenStatusName ==
                      "Handed Over to Customer") {
                    // Logic for already delivered (perhaps just show details or a message)
                    Get.snackbar("Info", "Order already delivered to customer",
                        backgroundColor: Colors.blue, colorText: Colors.white);
                    // _showHandedOverPopup(order);
                  } else if (widget.screenStatusName == "Read to Pick" ||
                      widget.type == 3) {
                    _showHandedOverPopup(order);
                  } else {
                    // Fallback for other statuses like Ready to Pick
                    _showOutForDeliveryPopup(order);
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

    if (widget.screenStatusName == "Read to Pick" ||
        widget.orderType == "Click & Collect") {
      _fetchCustomerDetails(order['orderId'], nameController, mobileController);
    }

    Get.dialog(
      AlertDialog(
        title: Text("Assign Delivery",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPopupField("Executive Name", nameController),
              const SizedBox(height: 12),
              _buildPopupField("Mobile Number", mobileController,
                  isPhone: true),
              const SizedBox(height: 12),
              _buildPopupField("Estimated Mins", minsController, isPhone: true),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(Get.context!).pop();
              },
              child: const Text("Cancel")),
          Obx(() => ElevatedButton(
                onPressed: deliveryController.isLoading.value
                    ? null
                    : () {
                        if (nameController.text.isEmpty ||
                            mobileController.text.length != 10) {
                          Fluttertoast.showToast(
                              msg: "Please enter valid details");
                          return;
                        }
                        Navigator.of(Get.context!).pop();

                        deliveryController
                            .submitDeliveryDetailsECOM(
                          name: nameController.text,
                          mobile: mobileController.text,
                          minutes: int.tryParse(minsController.text) ?? 30,
                          orderId: order['orderId'],
                          locationCode: selectedLocation!.locationCode,
                        )
                            .then((_) {
                          _fetchOrders();
                        });
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: deliveryController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text("Update OFD",
                        style: GoogleFonts.outfit(color: Colors.white)),
              )),
        ],
      ),
    );
  }

  void _showHandedOverPopup(Map<String, dynamic> order) {
    final DeliveryController deliveryController = Get.put(DeliveryController());
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final otpController = TextEditingController();

    deliveryController.otpVerified.value = false;

    if (widget.screenStatusName == "Read to Pick" ||
        widget.orderType == "Click & Collect") {
      _fetchCustomerDetails(order['orderId'], nameController, mobileController);
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Order ID: ${order['orderId']}',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildPopupField('Delivered to Person Name', nameController),
              const SizedBox(height: 12),
              _buildPopupField('Delivered to Mobile No', mobileController,
                  isPhone: true),
              const SizedBox(height: 4),

              // Send OTP Button
              Obx(() {
                return ElevatedButton(
                  onPressed: () {
                    if (mobileController.text.isEmpty) {
                      Get.snackbar('Alert', "Please enter Mobile number",
                          overlayBlur: 2,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                    } else {
                      deliveryController.sendOtpECOM(mobileController.text,
                          nameController.text, order['orderId']);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: deliveryController.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Send OTP',
                          style: GoogleFonts.outfit(color: Colors.white),
                        ),
                );
              }),
              const SizedBox(height: 16),

              _buildPopupField('Verify Otp', otpController, isPhone: true),
              const SizedBox(height: 4),

              ElevatedButton(
                onPressed: () {
                  if (otpController.text.isNotEmpty) {
                    deliveryController.verifyOtp(otpController.text);
                  } else {
                    Get.snackbar("Alert!", "Please enter otp",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        overlayBlur: 2);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Verify OTP',
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              // Final Delivered Button (Only visible if OTP is verified)
              Obx(() {
                return ElevatedButton(
                  onPressed: deliveryController.otpVerified.value
                      ? () async {
                          bool success =
                              await ecomController.updateHandedOverToCustomer(
                            order['orderId'], widget.orderType,
                            name: nameController.text, // <--- Added this
                            mobile: mobileController.text, // <--- Added this
                          );
                          if (success) {
                            Navigator.of(Get.context!).pop();

                            _fetchOrders();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: ecomController.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Delivered',
                          style: GoogleFonts.outfit(color: Colors.white),
                        ),
                );
              }),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _fetchCustomerDetails(String orderId,
      TextEditingController nameController, TextEditingController mobileController) async {
    try {
      final url = 'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/ECOMOrders/getCustDetails/$orderId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok' && data['data'] != null) {
          nameController.text = data['data']['cust_name'] ?? '';
          mobileController.text = data['data']['mobile'] ?? '';
        }
      }
    } catch (e) {
      print('Error fetching customer details: $e');
    }
  }

  Widget _buildPopupField(String label, TextEditingController controller,
      {bool isPhone = false}) {
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
