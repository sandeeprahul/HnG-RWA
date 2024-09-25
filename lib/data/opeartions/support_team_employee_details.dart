
class SupportTeamEmployeeDetails {
  String userName;
  String region;
  String status;
  String timings;
  String deptName;
  String mobileNo;

  SupportTeamEmployeeDetails({
    required this.userName,
    required this.region,
    required this.status,
    required this.timings,
    required this.deptName,
    required this.mobileNo,
  });

  factory SupportTeamEmployeeDetails.fromJson(Map<String, dynamic> json) {
    return SupportTeamEmployeeDetails(
      userName: json['userName'],
      region: json['region'],
      status: json['status'],
      timings: json['timings'],
      deptName: json['deptName'],
      mobileNo: json['mobileno'],
    );
  }
}