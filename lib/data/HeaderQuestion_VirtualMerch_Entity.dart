class HeaderQuestionVirtualMerchEntity {
  HeaderQuestionVirtualMerchEntity({
    required this.vm_assign_id,
    required this.checklistItemMstId,
    required this.checklistId,
    required this.itemName,
    required this.startTime,
    required this.endTime,//{vm_assign_id}/{userid}
    required this.itemWeightage,
    required this.mandatoryFlag,
    required this.activeFlag,
    required this.departmentRequired,
    required this.departmentRatingRequired,
    required this.storeRatingRequired,
    // this.department,
    // this.sectionId,
    required this.createdBy,
    required this.createdDatetime,
    required this.updatedBy,
    required this.checklistApplicableType,
    required this.checklistProgressStatus,
    required this.checklistEditStatus,
    required this.non_compliance_flag,
    required this.updatedName,
    required this.updatedByDatetime,
    required this.branD_CODE,
    required this.branD_NAME,
    required this.elemenT_ID,
    required this.elemenT_NAME,
    required this.demO_URL,
  });

  int vm_assign_id;
  int checklistItemMstId;
  int checklistId;
  String itemName;
  String branD_CODE;
  String branD_NAME;
  String elemenT_ID;
  String elemenT_NAME;
  String demO_URL;
  String startTime;
  String endTime;
  int itemWeightage;
  int mandatoryFlag;
  int activeFlag;
  int departmentRequired;
  int departmentRatingRequired;
  int storeRatingRequired;
  dynamic department;
  dynamic sectionId;
  int createdBy;
  String createdDatetime;
  int updatedBy;
  String checklistApplicableType;
  String checklistProgressStatus;
  String checklistEditStatus;
  String non_compliance_flag;
  String updatedName;
  String updatedByDatetime;

  factory HeaderQuestionVirtualMerchEntity.fromJson(Map<String, dynamic> json) => HeaderQuestionVirtualMerchEntity(
    vm_assign_id: json["vm_assign_id"],
    checklistItemMstId: json["checklist_Item_Mst_Id"],
    checklistId: json["checklist_id"],
    itemName: json["item_name"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    itemWeightage: json["item_weightage"],
    mandatoryFlag: json["mandatory_flag"],
    activeFlag: json["active_flag"],
    departmentRequired: json["department_required"],
    departmentRatingRequired: json["department_rating_required"],
    storeRatingRequired: json["store_rating_required"],
    // department: json["department"],
    // sectionId: json["section_id"],
    createdBy: json["created_by"],
    createdDatetime: json["created_datetime"],
    updatedBy: json["updated_by"],
    checklistApplicableType: json["checklist_applicable_type"],
    checklistProgressStatus:json["checklist_progress_status"]!,
    checklistEditStatus: json["checklist_edit_status"],
    non_compliance_flag: json["non_compliance_flag"],
    updatedName: json["updatedName"],
    updatedByDatetime: json["updated_by_datetime"],
    branD_NAME: json["branD_NAME"],
    branD_CODE: json["branD_CODE"],
    elemenT_ID: json["elemenT_ID"],
    demO_URL: json["demO_URL"],
    elemenT_NAME: json["elemenT_NAME"],
    //required this.branD_CODE,
    //     required this.branD_NAME,
    //     required this.elemenT_ID,
    //     required this.elemenT_NAME,
    //     required this.demO_URL,
  );

  Map<String, dynamic> toJson() => {
    "vm_assign_id": vm_assign_id,
    "checklist_Item_Mst_Id": checklistItemMstId,
    "checklist_id": checklistId,
    "item_name": itemName,
    "start_time": startTime,
    "end_time": endTime,
    "item_weightage": itemWeightage,
    "mandatory_flag": mandatoryFlag,
    "active_flag": activeFlag,
    "department_required": departmentRequired,
    "department_rating_required": departmentRatingRequired,
    "store_rating_required": storeRatingRequired,
    "department": department,
    "section_id": sectionId,
    "created_by": createdBy,
    "created_datetime": createdDatetime,
    "updated_by": updatedBy,
    "checklist_applicable_type": checklistApplicableType,
    "checklist_progress_status": checklistProgressStatus,
    "checklist_edit_status": checklistEditStatus,
    "non_compliance_flag": non_compliance_flag,
    "updatedName": updatedName,
    "updated_by_datetime": updatedByDatetime,
    "branD_CODE": branD_CODE,
    "branD_NAME": branD_NAME,
    "elemenT_ID": elemenT_ID,
    "elemenT_NAME": elemenT_NAME,
    "demO_URL": demO_URL,

  };
}