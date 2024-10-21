import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Generic POST request method
  Future<Map<String, dynamic>> postData({
    required String endpoint,
    required dynamic data,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: headers ?? _defaultHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception("No Internet Connection");
    } on FormatException {
      throw Exception("Bad response format");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // Generic GET request method
  Future<Map<String, dynamic>> getData({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(
        url,
        headers: headers ?? _defaultHeaders(),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception("No Internet Connection");
    } on FormatException {
      throw Exception("Bad response format");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // Default headers for all requests
  Map<String, String> _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Handle the API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode == 200 || statusCode == 201) {
      // Success response
      return jsonDecode(response.body);
    } else if (statusCode == 400) {
      throw Exception("Bad Request: ${response.body}");
    } else if (statusCode == 401) {
      throw Exception("Unauthorized: ${response.body}");
    } else if (statusCode == 500) {
      throw Exception("Internal Server Error: ${response.body}");
    } else {
      throw Exception("Unexpected Error: ${response.body}");
    }
  }
}
