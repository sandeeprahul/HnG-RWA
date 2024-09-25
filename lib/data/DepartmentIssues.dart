class DepartmentIssues {
    String department;
    List<String> issues;

    DepartmentIssues({
        required this.department,
        required this.issues,
    });

    factory DepartmentIssues.fromJson(Map<String, dynamic> json) => DepartmentIssues(
        department: json["Department"],
        issues: List<String>.from(json["Issues"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "Department": department,
        "Issues": List<dynamic>.from(issues.map((x) => x)),
    };
}