
class TicketResponse {
    DateTime dateEntered;
    String subject;
    String storeName;
    String caseNumber;
    String status;
    String departmentName;
    String issue;
    String description;

    TicketResponse({
        required this.dateEntered,
        required this.subject,
        required this.storeName,
        required this.caseNumber,
        required this.status,
        required this.departmentName,
        required this.issue,
        required this.description,
    });

    factory TicketResponse.fromJson(Map<String, dynamic> json) => TicketResponse(
        dateEntered: DateTime.parse(json["Date_Entered"]),
        subject: json["Subject"],
        storeName: json["StoreName"],
        caseNumber: json["Case_Number"],
        status: json["Status"],
        departmentName: json["Department_Name"],
        issue: json["Issue"],
        description: json["Description"],
    );

    Map<String, dynamic> toJson() => {
        "Date_Entered": dateEntered.toIso8601String(),
        "Subject": subject,
        "StoreName": storeName,
        "Case_Number": caseNumber,
        "Status": status,
        "Department_Name": departmentName,
        "Issue": issue,
        "Description": description,
    };
}