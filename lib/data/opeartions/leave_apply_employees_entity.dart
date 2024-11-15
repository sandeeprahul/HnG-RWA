class LeaveType {
  final String leaveCode;
  final String leaveType;

  LeaveType({required this.leaveCode, required this.leaveType});

  // Factory method to create a LeaveType from JSON
  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      leaveCode: json['leaveCode'] as String,
      leaveType: json['leaveType'] as String,
    );
  }
}

class Employee {
  final String empCode;
  final String empName;
  final String designation;
  final String date;
  final String status;

  Employee({
    required this.empCode,
    required this.empName,
    required this.designation,
    required this.date,
    required this.status,
  });

  // Factory method to create an Employee from JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empCode: json['empCode'] as String,
      empName: json['empName'] as String,
      designation: json['designation'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
    );
  }
}

class Description {
  final String code;
  final String message;

  Description({required this.message, required this.code});

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
        message: json['msg'] as String, code: json['code'] as String);
  }
}

// Create a class to hold both leave types and employees
class LeaveData {
  final List<LeaveType> leaveTypes;
  final List<Employee> employees;
  final List<Description> description;

  LeaveData({
    required this.leaveTypes,
    required this.employees,
    required this.description,
  });

  // Factory method to create LeaveData from JSON
  factory LeaveData.fromJson(Map<String, dynamic> json) {
    var leaveList = json['leavetypelist'] as List;
    var empList = json['employeelist'] as List;
    var descriptionList = json['descriptionmsg'] as List;

    List<LeaveType> leaveTypes =
        leaveList.map((leave) => LeaveType.fromJson(leave)).toList();

    List<Employee> employees =
        empList.map((emp) => Employee.fromJson(emp)).toList();

    List<Description> description = descriptionList
        .map((description) => Description.fromJson(description))
        .toList();

    return LeaveData(
        leaveTypes: leaveTypes, employees: employees, description: description);
  }
}
