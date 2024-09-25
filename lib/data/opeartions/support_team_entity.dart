import 'package:hng_flutter/data/opeartions/support_team_employee_details.dart';

class SupportTeamEntity {
  String teamType;
  String headerbgcolor;
  List<SupportTeamEmployeeDetails> empList;

  SupportTeamEntity({required this.teamType, required this.empList,required this.headerbgcolor});

  factory SupportTeamEntity.fromJson(Map<String, dynamic> json) {
    return SupportTeamEntity(
      teamType: json['teamType'],
      headerbgcolor: json['headerbgcolor'],
      empList: List<SupportTeamEmployeeDetails>.from(json['empList'].map((emp) => SupportTeamEmployeeDetails.fromJson(emp))),
    );
  }
}