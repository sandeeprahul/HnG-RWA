import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';

class StaffMovementReasonRepository {
  final String baseUrl = 'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/StaffMovement/GetStaffmovementreason';

  Future<List<String>> getStaffMovementReasons() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final reasons = data.map((item) => item.toString()).toList();
      return reasons;
    } else {
      throw Exception('Failed to load staff movement reasons');
    }
  }
}
