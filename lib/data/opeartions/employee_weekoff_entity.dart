// weekoff_data.dart
import 'employee_weekoff_details.dart';

class EmployeeWeekoffEntity {
  final String statusCode;
  final String status;
  final List<EmployeeWeekoffDetails> weekoffList;

  EmployeeWeekoffEntity({
    required this.statusCode,
    required this.status,
    required this.weekoffList,
  });

  factory EmployeeWeekoffEntity.fromJson(Map<String, dynamic> json) {
    var list = json['weekoffList'] as List;
    List<EmployeeWeekoffDetails> weekoffList =
    list.map((item) => EmployeeWeekoffDetails.fromJson(item)).toList();

    return EmployeeWeekoffEntity(
      statusCode: json['statusCode'],
      status: json['status'],
      weekoffList: weekoffList,
    );
  }
}