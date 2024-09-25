class QuestionAnswers {
  QuestionAnswers({
    required this.checkListItemId,
    required this.checklistId,
    required this.itemName,
    required this.department_Name,
    this.questionstatus,
    required this.questions,
  });

  int checkListItemId;
  int checklistId;
  String itemName;
  String department_Name;
  dynamic questionstatus;
  List<Question> questions;

  factory QuestionAnswers.fromJson(Map<String, dynamic> json) => QuestionAnswers(
    checkListItemId: json["checkList_Item_Id"],
    checklistId: json["checklist_id"],
    itemName: json["item_name"],
    department_Name: json["department_Name"],
    questionstatus: json["questionstatus"],

    questions: List<Question>.from(json["questions"].map((x) => Question.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "checkList_Item_Id": checkListItemId,
    "checklist_id": checklistId,
    "item_name": itemName,
    "department_Name": department_Name,
    "questionstatus": questionstatus,
    "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
  };
}

class Question {
  Question({
    required this.checkListAnswerId,
    required this.question,
    required this.answerTypeId,
    required this.posBosFlag,
    required this.mandatoryFlag,
    required this.orderFlag,
    required this.options,
  });

  String checkListAnswerId;
  String question;
  int answerTypeId;
  String posBosFlag;
  String mandatoryFlag;
  String orderFlag;
  List<Option> options;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    checkListAnswerId: json["checkList_Answer_Id"],
    question: json["question"],
    answerTypeId: json["answer_Type_Id"],
    posBosFlag: json["pos_Bos_Flag"],
    mandatoryFlag: json["mandatory_Flag"],
    orderFlag: json["order_Flag"],
    options: List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "checkList_Answer_Id": checkListAnswerId,
    "question": question,
    "answer_Type_Id": answerTypeId,
    "pos_Bos_Flag": posBosFlag,
    "mandatory_Flag": mandatoryFlag,
    "order_Flag": orderFlag,
    "options": List<dynamic>.from(options.map((x) => x.toJson())),
  };
}

class Option {
  Option({
    required this.checkListAnswerOptionId,
    this.answerOption,
    required this.option_mandatory_Flag,
    required this.weCareFlag,
    required this.nonComplianceFlag,
  });

  int checkListAnswerOptionId;
  String? answerOption;
  String weCareFlag;
  String nonComplianceFlag;
  String option_mandatory_Flag;

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    checkListAnswerOptionId: json["checkList_Answer_Option_Id"],
    answerOption: json["answer_Option"],
    weCareFlag: json["we_Care_Flag"],
    nonComplianceFlag: json["non_Compliance_Flag"],
    option_mandatory_Flag: json["option_mandatory_Flag"],
  );

  Map<String, dynamic> toJson() => {
    "checkList_Answer_Option_Id": checkListAnswerOptionId,
    "answer_Option": answerOption,
    "we_Care_Flag": weCareFlag,
    "non_Compliance_Flag": nonComplianceFlag,
    "option_mandatory_Flag": option_mandatory_Flag,
  };
}
