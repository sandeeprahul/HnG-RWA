class AmHeaderQuestionEmployee {
    int empChecklistAssignId;
    int checklisTItemMstId;
    String itemName;
    String itemWeightage;
    int updatedBy;
    String updatedByDatetime;
    String checklistApplicableType;
    String checklistProgressStatus;
    String checklistEditStatus;
    String nonComplianceFlag;
    int employeeCode;
    String employeeName;
    List<CheckListDetail> checkListDetails;

    AmHeaderQuestionEmployee({
        required this.empChecklistAssignId,
        required this.checklisTItemMstId,
        required this.itemName,
        required this.itemWeightage,
        required this.updatedBy,
        required this.updatedByDatetime,
        required this.checklistApplicableType,
        required this.checklistProgressStatus,
        required this.checklistEditStatus,
        required this.nonComplianceFlag,
        required this.employeeCode,
        required this.employeeName,
        required this.checkListDetails,
    });

    factory AmHeaderQuestionEmployee.fromJson(Map<String, dynamic> json) => AmHeaderQuestionEmployee(
        empChecklistAssignId: json["emp_checklist_assign_id"],
        checklisTItemMstId: json["checklisT_ITEM_MST_ID"],
        itemName: json["item_name"]!,
        itemWeightage: json["item_weightage"],
        updatedBy: json["updated_by"],
        updatedByDatetime: json["updated_by_datetime"],
        checklistApplicableType: json["checklist_applicable_type"],
        checklistProgressStatus: json["checklist_progress_status"],
        checklistEditStatus: json["checklist_edit_status"],
        nonComplianceFlag: json["non_compliance_flag"],
        employeeCode: json["employee_code"],
        employeeName: json["employee_Name"],
        checkListDetails: List<CheckListDetail>.from(json["check_list_details"].map((x) => CheckListDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "emp_checklist_assign_id": empChecklistAssignId,
        "checklisT_ITEM_MST_ID": checklisTItemMstId,
        "item_name": itemName,
        "item_weightage": itemWeightage,
        "updated_by": updatedBy,
        "updated_by_datetime": updatedByDatetime,
        "checklist_applicable_type": checklistApplicableType,
        "checklist_progress_status": checklistProgressStatus,
        "checklist_edit_status": checklistEditStatus,
        "non_compliance_flag": nonComplianceFlag,
        "employee_code": employeeCode,
        "employee_Name": employeeName,
        "check_list_details": List<dynamic>.from(checkListDetails.map((x) => x.toJson())),
    };
}

class CheckListDetail {
    int checklisTItemMstId;
    int checklisTAnswerId;
    String question;
    int answerTypeId;
    int checklisTAnswerOptionId;
    String answerOption;
    int weCareFlag;
    int empChecklistAssignId;
    int updatedBy;
    String updatedByDatetime;
    String checklistEditStatus;
    int imageSeqId;
    dynamic imageName;
    List<dynamic> checklistDetailImages;

    CheckListDetail({
        required this.checklisTItemMstId,
        required this.checklisTAnswerId,
        required this.question,
        required this.answerTypeId,
        required this.checklisTAnswerOptionId,
        required this.answerOption,
        required this.weCareFlag,
        required this.empChecklistAssignId,
        required this.updatedBy,
        required this.updatedByDatetime,
        required this.checklistEditStatus,
        required this.imageSeqId,
        this.imageName,
        required this.checklistDetailImages,
    });

    factory CheckListDetail.fromJson(Map<String, dynamic> json) => CheckListDetail(
        checklisTItemMstId: json["checklisT_ITEM_MST_ID"],
        checklisTAnswerId: json["checklisT_ANSWER_ID"],
        question: json["question"]!,
        answerTypeId: json["answer_type_id"],
        checklisTAnswerOptionId: json["checklisT_ANSWER_OPTION_ID"],
        answerOption: json["answer_option"],
        weCareFlag: json["we_care_flag"],
        empChecklistAssignId: json["emp_checklist_assign_id"],
        updatedBy: json["updated_by"],
        updatedByDatetime: json["updated_by_datetime"]!,
        checklistEditStatus: json["checklist_edit_status"]!,
        imageSeqId: json["image_Seq_Id"],
        imageName: json["image_Name"],
        checklistDetailImages: List<dynamic>.from(json["checklist_Detail_Images"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "checklisT_ITEM_MST_ID": checklisTItemMstId,
        "checklisT_ANSWER_ID": checklisTAnswerId,
        "question": question,
        "answer_type_id": answerTypeId,
        "checklisT_ANSWER_OPTION_ID": checklisTAnswerOptionId,
        "answer_option": answerOption,
        "we_care_flag": weCareFlag,
        "emp_checklist_assign_id": empChecklistAssignId,
        "updated_by": updatedBy,
        "updated_by_datetime": updatedByDatetime,
        "checklist_edit_status": checklistEditStatus,
        "image_Seq_Id": imageSeqId,
        "image_Name": imageName,
        "checklist_Detail_Images": List<dynamic>.from(checklistDetailImages.map((x) => x)),
    };
}





