

class EmployeeLeaveAplylist {
    String empCode;
    String empName;
    String designation;
    String scheduledDay;
    String applytype;

    EmployeeLeaveAplylist({
        required this.empCode,
        required this.empName,
        required this.designation,
        required this.scheduledDay,
        required this.applytype,
    });

    factory EmployeeLeaveAplylist.fromJson(Map<String, dynamic> json) => EmployeeLeaveAplylist(
        empCode: json["empCode"],
        empName: json["empName"],
        designation: json["designation"],
        scheduledDay: json["scheduledDay"],
        applytype: json["applytype"],
    );

    Map<String, dynamic> toJson() => {
        "empCode": empCode,
        "empName": empName,
        "designation": designation,
        "scheduledDay": scheduledDay,
        "applytype": applytype,
    };
}