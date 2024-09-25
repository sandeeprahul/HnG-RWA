class GetChecklist {
    GetChecklist({
        required this.checklistId,
        required this.checklistName,
    });

    int checklistId;
    String checklistName;

    factory GetChecklist.fromJson(Map<String, dynamic> json) => GetChecklist(
        checklistId: json["checklistId"],
        checklistName: json["checklistName"],
    );

    Map<String, dynamic> toJson() => {
        "checklistId": checklistId,
        "checklistName": checklistName,
    };
}
