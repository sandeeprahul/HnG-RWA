import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationSearchDialog extends StatefulWidget {
  final String userId;

  const LocationSearchDialog({super.key, required this.userId});

  @override
  _LocationSearchDialogState createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  List<dynamic> locations = [];
  List<dynamic> filteredLocations = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString("userCode");

      final response = await http.get(
        // Uri.parse('https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Login/GetLocation/9999'),
        Uri.parse('https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Login/GetLocation/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          locations = data['locations'];
          filteredLocations = locations;
          isLoading = false; // Stop loading
        });
      } else {
        showError();
      }
    } catch (e) {
      showError();
    }
  }

  void showError() {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to load locations')),
    );
  }

  void filterSearch(String query) {
    setState(() {
      filteredLocations = locations
          .where((location) =>
      location['locationName']
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          location['locationCode']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Search Location"),
      content: SizedBox(
        width: double.maxFinite, // Ensures the AlertDialog takes full width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(fontSize: 15),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: filterSearch,
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
                : Expanded(
              child:filteredLocations.isNotEmpty? ListView.builder(
                itemCount: filteredLocations.length,
                itemBuilder: (context, index) {
                  final location = filteredLocations[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 4),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: index.isOdd
                          ? Colors.grey[200]
                          : Colors.transparent, // Alternating colors
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      child: Text(
                        "${location['locationName']}-${location['locationCode']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onTap: () {
                        Navigator.pop(context, location);
                      },
                    ),
                  );
                },
              ):const Center(child:
                Text('No data'),),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close",style:TextStyle(color: Colors.white) ,),
        ),
      ],
    );
  }
}
