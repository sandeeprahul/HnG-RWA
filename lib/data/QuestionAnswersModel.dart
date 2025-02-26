class QuestionAnswersModel {
  final int checkListItemId;
  final int checklistId;
  final String itemName;
  final String questionStatus;
  final String questionEditStatus;
  final String departmentName;
  final List<Question> questions;

  QuestionAnswersModel({
    required this.checkListItemId,
    required this.checklistId,
    required this.itemName,
    required this.questionStatus,
    required this.questionEditStatus,
    required this.departmentName,
    required this.questions,
  });

  factory QuestionAnswersModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnswersModel(
      checkListItemId: json['checkList_Item_Id'],
      checklistId: json['checklist_id'],
      itemName: json['item_name'] ?? '',
      questionStatus: json['questionstatus'] ?? '',
      questionEditStatus: json['questioneditstatus'] ?? '',
      departmentName: json['department_Name'] ?? '',
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

class Question {
  final String checkListAnswerId;
  final String question;
  final int answerTypeId;
  final String posBosFlag;
  final String mandatoryFlag;
  final String orderFlag;
  final List<AnswerOption> options;

  Question({
    required this.checkListAnswerId,
    required this.question,
    required this.answerTypeId,
    required this.posBosFlag,
    required this.mandatoryFlag,
    required this.orderFlag,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      checkListAnswerId: json['checkList_Answer_Id'] ?? '',
      question: json['question'] ?? '',
      answerTypeId: json['answer_Type_Id'] ?? 0,
      posBosFlag: json['pos_Bos_Flag'] ?? '',
      mandatoryFlag: json['mandatory_Flag'] ?? '',
      orderFlag: json['order_Flag'] ?? '',
      options: (json['options'] as List)
          .map((opt) => AnswerOption.fromJson(opt))
          .toList(),
    );
  }
}

class AnswerOption {
  final int checkListAnswerOptionId;
  final String answerOption;
  final String answerOptionId;
  final String weCareFlag;
  final String nonComplianceFlag;
  final String optionMandatoryFlag;

  AnswerOption({
    required this.checkListAnswerOptionId,
    required this.answerOption,
    required this.answerOptionId,
    required this.weCareFlag,
    required this.nonComplianceFlag,
    required this.optionMandatoryFlag,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      checkListAnswerOptionId: json['checkList_Answer_Option_Id'] ?? 0,
      answerOption: json['answer_Option'] ?? '',
      answerOptionId: json['answer_Option_id'] ?? '',
      weCareFlag: json['we_Care_Flag'] ?? '',
      nonComplianceFlag: json['non_Compliance_Flag'] ?? '',
      optionMandatoryFlag: json['option_mandatory_Flag'] ?? '',
    );
  }
}
