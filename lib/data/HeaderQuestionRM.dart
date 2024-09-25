// To parse this JSON data, do
//
//     final headerQuestionRm = headerQuestionRmFromJson(jsonString);

import 'dart:convert';

// List<HeaderQuestionRm> headerQuestionRmFromJson(String str) => List<HeaderQuestionRm>.from(json.decode(str).map((x) => HeaderQuestionRm.fromJson(x)));
//
// String headerQuestionRmToJson(List<HeaderQuestionRm> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HeaderQuestionRM {
  int lpdChecklistAssignId;
  int checklisTItemMstId;
  String itemName;
  String itemWeightage;
  int updatedBy;
  String updatedByDatetime;
  String checklistApplicableType;
  String checklistProgressStatus;
  String checklistEditStatus;
  String nonComplianceFlag;
  List<CheckListDetail> checkListDetails;

  HeaderQuestionRM({
    required this.lpdChecklistAssignId,
    required this.checklisTItemMstId,
    required this.itemName,
    required this.itemWeightage,
    required this.updatedBy,
    required this.updatedByDatetime,
    required this.checklistApplicableType,
    required this.checklistProgressStatus,
    required this.checklistEditStatus,
    required this.nonComplianceFlag,
    required this.checkListDetails,
  });

  factory HeaderQuestionRM.fromJson(Map<String, dynamic> json) => HeaderQuestionRM(
    lpdChecklistAssignId: json["lpd_checklist_assign_id"],
    checklisTItemMstId: json["checklisT_ITEM_MST_ID"],
    itemName: json["item_name"],
    itemWeightage: json["item_weightage"],
    updatedBy: json["updated_by"],
    updatedByDatetime: json["updated_by_datetime"],
    checklistApplicableType: json["checklist_applicable_type"]!,
    checklistProgressStatus: json["checklist_progress_status"]!,
    checklistEditStatus:json["checklist_edit_status"]!,
    nonComplianceFlag: json["non_compliance_flag"],
    checkListDetails: List<CheckListDetail>.from(json["check_list_details"].map((x) => CheckListDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "lpd_checklist_assign_id": lpdChecklistAssignId,
    "checklisT_ITEM_MST_ID": checklisTItemMstId,
    "item_name": itemName,
    "item_weightage": itemWeightage,
    "updated_by": updatedBy,
    "updated_by_datetime": updatedByDatetime,
    "checklist_applicable_type": checklistApplicableType,
    "checklist_progress_status": checklistProgressStatus,
    "checklist_edit_status":checklistEditStatus,
    "non_compliance_flag": nonComplianceFlag,
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
  int lpdChecklistAssignId;
  int updatedBy;
  String updatedByDatetime;
  String checklistEditStatus;
  int imageSeqId;
  String imageName;
  List<dynamic> checklistDetailImages;

  CheckListDetail({
    required this.checklisTItemMstId,
    required this.checklisTAnswerId,
    required this.question,
    required this.answerTypeId,
    required this.checklisTAnswerOptionId,
    required this.answerOption,
    required this.weCareFlag,
    required this.lpdChecklistAssignId,
    required this.updatedBy,
    required this.updatedByDatetime,
    required this.checklistEditStatus,
    required this.imageSeqId,
    required this.imageName,
    required this.checklistDetailImages,
  });

  factory CheckListDetail.fromJson(Map<String, dynamic> json) => CheckListDetail(
    checklisTItemMstId: json["checklisT_ITEM_MST_ID"],
    checklisTAnswerId: json["checklisT_ANSWER_ID"],
    question: json["question"],
    answerTypeId: json["answer_type_id"],
    checklisTAnswerOptionId: json["checklisT_ANSWER_OPTION_ID"],
    answerOption: json["answer_option"],
    weCareFlag: json["we_care_flag"],
    lpdChecklistAssignId: json["lpd_checklist_assign_id"],
    updatedBy: json["updated_by"],
    updatedByDatetime: json["updated_by_datetime"],
    checklistEditStatus: json["checklist_edit_status"],
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
    "lpd_checklist_assign_id": lpdChecklistAssignId,
    "updated_by": updatedBy,
    "updated_by_datetime": updatedByDatetime,
    "checklist_edit_status": checklistEditStatus,
    "image_Seq_Id": imageSeqId,
    "image_Name": imageName,
    "checklist_Detail_Images": List<dynamic>.from(checklistDetailImages.map((x) => x)),
  };
}

