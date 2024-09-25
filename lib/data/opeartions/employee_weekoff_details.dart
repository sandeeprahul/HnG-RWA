// weekoff_list.dart
class EmployeeWeekoffDetails {
  final String empCode;
  final String date;
  final String day;
  final String leavetype;
  final String activeInd;

  EmployeeWeekoffDetails({
    required this.empCode,
    required this.date,
    required this.day,
    required this.leavetype,
    required this.activeInd,
  });

  factory EmployeeWeekoffDetails.fromJson(Map<String, dynamic> json) {
    return EmployeeWeekoffDetails(
      empCode: json['empCode'],
      date: json['date'],
      day: json['day'],
      leavetype: json['leavetype'],
      activeInd: json['activeInd'],
    );
  }
}


