import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hng_flutter/presentation/ecom_out_for_delivery_screen.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../common/constants.dart';
import '../controllers/order_controller.dart';
import '../data/UserLocations.dart';
import 'ecom_assign_delivery_screen.dart';
import 'ecom_order_details_screen.dart';
import 'order_details_screen.dart';

class EcomOrderListScreen extends StatefulWidget {
  final String orderType;
  final String status;
  final String? orderTypeName;

  const EcomOrderListScreen({
    super.key,
    required this.orderType,
    required this.status,
     this.orderTypeName,
  });

  @override
  State<EcomOrderListScreen> createState() => _EcomOrderListScreenState();
}

class _EcomOrderListScreenState extends State<EcomOrderListScreen> {
  late OrderController orderController;
  UserLocations? selectedLocation;
  List<UserLocations> allLocations = [];
  List<UserLocations> filteredLocations = [];
  bool isLocationsLoading = false;
  String loadingMessage = "";

  @override
  void initState() {
    super.initState();
    // Using put instead of find to ensure the controller exists
    orderController = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController(0));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("widget.status");
      print(widget.status);

      _fetchStoreLocations();
    });
  }

  Future<void> _fetchStoreLocations() async {
    setState(() {
      isLocationsLoading = true;
      loadingMessage = "Fetching your stores...";
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
            allLocations = jsonList.map((json) => UserLocations.fromJson(json)).toList();
            filteredLocations = allLocations;
            isLocationsLoading = false;
          });

          if (allLocations.isNotEmpty) {
            _showStoreSelector();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching locations: $e");
      setState(() {
        isLocationsLoading = false;
      });
    }
  }

  void _showStoreSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StoreSelectorSheet(
        locations: allLocations,
        onLocationSelected: (location) async {
          Navigator.pop(context);
          _verifyProximityAndFetch(location);
        },
      ),
    );
  }

  Future<void> _verifyProximityAndFetch(UserLocations location) async {
    setState(() {
      isLocationsLoading = true;
      loadingMessage = "Verifying proximity to ${location.locationName}...";
    });

    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }

    if (!status.isGranted) {
      Fluttertoast.showToast(msg: "Location access is required for security verification.");
      setState(() { isLocationsLoading = false; });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        double.parse(location.latitude),
        double.parse(location.longitude),
      );

      if (distance >= 100.0) { // Allowing 1km range for store proximity
        setState(() {
          selectedLocation = location;
          isLocationsLoading = false;
        });
        orderController.fetchEcomOrders(location.locationCode, widget.orderType, widget.status=="ALL Orders"?"All":widget.status=="Ready to Pick"?"Ready to Ship":widget.status);
        // orderController.fetchEcomOrders(location.locationCode, widget.orderType, widget.status=="ALL Orders"?"All":widget.status);
      } else {
        setState(() { isLocationsLoading = false; });
        _showAccessDeniedDialog(distance);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Could not verify your location.");
      setState(() { isLocationsLoading = false; });
    }
  }

  void _showAccessDeniedDialog(double distance) {
    Get.defaultDialog(
      title: "Access Restricted",
      titleStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      middleText: "You are ${distance.toStringAsFixed(0)}m away. Order access is only permitted within store proximity.",
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text("Understand"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (isLocationsLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(loadingMessage, style: GoogleFonts.outfit(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            _buildOrderList(),
        ],
      ),
      floatingActionButton: selectedLocation != null ? FloatingActionButton(
        onPressed: _showStoreSelector,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.location_on_rounded, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.orange,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.status.toUpperCase()} ORDERS",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            if (selectedLocation != null)
              Text(
                selectedLocation!.locationName,
                style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70),
              ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.orange, Colors.deepOrange],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return Obx(() {
      if (orderController.isLoading.value) {
        return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
      }
      if (orderController.orders.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("No orders found for this status", style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final order = orderController.orders[index];
              return _OrderCard(order: order, locationCode: selectedLocation?.locationCode ?? "");
            },
            childCount: orderController.orders.length,
          ),
        ),
      );
    });
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String locationCode;
  final String? orderTypeName;

  const _OrderCard({required this.order, required this.locationCode,this.orderTypeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(

        onTap: () async {

          final s = (order['status'] ?? '').toString().toUpperCase();
          bool? refresh;
          if (s == 'READY_TO_SHIP' || s == 'OUT_FOR_DELIVERY' || s == 'HANDED OVER TO CUSTOMER') {
            refresh = await Get.to(() => EcomAssignDeliveryScreen(
                  order: order,
                  locationCode: locationCode,
                  title: s == 'HANDED OVER TO CUSTOMER' ? "Handed Over to Customer — ${order['orderId']}" : null,
                ));
          } else {
            refresh = await Get.to(() => EcomOrderDetailsScreen(
                  order: order,
                  selectedLocationCode: locationCode,
                orderTypeName:orderTypeName,
                ));

          }
          if (refresh == true) {
            final orderController = Get.find<OrderController>();
            orderController.fetchEcomOrders(
                locationCode, (order['shippingMethod'] ?? 'Standard'), s.toLowerCase());
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['orderId'] ?? 'N/A',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(Icons.calendar_today_outlined, "Date", order['date'] ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.payments_outlined, "Payment", "${order['paymentMethod']} (${order['paymentStatus']})"),
              if (order['shippingMethod'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.local_shipping_outlined, "Shipping", order['shippingMethod']),
              ],
              const SizedBox(height: 8),

              _StatusChip(status: order['status'] ?? 'OPEN'),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text("$label: ", style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
        Expanded(
          child: Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.blue;
    String s = status.toUpperCase();
    if (s == 'OPEN') color = Colors.orange;
    if (s == 'READY_TO_SHIP') color = Colors.orange; // Consistent with app theme
    if (s == 'OUT_FOR_DELIVERY') color = Colors.deepOrange;
    if (s.contains('CANCEL')) color = Colors.red;
    if (s.contains('DELIVERED')) color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class _StoreSelectorSheet extends StatefulWidget {
  final List<UserLocations> locations;
  final Function(UserLocations) onLocationSelected;

  const _StoreSelectorSheet({required this.locations, required this.onLocationSelected});

  @override
  State<_StoreSelectorSheet> createState() => _StoreSelectorSheetState();
}

class _StoreSelectorSheetState extends State<_StoreSelectorSheet> {
  late List<UserLocations> filtered;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filtered = widget.locations;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text("Select Store", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  filtered = widget.locations.where((l) => l.locationName.toLowerCase().contains(val.toLowerCase()) || l.locationCode.contains(val)).toList();
                });
              },
              decoration: InputDecoration(
                hintText: "Search store name or code",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final loc = filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1), child: const Icon(Icons.store, color: Colors.orange)),
                  title: Text(loc.locationName, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  subtitle: Text("Code: ${loc.locationCode}"),
                  onTap: () => widget.onLocationSelected(loc),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
