class MyStaffMovementData {
  final int employeeCode;
  final int transId;
  final String? transDate;
  final String employeeName;
  final String reasonMovement;
  final String expectedAroundTime;
  final String remarks;
  final String approvalStatus;
  final String? staffOutTiming;

  MyStaffMovementData({
    required this.employeeCode,
    required this.transId,
    this.transDate,
    required this.employeeName,
    required this.reasonMovement,
    required this.expectedAroundTime,
    required this.remarks,
    required this.approvalStatus,
    this.staffOutTiming,
  });

  factory MyStaffMovementData.fromJson(Map<String, dynamic> json) {
    return MyStaffMovementData(
      employeeCode: json['employeecode'],
      transId: json['transId'],
      transDate: json['transDate'],
      employeeName: json['employeeName'],
      reasonMovement: json['reasonMovement'],
      expectedAroundTime: json['expected_Arround_Time'],
      remarks: json['remarks'],
      approvalStatus: json['aprovalStatus'],
      staffOutTiming: json['staffoutTiming'],
    );
  }
}
