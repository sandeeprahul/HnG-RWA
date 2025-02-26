import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/section_details_controller.dart';
import 'ChecklistQuestionScreen.dart';

class SectionDetailsScreen extends StatelessWidget {
  final String amChecklistId;
  final String sectionId;
  final String createdBy;

  final SectionDetailsController controller = Get.put(SectionDetailsController());

  SectionDetailsScreen({
    required this.amChecklistId,
    required this.sectionId,
    required this.createdBy,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch section details when the screen is opened
    controller.fetchSectionDetails(amChecklistId, sectionId, createdBy);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Section Details'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Checklist Status: ${controller.checklistStatus.value}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Total Questions: ${controller.totalQuestions.value}"),
              Text("Completed Questions: ${controller.completedQuestions.value}"),
              SizedBox(height: 16),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.questions.length,
                  itemBuilder: (context, index) {
                    var question = controller.questions[index];
                    return Card(
                      child: ListTile(
                        title: Text(question['item_name'] ?? "No Name"),
                        subtitle: Text("Status: ${question['checklist_progress_status'] ?? 'Unknown'}"),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // Navigate to question details screen if needed
                          Get.to(() => ChecklistScreen(
                            // checklistId: amChecklistId,
                            // sectionId: sectionId,
                            // createdBy: createdBy,
                          ));
                        },
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
