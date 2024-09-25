class Answeroption {
    int checkListAnswerOptionId;
    String answerOption;
    String weCareFlag;
    String nonComplianceFlag;
    String optionMandatoryFlag;

    Answeroption({
        required this.checkListAnswerOptionId,
        required this.answerOption,
        required this.weCareFlag,
        required this.nonComplianceFlag,
        required this.optionMandatoryFlag,
    });

    factory Answeroption.fromJson(Map<String, dynamic> json) => Answeroption(
        checkListAnswerOptionId: json["checkList_Answer_Option_Id"],
        answerOption: json["answer_Option"],
        weCareFlag: json["we_Care_Flag"],
        nonComplianceFlag: json["non_Compliance_Flag"],
        optionMandatoryFlag: json["option_mandatory_Flag"],
    );

    Map<String, dynamic> toJson() => {
        "checkList_Answer_Option_Id": checkListAnswerOptionId,
        "answer_Option": answerOption,
        "we_Care_Flag": weCareFlag,
        "non_Compliance_Flag": nonComplianceFlag,
        "option_mandatory_Flag": optionMandatoryFlag,
    };
}