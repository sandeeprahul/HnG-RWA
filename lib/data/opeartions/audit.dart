class Audit {
  final int auditId;
  final String auditName;

  Audit(this.auditId, this.auditName);

  factory Audit.fromJson(Map<String, dynamic> json) {
    return Audit(
      json['auditid'] as int,
      json['auditName'] as String,
    );
  }
}
