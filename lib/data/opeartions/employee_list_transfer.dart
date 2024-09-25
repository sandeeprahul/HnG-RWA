
class Employeelist {
    String empCode;
    String empName;
    String designation;
    String currentLoactionCode;
    String currentLoactionName;

    Employeelist({
        required this.empCode,
        required this.empName,
        required this.designation,
        required this.currentLoactionCode,
        required this.currentLoactionName,
    });

    factory Employeelist.fromJson(Map<String, dynamic> json) => Employeelist(
        empCode: json["empCode"],
        empName: json["empName"],
        designation: json["designation"],
        currentLoactionCode: json["currentLoactionCode"],
        currentLoactionName: json["currentLoactionName"],
    );

    Map<String, dynamic> toJson() => {
        "empCode": empCode,
        "empName": empName,
        "designation":designation,
        "currentLoactionCode": currentLoactionCode,
        "currentLoactionName": currentLoactionName,
    };
}