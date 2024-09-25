class HeaderQuestionEmployee {
    int empChecklistAssignId;
    int checklisTItemMstId;
    int checklistId;
    int employeeCode;
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
    dynamic departmentName;
    int sectionId;
    int createdBy;
    int updatedBy;
    String updatedName;
    String updatedDatetime;
    String checklistApplicableType;
    String checklistProgressStatus;
    String checklistEditStatus;
    String non_compliance_flag;

    HeaderQuestionEmployee({
        required this.empChecklistAssignId,
        required this.checklisTItemMstId,
        required this.checklistId,
        required this.employeeCode,
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
        this.departmentName,
        required this.sectionId,
        required this.createdBy,
        required this.updatedBy,
        required this.updatedName,
        required this.updatedDatetime,
        required this.checklistApplicableType,
        required this.checklistProgressStatus,
        required this.checklistEditStatus,
        required this.non_compliance_flag,
    });

    factory HeaderQuestionEmployee.fromJson(Map<String, dynamic> json) => HeaderQuestionEmployee(
        empChecklistAssignId: json["emp_checklist_assign_id"],
        checklisTItemMstId: json["checklisT_ITEM_MST_ID"],
        checklistId: json["checklist_id"],
        employeeCode: json["employee_code"],
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
        updatedBy: json["updated_by"],
        updatedName: json["updatedName"],
        updatedDatetime: json["updated_Datetime"],
        checklistApplicableType: json["checklist_applicable_type"],
        checklistProgressStatus: json["checklist_progress_status"],
        checklistEditStatus: json["checklist_edit_status"],
        non_compliance_flag: json["non_compliance_flag"],
    );

    Map<String, dynamic> toJson() => {
        "emp_checklist_assign_id": empChecklistAssignId,
        "checklisT_ITEM_MST_ID": checklisTItemMstId,
        "checklist_id": checklistId,
        "employee_code": employeeCode,
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
        "updated_by": updatedBy,
        "updatedName": updatedName,
        "updated_Datetime": updatedDatetime,
        "checklist_applicable_type": checklistApplicableType,
        "checklist_progress_status": checklistProgressStatus,
        "checklist_edit_status": checklistEditStatus,
        "non_compliance_flag": non_compliance_flag,
    };
}