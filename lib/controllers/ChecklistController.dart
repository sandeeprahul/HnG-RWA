import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../data/CheckListItem.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChecklistController extends GetxController {
  RxList<Question> allQuestions = <Question>[].obs;
  RxInt currentQuestionIndex = 0.obs;
  RxBool isLoading = false.obs;

  final int checklistId;
  final int sectionId;
  final int createdBy;

  ChecklistController({
    required this.checklistId,
    required this.sectionId,
    required this.createdBy,
  });

  @override
  void onInit() {
    super.onInit();
    fetchChecklist();
  }

  /// Fetch checklist data from API
  void fetchChecklist() async {
    isLoading(true);
    try {
      final response = await http.get(Uri.parse(
        "https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/AreaManager/QuestionAnswers/777052324900018/1613/P/70003",
      ));

      print("Fetching Checklist Data...");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Extract questions from checklist items
        List<Question> extractedQuestions = [];
        for (var item in data) {
          if (item["questions"] != null) {
            extractedQuestions.addAll(
              (item["questions"] as List).map((q) => Question.fromJson(q)),
            );
          }
        }

        allQuestions.assignAll(extractedQuestions);
        print("Checklist Loaded: ${allQuestions.length} questions");
      } else {
        Get.snackbar("Error", "Failed to fetch checklist data");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Submit the current answer and move to the next question
  void nextQuestion() async {
    Question currentQuestion = allQuestions[currentQuestionIndex.value];
    AnswerOption? selectedOption = currentQuestion.options.firstWhereOrNull(
            (option) => option.checkListAnswerOptionId == currentQuestion.selectedOption);

    if (selectedOption == null) {
      Get.snackbar("Error", "Please select an answer before proceeding!");
      return;
    }

    await submitAnswer(currentQuestion, selectedOption); // Submit current answer

    if (currentQuestionIndex.value < allQuestions.length - 1) {
      currentQuestionIndex.value++; // Move to next question
    } /*else {
      Get.snackbar("Completed", "All questions answered!");
    }*/
  }

  /// Submit the selected answer to API
  Future<void> submitAnswer(Question question, AnswerOption selectedOption) async {
    try {
      var requestBody = [
        {
          "am_checklist_assign_id": 777052324900018,
          "checkList_Item_Mst_Id": 107,
          "checklist_Id": 107,
          "item_name": question.question,
          "checkList_Answer_Id": question.checkListAnswerId,
          "question": question.question,
          "answer_Type_Id": question.answerTypeId,
          "mandatory_Flag": 0,
          "active_Flag": 0,
          "checkList_Answer_Option_Id": selectedOption.checkListAnswerOptionId,
          "answer_Option": selectedOption.answerOption,
          "answer_Option_id": selectedOption.answerOption,
          "we_Care_Flag": selectedOption.weCareFlag,
          "non_Compliance_Flag": selectedOption.nonComplianceFlag,
          "pos_bos_flag": 0,
          "order_flag": 0,
          "checklist_assign_id": 0,
          "created_by": createdBy,
          "created_datetime": DateTime.now().toIso8601String(),
          "updated_by": createdBy,
          "updated_by_datetime": DateTime.now().toIso8601String(),
          "checklist_applicable_type": "",
          "checklist_progress_status": "",
          "checklist_edit_status": "",
          "questionstatus": "",
          "imagename": ""
        }
      ];

      final response = await http.post(
        Uri.parse("https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/AreaManager/AddQuestionAnswer"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      print("https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/AreaManager/AddQuestionAnswer");

      print(requestBody);
      print(response.body);
      if (response.statusCode == 200) {
        question.selectedOption = selectedOption.checkListAnswerOptionId;
        allQuestions.refresh();
      } else {
        Get.snackbar("Error", "Failed to submit answer");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    }
  }

  /// Check if the current question is the last one
  bool isLastQuestion() {
    return currentQuestionIndex.value == allQuestions.length - 1;
  }
}