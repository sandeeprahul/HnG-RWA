class StaffMovementReasonData {
  final int reasonCode;
  final String reasonDescription;
  final int durations;
  final int isActive;

  StaffMovementReasonData({
    required this.reasonCode,
    required this.reasonDescription,
    required this.durations,
    required this.isActive,
  });

  factory StaffMovementReasonData.fromJson(Map<String, dynamic> json) {
    return StaffMovementReasonData(
      reasonCode: json['reasonCode'] as int,
      reasonDescription: json['reason_description'] as String,
      durations: json['durations'] as int,
      isActive: json['isActive'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reasonCode': reasonCode,
      'reason_description': reasonDescription,
      'durations': durations,
      'isActive': isActive,
    };
  }
}
