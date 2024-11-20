import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hng_flutter/data/myStaffMovementData.dart';
import 'package:hng_flutter/presentation/profile/staff_movement_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/staff_movement_card.dart';

class MyStaffMovementAppliedPage extends StatefulWidget {
  const MyStaffMovementAppliedPage({super.key});

  @override
  State<MyStaffMovementAppliedPage> createState() =>
      _MyStaffMovementAppliedPageState();
}

class _MyStaffMovementAppliedPageState
    extends State<MyStaffMovementAppliedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Movement Data'),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<MyStaffMovementData>>(
            stream: fetchStaffMovementData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error.toString()}'),
                );
              } else if (snapshot.hasData) {
                final staffData = snapshot.data!;

                if (staffData.isEmpty) {
                  return const Center(
                    child: Text('No data found.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: staffData.length,
                    itemBuilder: (context, index) {
                      return StaffMovementCard(staffData: staffData[index]);
                    },
                  );
                }
              } else {
                return const Center(
                  child: Text('No data available.'),
                );
              }
            },
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StaffMovementPage()));
                      },
                      child: const Text('Staff Apply'),
                    )),
              ))
        ],
      ),
      // floatingActionButton: ElevatedButton(onPressed: () {  },child: Text('Staff Apply'),),
    );
  }

  Stream<List<MyStaffMovementData>> fetchStaffMovementData() async* {
    while (true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        var userId = prefs.getString("userCode");
        var locationCode = prefs.getString('locationCode') ?? '106';
        final response = await http.get(
          Uri.parse(
              'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/StaffMovement/GetStaff_IN_OUT_Details/$userId/$locationCode'),
        );
        print('https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/StaffMovement/GetStaff_IN_OUT_Details/$userId/$locationCode');

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final staffData = List<MyStaffMovementData>.from(
            data.map((reasonData) => MyStaffMovementData.fromJson(reasonData)),
          );
          yield staffData;
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        yield* Stream.error(e); // Emit an error through the stream
      }
      // await Future.delayed(const Duration(seconds: 10)); // Simulate data updates
    }
  }


}
