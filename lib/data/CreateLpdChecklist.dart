class CreateLpdChecklist {
    CreateLpdChecklist({
        required this.sectionId,
        required this.sectionName,
    });

    String sectionId;
    String sectionName;

    factory CreateLpdChecklist.fromJson(Map<String, dynamic> json) => CreateLpdChecklist(
        sectionId: json["sectionId"],
        sectionName: json["sectionName"],
    );

    Map<String, dynamic> toJson() => {
        "sectionId": sectionId,
        "sectionName": sectionName,
    };
}