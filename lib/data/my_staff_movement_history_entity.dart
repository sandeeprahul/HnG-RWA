class MyStaffMovementHistoryEntity {
  int employeecode;
  int transId;
  String transDate;
  String employeeName;
  String reasonMovement;
  String expectedAroundTime;
  String remarks;
  String approvalStatus;
  String staffoutTiming;

  MyStaffMovementHistoryEntity({
    required this.employeecode,
    required this.transId,
    required this.transDate,
    required this.employeeName,
    required this.reasonMovement,
    required this.expectedAroundTime,
    required this.remarks,
    required this.approvalStatus,
    required this.staffoutTiming,
  });

  factory MyStaffMovementHistoryEntity.fromJson(Map<String, dynamic> json) {
    return MyStaffMovementHistoryEntity(
      employeecode: json['employeecode'],
      transId: json['transId'],
      transDate: json['transDate'],

      employeeName: json['employeeName'],
      reasonMovement: json['reasonMovement'],
      expectedAroundTime: json['expected_Arround_Time'],
      remarks: json['remarks'],
      approvalStatus: json['aprovalStatus'],
      staffoutTiming:json['staffoutTiming'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeecode': employeecode,
      'transId': transId,
      'transDate': transDate,
      'employeeName': employeeName,
      'reasonMovement': reasonMovement,
      'expected_Around_Time': expectedAroundTime,
      'remarks': remarks,
      'aprovalStatus': approvalStatus,
      'staffoutTiming': staffoutTiming,
    };
  }
}