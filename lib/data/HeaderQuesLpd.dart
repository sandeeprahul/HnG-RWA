class HeaderQuesLpd {
    HeaderQuesLpd({
        required this.lpdChecklistAssignId,
        required this.checklisTItemMstId,
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
        required this.checklistApplicableType,
        required this.checklistProgressStatus,
        required this.checklistEditStatus,
        required this.non_compliance_flag,
        required this.updated_by,
        required this.updated_datetime,
        required this.updatedName,
    });


    int lpdChecklistAssignId;
    int checklisTItemMstId;
    int checklistId;
    String itemName;
    String startTime;
    String endTime;
    int itemWeightage;
    int mandatoryFlag;
    int activeFlag;
    int departmentRequired;
    int departmentRatingRequired;
    int storeRatingRequired;
    int department;
    String departmentName;
    int sectionId;
    int createdBy;
    String checklistApplicableType;
    String checklistProgressStatus;
    String checklistEditStatus;
    String non_compliance_flag;
    int? updated_by;
    String updated_datetime;
    String updatedName;

    factory HeaderQuesLpd.fromJson(Map<String, dynamic> json) => HeaderQuesLpd(
        lpdChecklistAssignId: json["lpd_checklist_assign_id"],
        checklisTItemMstId: json["checklisT_ITEM_MST_ID"],
        checklistId: json["checklist_id"],
        itemName: json["item_name"],
        startTime: json["start_time"]==''?'29-11-2022 00:00:00':json["start_time"],
        endTime: json["end_time"]==''?'29-11-2022 00:00:00':json["end_time"],
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
        checklistApplicableType: json["checklist_applicable_type"]!,
        checklistProgressStatus: json["checklist_progress_status"]!,
        checklistEditStatus: json["checklist_edit_status"],
        non_compliance_flag: json["non_compliance_flag"],
        updated_by: json["updated_by"],
        updated_datetime: json["updated_datetime"],
        updatedName: json["updatedName"]??0,
    );

    Map<String, dynamic> toJson() => {
        "lpd_checklist_assign_id": lpdChecklistAssignId,
        "checklisT_ITEM_MST_ID": checklisTItemMstId,
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
        "departmentName": departmentName,
        "section_id": sectionId,
        "created_by": createdBy,
        "checklist_applicable_type": checklistApplicableType,
        "checklist_progress_status": checklistProgressStatus,
        "checklist_edit_status": checklistEditStatus,
        "non_compliance_flag": non_compliance_flag,
        "updated_by": updated_by,
        "updatedName": updatedName,
    };
}