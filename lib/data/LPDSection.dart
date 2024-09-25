
class LPDSection {
    LPDSection({
        required this.sectionId,
        required this.sectionName,
        required this.section_completion_status,
        required this.percentage,
    });

    String sectionId;
    String sectionName;
    String section_completion_status;
    String percentage;

    factory LPDSection.fromJson(Map<String, dynamic> json) => LPDSection(
        sectionId: json["sectionId"],
        sectionName: json["sectionName"],
        section_completion_status: json["section_completion_status"],
        percentage: json["percentage"],
    );

    Map<String, dynamic> toJson() => {
        "sectionId": sectionId,
        "sectionName": sectionName,
        "section_completion_status": section_completion_status,
        "percentage": percentage,
    };
}