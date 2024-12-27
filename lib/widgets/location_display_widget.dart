import 'package:flutter/material.dart';

class LocationDisplay extends StatelessWidget {
  final String locationCode;
  final String locationName;

  const LocationDisplay({
    super.key,
    required this.locationCode,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      // elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            const Icon(Icons.location_on,color: Colors.blueGrey,),
            Text(
              locationName,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(width: 12), // Space between labels and values
            Text(
              locationCode,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 4), // Space between rows

          ],
        ),
      ),
    );
  }
}
