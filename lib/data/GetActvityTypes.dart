
class GetActvityTypes {
    GetActvityTypes({
        required this.userId,
        required this.auditId,
        required this.auditName,
        required this.description,
        required this.currentCount,
        required this.pendingCount,
        this.apiUrl,
    });

    String userId;
    String auditId;
    String auditName;
    String description;
    int currentCount;
    int pendingCount;
    dynamic apiUrl;

    factory GetActvityTypes.fromJson(Map<String, dynamic> json) => GetActvityTypes(
        userId: json["userId"],
        auditId: json["auditId"],
        auditName: json["auditName"],
        description: json["description"],
        pendingCount: json["pendingCount"],
        currentCount: json["currentCount"],
        apiUrl: json["apiUrl"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "auditId": auditId,
        "auditName": auditName,
        "description": description,
        "currentCount": currentCount,
        "pendingCount": pendingCount,
        "apiUrl": apiUrl,
    };
}
