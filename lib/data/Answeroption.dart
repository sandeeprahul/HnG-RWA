class Answeroption {
    int checkListAnswerOptionId;
    String answerOption;
    String answerOptionID;
    String weCareFlag;
    String nonComplianceFlag;
    String optionMandatoryFlag;
    String score;

    Answeroption({
        required this.checkListAnswerOptionId,
        required this.answerOption,
        required this.answerOptionID,
        required this.weCareFlag,
        required this.nonComplianceFlag,
        required this.optionMandatoryFlag,
        required this.score,
    });

    factory Answeroption.fromJson(Map<String, dynamic> json) => Answeroption(
        checkListAnswerOptionId: json["checkList_Answer_Option_Id"]??-1,
        answerOptionID: json["answer_Option_id"]??'',
        answerOption: json["answer_Option"]??'',
        weCareFlag: json["we_Care_Flag"]??'',
        nonComplianceFlag: json["non_Compliance_Flag"]??'',
        optionMandatoryFlag: json["option_mandatory_Flag"]??'',
        score: json["score"]??'',
    );

    Map<String, dynamic> toJson() => {
        "checkList_Answer_Option_Id": checkListAnswerOptionId,
        "answer_Option": answerOption,
        "answerOptionID": answerOptionID,
        "we_Care_Flag": weCareFlag,
        "non_Compliance_Flag": nonComplianceFlag,
        "option_mandatory_Flag": optionMandatoryFlag,
        "score": score,
    };
}