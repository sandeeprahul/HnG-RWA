import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../data/UserLocations.dart';

class LocationPopup extends StatefulWidget {
  final List<UserLocations> locations;
  final Function(UserLocations) onLocationSelected;

  const LocationPopup({super.key, required this.locations, required this.onLocationSelected});

  @override
  _LocationPopupState createState() => _LocationPopupState();
}

class _LocationPopupState extends State<LocationPopup> {
  TextEditingController searchController = TextEditingController();
  List<UserLocations> filteredLocations = [];

  @override
  void initState() {
    super.initState();
    filteredLocations = widget.locations;
  }

  void filterSearch(String query) {
    setState(() {
      filteredLocations = widget.locations
          .where((location) =>
      location.locationName.toLowerCase().contains(query.toLowerCase()) ||
          location.locationCode.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> checkAndSelectLocation(UserLocations location) async {
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    double distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      double.parse(location.latitude),
      double.parse(location.longitude),
    );

    if (distance <= 100) {
      // If within 100 meters, proceed
      Navigator.pop(context);
      widget.onLocationSelected(location);
    } else {
      // Show alert if outside range
      Get.snackbar('Out of Range', 'You are ${distance.toStringAsFixed(2)} meters away. Please select a closer location.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const Text('Select Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(hintText: "Search", suffixIcon: Icon(Icons.search)),
              onChanged: filterSearch,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: filteredLocations.length,
                itemBuilder: (context, index) {
                  final location = filteredLocations[index];
                  return ListTile(
                    title: Text(location.locationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Code: ${location.locationCode} | ${location.latitude}, ${location.longitude}', style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                    onTap: () => checkAndSelectLocation(location),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
