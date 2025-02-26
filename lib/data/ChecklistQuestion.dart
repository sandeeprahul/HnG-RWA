class ChecklistQuestion {
  final int checklistAssignId;
  final int checklistItemMstId;
  final int checklistId;
  final String itemName;
  final String startTime;
  final String endTime;
  final int itemWeightage;
  final int mandatoryFlag;
  final int activeFlag;
  final int departmentRequired;
  final int departmentRatingRequired;
  final int storeRatingRequired;
  final int department;
  final String departmentName;
  final int sectionId;
  final int createdBy;
  final String createdDateTime;
  final int updatedBy;
  final String checklistApplicableType;
  final String checklistProgressStatus;
  final String checklistEditStatus;
  final String updatedByDateTime;
  final String nonComplianceFlag;
  final String? updatedName;

  ChecklistQuestion({
    required this.checklistAssignId,
    required this.checklistItemMstId,
    required this.checklistId,
    required this.itemName,
    required this.startTime,
    required this.endTime,
    required this.itemWeightage,
    required this.mandatoryFlag,
    required this.activeFlag,
    required this.departmentRequired,
    required this.departmentRatingRequired,
    required this.storeRatingRequired,
    required this.department,
    required this.departmentName,
    required this.sectionId,
    required this.createdBy,
    required this.createdDateTime,
    required this.updatedBy,
    required this.checklistApplicableType,
    required this.checklistProgressStatus,
    required this.checklistEditStatus,
    required this.updatedByDateTime,
    required this.nonComplianceFlag,
    this.updatedName,
  });

  factory ChecklistQuestion.fromJson(Map<String, dynamic> json) {
    return ChecklistQuestion(
      checklistAssignId: json["am_checklist_assign_id"],
      checklistItemMstId: json["checklisT_ITEM_MST_ID"],
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
      department: json["department"],
      departmentName: json["departmentName"],
      sectionId: json["section_id"],
      createdBy: json["created_by"],
      createdDateTime: json["created_datetime"],
      updatedBy: json["updated_by"],
      checklistApplicableType: json["checklist_applicable_type"],
      checklistProgressStatus: json["checklist_progress_status"],
      checklistEditStatus: json["checklist_edit_status"],
      updatedByDateTime: json["updated_by_datetime"],
      nonComplianceFlag: json["non_compliance_flag"] ?? "",
      updatedName: json["updatedName"],
    );
  }
}
