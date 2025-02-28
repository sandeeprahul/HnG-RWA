import 'dart:convert';

class AuditSummary {
  final String auditStartTime;
  final String auditEndTime;
  final List<Section> sections;
  final String totalScore;
  final String yourRatingScore;
  final String percentage;

  AuditSummary({
    required this.auditStartTime,
    required this.auditEndTime,
    required this.sections,
    required this.totalScore,
    required this.yourRatingScore,
    required this.percentage,
  });

  factory AuditSummary.fromJson(Map<String, dynamic> json) {
    var sectionList = json['section'] as List;
    List<Section> sectionItems =
    sectionList.map((i) => Section.fromJson(i)).toList();

    return AuditSummary(
      auditStartTime: json['auditStartTime'],
      auditEndTime: json['auditEndTime'],
      sections: sectionItems,
      totalScore: json['totalScore'],
      yourRatingScore: json['yourRatingScore'],
      percentage: json['percentage'],
    );
  }
}

class Section {
  final String sectionName;
  final String totalScore;
  final String yourRatingScore;

  Section({
    required this.sectionName,
    required this.totalScore,
    required this.yourRatingScore,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionName: json['sectionName'],
      totalScore: json['totalScore'],
      yourRatingScore: json['yourRatingScore'],
    );
  }
}
