class ChecklistItem {
  int checkListItemId;
  int checklistId;
  String itemName;
  String questionStatus;
  String questionEditStatus;
  List<Question> questions;

  ChecklistItem({
    required this.checkListItemId,
    required this.checklistId,
    required this.itemName,
    required this.questionStatus,
    required this.questionEditStatus,
    required this.questions,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      checkListItemId: json['checkList_Item_Id'],
      checklistId: json['checklist_id'],
      itemName: json['item_name'],
      questionStatus: json['questionstatus'],
      questionEditStatus: json['questioneditstatus'],
      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
    );
  }
}

class Question {
  String checkListAnswerId;
  String question;
  int answerTypeId;
  List<AnswerOption> options;
  int? selectedOption; // Stores selected answer option ID

  Question({
    required this.checkListAnswerId,
    required this.question,
    required this.answerTypeId,
    required this.options,
    this.selectedOption,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      checkListAnswerId: json["checkList_Answer_Id"],
      question: json["question"],
      answerTypeId: json["answer_Type_Id"],
      options: (json["options"] as List)
          .map((option) => AnswerOption.fromJson(option))
          .toList(),
    );
  }
}

class AnswerOption {
  int checkListAnswerOptionId;
  String answerOption;

  // String answer_Option_id;
  String weCareFlag;
  String nonComplianceFlag;
  String optionMandatoryFlag;

  AnswerOption({
    required this.checkListAnswerOptionId,
    required this.answerOption,
    required this.weCareFlag,
    required this.nonComplianceFlag,
    required this.optionMandatoryFlag,
    // required this.answer_Option_id,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      checkListAnswerOptionId: json['checkList_Answer_Option_Id'],
      answerOption: json['answer_Option'],
      weCareFlag: json['we_Care_Flag'],
      nonComplianceFlag: json['non_Compliance_Flag'],
      optionMandatoryFlag: json['option_mandatory_Flag'],
      // answer_Option_id: json['answer_Option_id'],
    );
  }
}
