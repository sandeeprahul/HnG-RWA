class AmHeaderQuestion {
    AmHeaderQuestion({
        required this.checklistAssignId,
        required this.checklisTItemMstId,
        required this.itemName,
        required this.itemWeightage,
        required this.updatedBy,
        required this.updatedByDatetime,
        required this.checklistApplicableType,
        required this.checklistProgressStatus,
        required this.checklistEditStatus,
        required this.non_compliance_flag,
        required this.updated_By_Name,
        // required this.image_Name,
        required this.checkListDetails,
    });

    int checklistAssignId;
    int checklisTItemMstId;
    String itemName;
    String itemWeightage;
    int updatedBy;
    String updatedByDatetime;
    String checklistApplicableType;
    String checklistProgressStatus;
    String checklistEditStatus;
    String non_compliance_flag;
    String updated_By_Name;
    List<CheckListDetail> checkListDetails;

    factory AmHeaderQuestion.fromJson(Map<String, dynamic> json) => AmHeaderQuestion(
        checklistAssignId: json["checklist_assign_id"],
        checklisTItemMstId: json["checklisT_ITEM_MST_ID"],
        itemName: json["item_name"],
        itemWeightage: json["item_weightage"],
        updatedBy: json["updated_by"],
        updatedByDatetime: json["updated_by_datetime"],
        checklistApplicableType: json["checklist_applicable_type"],
        checklistProgressStatus:json["checklist_progress_status"],
        checklistEditStatus: json["checklist_edit_status"],
        non_compliance_flag: json["non_compliance_flag"]??'0',
        updated_By_Name: json["updated_By_Name"]??'0',
        // image_Name: json["image_Name"]??'',
        checkListDetails: List<CheckListDetail>.from(json["check_list_details"].map((x) => CheckListDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "checklist_assign_id": checklistAssignId,
        "checklisT_ITEM_MST_ID": checklisTItemMstId,
        "item_name": itemName,
        "item_weightage": itemWeightage,
        "updated_by": updatedBy,
        "updated_by_datetime": updatedByDatetime,
        "checklist_applicable_type": checklistApplicableType,
        "checklist_progress_status": checklistProgressStatus,
        "checklist_edit_status": checklistEditStatus,
        "non_compliance_flag": non_compliance_flag,
        "updated_By_Name": updated_By_Name,
        // "image_Name": image_Name,
    "check_list_details": List<dynamic>.from(checkListDetails.map((x) => x.toJson())),
    };
}

class CheckListDetail {
    CheckListDetail({
        required this.checklisTItemMstId,
        required this.checklisTAnswerId,
        required this.question,
        required this.answerTypeId,
        required this.checklisTAnswerOptionId,
        required this.answerOption,
        required this.weCareFlag,
        required this.image_Name,
        required this.checklistAssignId,
        // String image_Name;

        required this.updatedBy,
        required this.updatedByDatetime,
        required this.checklistEditStatus,
        required this.imageSeqId,
        required this.checklistDetailImages,
    });

    int checklisTItemMstId;
    int checklisTAnswerId;
    String question;
    int answerTypeId;
    int checklisTAnswerOptionId;
    String answerOption;
    int weCareFlag;
    int checklistAssignId;
    int updatedBy;
    String updatedByDatetime;
    String image_Name;
    String checklistEditStatus;
    int imageSeqId;
    List<ChecklistDetailImage> checklistDetailImages;

    factory CheckListDetail.fromJson(Map<String, dynamic> json) => CheckListDetail(
        checklisTItemMstId: json["checklisT_ITEM_MST_ID"],
        checklisTAnswerId: json["checklisT_ANSWER_ID"],
        question: json["question"],
        answerTypeId: json["answer_type_id"],
        checklisTAnswerOptionId: json["checklisT_ANSWER_OPTION_ID"],
        answerOption: json["answer_option"],
        weCareFlag: json["we_care_flag"],
        checklistAssignId: json["checklist_assign_id"],
        updatedBy: json["updated_by"],
        updatedByDatetime: json["updated_by_datetime"],
        checklistEditStatus: json["checklist_edit_status"],
        imageSeqId: json["image_Seq_Id"],
        image_Name: json["image_Name"],
        checklistDetailImages: List<ChecklistDetailImage>.from(json["checklist_Detail_Images"].map((x) => ChecklistDetailImage.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "checklisT_ITEM_MST_ID": checklisTItemMstId,
        "checklisT_ANSWER_ID": checklisTAnswerId,
        "question": question,
        "answer_type_id": answerTypeId,
        "checklisT_ANSWER_OPTION_ID": checklisTAnswerOptionId,
        "answer_option": answerOption,
        "we_care_flag": weCareFlag,
        "checklist_assign_id": checklistAssignId,
        "updated_by": updatedBy,
        "updated_by_datetime": updatedByDatetime,
        "checklist_edit_status": checklistEditStatus,
        "image_Seq_Id": imageSeqId,
        "image_Name": image_Name,
        "checklist_Detail_Images": List<dynamic>.from(checklistDetailImages.map((x) => x.toJson())),
    };
}


class ChecklistDetailImage {
    ChecklistDetailImage({
        required this.seqNo,
        required this.checklistAssignId,
        required this.checklisTItemMstId,
        required this.checklistId,
        required this.questionId,
        required this.question,
        required this.checKlIstAnswerOptionId,
        required this.answerId,
        required this.imageNo,
        required this.imageUrl,
        required this.updatedDate,
    });

    int seqNo;
    int checklistAssignId;
    int checklisTItemMstId;
    int checklistId;
    int questionId;
    String question;
    int checKlIstAnswerOptionId;
    int answerId;
    int imageNo;
    String imageUrl;
    String updatedDate;

    factory ChecklistDetailImage.fromJson(Map<String, dynamic> json) => ChecklistDetailImage(
        seqNo: json["seqNo"],
        checklistAssignId: json["checklist_assign_id"],
        checklisTItemMstId: json["checklisT_ITEM_MST_ID"],
        checklistId: json["checklist_id"],
        questionId: json["question_Id"],
        question: json["question"],
        checKlIstAnswerOptionId: json["checKlIST_ANSWER_OPTION_ID"],
        answerId: json["answer_id"],
        imageNo: json["image_no"],
        imageUrl: json["imageUrl"],
        updatedDate: json["updatedDate"],
    );

    Map<String, dynamic> toJson() => {
        "seqNo": seqNo,
        "checklist_assign_id": checklistAssignId,
        "checklisT_ITEM_MST_ID": checklisTItemMstId,
        "checklist_id": checklistId,
        "question_Id": questionId,
        "question": question,
        "checKlIST_ANSWER_OPTION_ID": checKlIstAnswerOptionId,
        "answer_id": answerId,
        "image_no": imageNo,
        "imageUrl": imageUrl,
        "updatedDate": updatedDate,
    };
}