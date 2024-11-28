class HeaderQuesStoreAM {
    HeaderQuesStoreAM({
        required this.am_checklist_assign_id,
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
        required this.sectionId,
        required this.createdBy,
        required this.checklistApplicableType,
        required this.checklistProgressStatus,
        required this.checklistEditStatus,
        required this.updated_by,
        required this.updated_by_datetime
    });


    int am_checklist_assign_id;
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
    int sectionId;
    int createdBy;
    int updated_by;
    String checklistApplicableType;
    String checklistProgressStatus;
    String updated_by_datetime;
    String checklistEditStatus;

    factory HeaderQuesStoreAM.fromJson(Map<String, dynamic> json) => HeaderQuesStoreAM(
        am_checklist_assign_id: json["am_checklist_assign_id"],
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
        sectionId: json["section_id"],
        createdBy: json["created_by"],
        checklistApplicableType: json["checklist_applicable_type"]!,
        checklistProgressStatus: json["checklist_progress_status"]!,
        checklistEditStatus: json["checklist_edit_status"],
        updated_by: json["updated_by"],
        updated_by_datetime: json["updated_by_datetime"],
    );

    Map<String, dynamic> toJson() => {
        "store_checklist_assign_id": am_checklist_assign_id,
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
        "section_id": sectionId,
        "created_by": createdBy,
        "checklist_applicable_type": checklistApplicableType,
        "checklist_progress_status": checklistProgressStatus,
        "checklist_edit_status": checklistEditStatus,
    };
}