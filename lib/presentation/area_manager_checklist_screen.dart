import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../controllers/area_manager_checklist_controller.dart';
import 'SectionDetailsScreen.dart';


class AreaManagerChecklistScreen extends StatefulWidget {
  @override
  State<AreaManagerChecklistScreen> createState() => _AreaManagerChecklistScreenState();
}

class _AreaManagerChecklistScreenState extends State<AreaManagerChecklistScreen> {
  final AreaManagerChecklistController controller = Get.put(AreaManagerChecklistController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fetchChecklist();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Area Manager Checklist')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Checklist ID: ${controller.checklistData['amChecklistId']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.sections.length,

                  itemBuilder: (context, index) {
                    var section = controller.sections[index];
                    return Card(

                      child: ListTile(
                        onTap: () {
                          Get.to(() => SectionDetailsScreen(sectionId: section['sectionId'], amChecklistId: '777052324900018', createdBy: '70003',),);
                        },
                        title: Text(section['sectionName']),
                        subtitle: Text('Completion Status: ${section['section_completion_status'] ?? 'Pending'}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
