class ActiveCheckListEmployee {
    int empChecklistAssignId;
    int regionCode;
    String regionName;
    int locationCode;
    String locationName;
    String publishDate;
    int employeeCode;
    int id;
    String auditType;
    String iconUrl;
    String apiRefType;
    int weCareFlag;
    int nonComplianceFlag;
    int posBosFlag;
    int locationFlag;
    String checkinFlag;
    int activeFlag;
    int sectionFlag;
    int checklisTId;
    int auditTypeId;
    String checklistName;
    String startDate;
    String endDate;
    String startTime;
    String endTime;
    String empCutoffTime;
    String managerCutoffTime;
    int publishFlag;
    int frequencyFlag;
    String checklistApplicableType;
    String checklistProgressStatus;
    String applicableType;
    String checklistEditStatus;
    String checkInFlag;
    String locationValidateFlag;
    String latitude;
    String longitude;
    String list_type;

    ActiveCheckListEmployee({
        required this.empChecklistAssignId,
        required this.regionCode,
        required this.regionName,
        required this.locationCode,
        required this.locationName,
        required this.publishDate,
        required this.employeeCode,
        required this.id,
        required this.auditType,
        required this.iconUrl,
        required this.apiRefType,
        required this.weCareFlag,
        required this.nonComplianceFlag,
        required this.posBosFlag,
        required this.locationFlag,
        required this.checkinFlag,
        required this.activeFlag,
        required this.sectionFlag,
        required this.checklisTId,
        required this.auditTypeId,
        required this.checklistName,
        required this.startDate,
        required this.endDate,
        required this.startTime,
        required this.endTime,
        required this.empCutoffTime,
        required this.managerCutoffTime,
        required this.publishFlag,
        required this.frequencyFlag,
        required this.checklistApplicableType,
        required this.checklistProgressStatus,
        required this.applicableType,
        required this.checklistEditStatus,
        required this.checkInFlag,
        required this.locationValidateFlag,
        required this.latitude,
        required this.longitude,
        required this.list_type,
    });

    factory ActiveCheckListEmployee.fromJson(Map<String, dynamic> json) => ActiveCheckListEmployee(
        empChecklistAssignId: json["emp_checklist_assign_id"],
        regionCode: json["region_code"],
        regionName: json["region_name"],
        locationCode: json["location_code"],
        locationName: json["location_name"],
        publishDate: json["publish_date"],
        employeeCode: json["employee_code"],
        id: json["id"],
        auditType: json["audit_type"],
        iconUrl: json["icon_url"],
        apiRefType: json["api_ref_type"],
        weCareFlag: json["we_care_flag"],
        nonComplianceFlag: json["non_compliance_flag"],
        posBosFlag: json["pos_bos_flag"],
        locationFlag: json["location_flag"],
        checkinFlag: json["check_In_Flag"],
        activeFlag: json["active_flag"],
        sectionFlag: json["section_flag"],
        checklisTId: json["checklisT_ID"],
        auditTypeId: json["audit_type_id"],
        checklistName: json["checklist_name"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        empCutoffTime: json["emp_cutoff_time"],
        managerCutoffTime: json["manager_cutoff_time"],
        publishFlag: json["publish_flag"],
        frequencyFlag: json["frequency_flag"],
        checklistApplicableType: json["checklist_applicable_type"],
        checklistProgressStatus: json["checklist_progress_status"],
        applicableType: json["applicable_type"],
        checklistEditStatus: json["checklist_edit_status"],
        checkInFlag: json["check_In_Flag"],
        locationValidateFlag: json["location_Validate_flag"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        list_type: json["list_type"],
    );

    Map<String, dynamic> toJson() => {
        "emp_checklist_assign_id": empChecklistAssignId,
        "region_code": regionCode,
        "region_name": regionName,
        "location_code": locationCode,
        "location_name": locationName,
        "publish_date": publishDate,
        "employee_code": employeeCode,
        "id": id,
        "audit_type": auditType,
        "icon_url": iconUrl,
        "api_ref_type": apiRefType,
        "we_care_flag": weCareFlag,
        "non_compliance_flag": nonComplianceFlag,
        "pos_bos_flag": posBosFlag,
        "location_flag": locationFlag,
        "checkin_flag": checkinFlag,
        "active_flag": activeFlag,
        "section_flag": sectionFlag,
        "checklisT_ID": checklisTId,
        "audit_type_id": auditTypeId,
        "checklist_name": checklistName,
        "start_date": startDate,
        "end_date": endDate,
        "start_time": startTime,
        "end_time": endTime,
        "emp_cutoff_time": empCutoffTime,
        "manager_cutoff_time": managerCutoffTime,
        "publish_flag": publishFlag,
        "frequency_flag": frequencyFlag,
        "checklist_applicable_type": checklistApplicableType,
        "checklist_progress_status": checklistProgressStatus,
        "applicable_type": applicableType,
        "checklist_edit_status": checklistEditStatus,
        "check_In_Flag": checkInFlag,
        "location_Validate_flag": locationValidateFlag,
        "latitude": latitude,
        "longitude": longitude,
        "list_type": list_type,
    };
}