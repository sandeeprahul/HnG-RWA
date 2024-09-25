class ActiveCheckListVirtualMerchEntity {
  ActiveCheckListVirtualMerchEntity({
    required this.vm_assign_id,
    required this.regionCode,
    required this.regionName,
    required this.locationCode,
    required this.locationName,
    required this.publishDate,
    required this.id,
    required this.auditType,
    required this.iconUrl,
    required this.apiRefType,
    required this.weCareFlag,
    required this.nonComplianceFlag,
    required this.posBosFlag,
    required this.checkinFlag,
    required this.locationFlag,
    required this.sectionFlag,
    required this.frequencyFlag,
    required this.activeFlag,
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
    required this.checklistApplicableType,
    required this.checklistProgressStatus,
    required this.checklistEditStatus,
    required this.check_In_Flag,
    required this.location_Validate_flag,
    required this.latitude,
    required this.longitude,
    required this.checklist_Current_Status_Type,
  });

  int vm_assign_id;
  int regionCode;
  String regionName;
  int locationCode;
  String locationName;
  String publishDate;
  int id;
  String auditType;
  String iconUrl;
  String apiRefType;
  int weCareFlag;
  int nonComplianceFlag;
  int posBosFlag;
  int checkinFlag;
  int locationFlag;
  int sectionFlag;
  int frequencyFlag;
  int activeFlag;
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
  String checklistApplicableType;
  String checklistProgressStatus;
  String  checklistEditStatus;
  String  check_In_Flag;
  String  location_Validate_flag;
  String  latitude;
  String  checklist_Current_Status_Type;
  String  longitude;


  factory ActiveCheckListVirtualMerchEntity.fromJson(Map<String, dynamic> json) => ActiveCheckListVirtualMerchEntity(
    vm_assign_id: json["vm_assign_id"],
    regionCode: json["region_code"],
    regionName: json["region_name"],
    locationCode: json["location_code"],
    locationName: json["location_name"],
    publishDate: json["publish_date"],
    id: json["id"],
    auditType: json["audit_type"],
    iconUrl: json["icon_url"],
    apiRefType: json["api_ref_type"],
    weCareFlag: json["we_care_flag"],
    nonComplianceFlag: json["non_compliance_flag"],
    posBosFlag: json["pos_bos_flag"],
    checkinFlag: json["checkin_flag"],
    locationFlag: json["location_flag"],
    sectionFlag: json["section_flag"],
    frequencyFlag: json["frequency_flag"],
    activeFlag: json["active_flag"],
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
    checklistApplicableType: json["checklist_applicable_type"],
    checklistProgressStatus: json["checklist_progress_status"],
    checklistEditStatus: json["checklist_edit_status"],
    check_In_Flag: json["check_In_Flag"]??'',
    location_Validate_flag: json["location_Validate_flag"]??'',
    latitude: json["latitude"]??'',
    longitude: json["longitude"]??'',
    checklist_Current_Status_Type: json["checklist_Current_Status_Type"]??'',

  );

  Map<String, dynamic> toJson() => {
    "vm_assign_id": vm_assign_id,
    "region_code": regionCode,
    "region_name": regionName,
    "location_code": locationCode,
    "location_name": locationName,
    "publish_date": publishDate,
    "id": id,
    "audit_type": auditType,
    "icon_url": iconUrl,
    "api_ref_type": apiRefType,
    "we_care_flag": weCareFlag,
    "non_compliance_flag": nonComplianceFlag,
    "pos_bos_flag": posBosFlag,
    "checkin_flag": checkinFlag,
    "location_flag": locationFlag,
    "section_flag": sectionFlag,
    "frequency_flag": frequencyFlag,
    "active_flag": activeFlag,
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
    "checklist_applicable_type": checklistApplicableType,
    "checklist_progress_status": checklistProgressStatus,
    "checklist_edit_status": checklistEditStatus,
    "check_In_Flag": checklistEditStatus,
    "location_Validate_flag": checklistEditStatus,
    "latitude": checklistEditStatus,
    "longitude": checklistEditStatus,
    "checklist_Current_Status_Type": checklist_Current_Status_Type,

  };
}