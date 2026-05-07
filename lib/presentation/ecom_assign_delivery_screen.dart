import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../controllers/delivery_controller.dart';
import '../controllers/ecom_order_details_controller.dart';

class EcomAssignDeliveryScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String locationCode;

  const EcomAssignDeliveryScreen({
    super.key,
    required this.order,
    required this.locationCode,
  });

  @override
  State<EcomAssignDeliveryScreen> createState() => _EcomAssignDeliveryScreenState();
}

class _EcomAssignDeliveryScreenState extends State<EcomAssignDeliveryScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final minsController = TextEditingController();
  final DeliveryController deliveryController = Get.put(DeliveryController());
  final EcomOrderDetailsController ecomController = Get.put(EcomOrderDetailsController());

  void _handleHandover() async {
    bool success = await ecomController.updateHandedOverToCustomer(widget.order['orderId']);
    if (success) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Out For Delivery — ${widget.order['orderId']}",
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Slot Info Box matching the design
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_filled, size: 18, color: Colors.orange.withOpacity(0.7)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Slot: Tomorrow 9AM – 1PM (read-only)",
                        style: GoogleFonts.outfit(
                          color: Colors.orange[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel("DELIVERY EXECUTIVE NAME"),
              _buildTextField(nameController, "Rajan Kumar"),
              const SizedBox(height: 20),
              _buildLabel("MOBILE NUMBER"),
              _buildTextField(mobileController, "+91 98765 43210", isPhone: true),
              const SizedBox(height: 20),
              _buildLabel("ESTIMATED DELIVERY (MINUTES)"),
              _buildTextField(minsController, "45 min", isPhone: true),
              const SizedBox(height: 32),
              if (widget.order['status']?.toString().toUpperCase() == 'OUT_FOR_DELIVERY') ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Obx(() => ElevatedButton(
                    onPressed: ecomController.isLoading.value ? null : _handleHandover,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: ecomController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "HANDOVER TO CUSTOMER",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                  )),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: deliveryController.isLoading.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: deliveryController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("🚚 ", style: TextStyle(fontSize: 20)),
                            Text(
                              widget.order['status']?.toString().toUpperCase() == 'OUT_FOR_DELIVERY'
                                  ? "UPDATE ASSIGNMENT"
                                  : "OUT FOR DELIVERY",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                )),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPhone = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.orange, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  void _submit() {
    if (nameController.text.isEmpty || mobileController.text.isEmpty || minsController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }
    
    // Clean minutes input to extract only numbers
    int minutes = int.tryParse(minsController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;

    deliveryController.submitDeliveryDetails(
      name: nameController.text,
      mobile: mobileController.text,
      minutes: minutes,
      orderId: widget.order['orderId'],
      locationCode: widget.locationCode,
    );
  }
}
