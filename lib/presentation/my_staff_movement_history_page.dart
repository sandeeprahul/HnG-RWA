import 'dart:convert';

import 'package:flutter/material.dart';


import 'package:flutter/material.dart';
import 'package:hng_flutter/data/myStaffMovementData.dart';
import 'package:hng_flutter/presentation/profile/staff_movement_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/my_staff_movement_history_entity.dart';
import '../widgets/my_staff_movement_history_card.dart';
import '../widgets/staff_movement_card.dart';

class MyStaffMovementHistoryPage extends StatefulWidget {
  const MyStaffMovementHistoryPage({super.key});

  @override
  State<MyStaffMovementHistoryPage> createState() =>
      _MyStaffMovementHistoryPageState();
}

class _MyStaffMovementHistoryPageState
    extends State<MyStaffMovementHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Movement Data'),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<MyStaffMovementHistoryEntity>>(
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
                      return StaffMovementHistoryCard(staffData: staffData[index]);
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

        ],
      ),
      // floatingActionButton: ElevatedButton(onPressed: () {  },child: Text('Staff Apply'),),
    );
  }

  Stream<List<MyStaffMovementHistoryEntity>> fetchStaffMovementData() async* {
    while (true) {
      try {
        final prefs = await SharedPreferences.getInstance();

        var userID = prefs.getString('userCode') ?? '105060';
        final response = await http.get(
          Uri.parse(
              'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/StaffMovement/Staff_In_Out_Detail/$userID'),
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final staffData = List<MyStaffMovementHistoryEntity>.from(
            data.map((reasonData) => MyStaffMovementHistoryEntity.fromJson(reasonData)),
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