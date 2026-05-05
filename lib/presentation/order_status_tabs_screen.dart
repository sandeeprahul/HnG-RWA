import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../common/progress_dialog.dart';
import 'ecom_order_list_screen.dart';

class OrderStatusTabsScreen extends StatefulWidget {
  final int orderTypeId;
  final String orderTypeName;

  const OrderStatusTabsScreen({
    super.key,
    required this.orderTypeId,
    required this.orderTypeName,
  });

  @override
  State<OrderStatusTabsScreen> createState() => _OrderStatusTabsScreenState();
}

class _OrderStatusTabsScreenState extends State<OrderStatusTabsScreen> {
  List<dynamic> statusTabs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchOrderStatusTabs();
    });
  }

  Future<void> fetchOrderStatusTabs() async {
    final url = 'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/ECOMOrders/GetOrderStatusByOrderType?orderTypeId=${widget.orderTypeId}';
    
    ProgressDialog.show(context, message: "Loading status options...");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          print("Status Tabs Data: ${data['data']}");
          setState(() {
            statusTabs = data['data'];
          });
        } else {
          _showErrorSnackBar("Error: ${data['message']}");
        }
      } else {
        _showErrorSnackBar("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorSnackBar("Network error. Please try again.");
    } finally {
      ProgressDialog.hide(context);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.orderTypeName} Process',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
            ),
            Text(
              'Select status to view orders',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading && statusTabs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : statusTabs.isEmpty
              ? const Center(child: Text("No status options found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: statusTabs.length,
                  itemBuilder: (context, index) {
                    final status = statusTabs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _StatusSelectionCard(
                        title: status['screenStatusName'],
                        subtitle: "View all ${status['screenStatusName']} orders",
                        onTap: () {
                          Get.to(() => EcomOrderListScreen(
                                orderType: widget.orderTypeName,
                                status: status['screenStatusName'],
                              ));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class _StatusSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StatusSelectionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.list_alt_rounded, color: Colors.deepOrangeAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD1D5DB), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
