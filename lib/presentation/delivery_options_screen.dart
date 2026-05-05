import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'order_status_tabs_screen.dart';
import '../common/progress_dialog.dart';

class DeliveryOptionsScreen extends StatefulWidget {
  const DeliveryOptionsScreen({super.key});

  @override
  State<DeliveryOptionsScreen> createState() => _DeliveryOptionsScreenState();
}

class _DeliveryOptionsScreenState extends State<DeliveryOptionsScreen> {
  List<dynamic> deliveryMethods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDeliveryMethods();
    });
  }

  Future<void> fetchDeliveryMethods() async {
    const url =
        'https://rwaweb.healthandglowonline.co.in/RWAMOBILEAPIOMS/api/ECOMOrders/ECOMOrderMasterlist';

    // Show progress dialog
    ProgressDialog.show(context, message: "Fetching delivery options...");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            deliveryMethods = data['data'];
            isLoading = false;
          });
        } else {
          _showErrorSnackBar("Failed to load options: ${data['message']}");
        }
      } else {
        _showErrorSnackBar("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorSnackBar("Network error. Please check your connection.");
    } finally {
      // Hide progress dialog
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

  IconData _getIconForType(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'standard':
        return Icons.local_shipping_outlined;
      case 'express':
        return Icons.bolt_rounded;
      case 'click & collect':
        return Icons.store_mall_directory_outlined;
      default:
        return Icons.delivery_dining_outlined;
    }
  }

  Color _getColorForType(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'standard':
        return const Color(0xFF3B82F6);
      case 'express':
        return const Color(0xFFF59E0B);
      case 'click & collect':
        return const Color(0xFF10B981);
      default:
        return Colors.blueGrey;
    }
  }

  String _getETAFake(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'standard':
        return '3 - 5 Business Days';
      case 'express':
        return 'Same Day before 3 PM';
      case 'click & collect':
        return 'Ready in 2 Hours';
      default:
        return 'Check details';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // Subtle background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.03),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 140.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFFF9FAFB).withOpacity(0.9),
                centerTitle: false,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 20, color: Color(0xFF111827)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
                  title: Text(
                    'Delivery Method',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      fontSize: 24,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: fetchDeliveryMethods,
                    icon: const Icon(Icons.refresh, color: Color(0xFF111827)),
                  )
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // const SizedBox(height: 8),
                    // Text(
                    //   'Choose a delivery service that fits your schedule.',
                    //   style: GoogleFonts.outfit(
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w400,
                    //     color: const Color(0xFF6B7280),
                    //   ),
                    // ),
                    // const SizedBox(height: 32),

                    if (isLoading && deliveryMethods.isEmpty)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: Text("Loading delivery options..."),
                      ))
                    else if (deliveryMethods.isEmpty)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: Text("No delivery options available."),
                      ))
                    else
                      ...deliveryMethods
                          .map((method) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _ProfessionalDeliveryCard(
                                  title: method['orderTypeName'] ?? 'Delivery',
                                  description: method['instruction'] ??
                                      'Priority handling',
                                  eta: _getETAFake(
                                      method['orderTypeName'] ?? ''),
                                  icon: _getIconForType(
                                      method['orderTypeName'] ?? ''),
                                  accentColor: _getColorForType(
                                      method['orderTypeName'] ?? ''),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderStatusTabsScreen(
                                          orderTypeId: method['orderTypeId'],
                                          orderTypeName:
                                              method['orderTypeName'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ))
                          .toList(),

                    const SizedBox(height: 32),

                    // Support Information Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF9CA3AF), size: 22),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Delivery availability may vary based on your location and store stock.',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: const Color(0xFF6B7280),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfessionalDeliveryCard extends StatelessWidget {
  final String title;
  final String description;
  final String eta;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _ProfessionalDeliveryCard({
    required this.title,
    required this.description,
    required this.eta,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon Box
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: accentColor),
                          const SizedBox(width: 6),
                          Text(
                            eta,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFD1D5DB),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
