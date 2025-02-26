import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ChecklistController.dart';

class ChecklistScreen extends StatefulWidget {
  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final ChecklistController controller = Get.put(ChecklistController(
      checklistId: 777052324900018, sectionId: 1613, createdBy: 70003));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checklist Questions')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.allQuestions.isEmpty) {
          return Center(child: Text("No questions available"));
        }

        var currentQuestion =
            controller.allQuestions[controller.currentQuestionIndex.value];

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentQuestion.question,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Column(
                children: currentQuestion.options.map((option) {
                  return RadioListTile<int>(
                    title: Text(option.answerOption),
                    value: option.checkListAnswerOptionId,
                    groupValue: currentQuestion.selectedOption,
                    onChanged: (value) {
                      setState(() {
                        currentQuestion.selectedOption =
                            value; // Update selected option
                      });
                      controller.update(); // Refresh UI
                    },
                  );
                }).toList(),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*  if (controller.currentQuestionIndex.value > 0)
                    ElevatedButton(
                      onPressed: controller.previousQuestion,
                      child: Text("Previous"),
                    ),*/
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: MediaQuery.of(context).size.width / 1.2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        onPressed: controller.nextQuestion,
                        child: Text(
                          controller.isLastQuestion() ? "Submit" : "Next",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
