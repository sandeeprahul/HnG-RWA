import 'dart:convert';

List<GetProgressStatus> getProgressStatusFromJson(String str) => List<GetProgressStatus>.from(json.decode(str).map((x) => GetProgressStatus.fromJson(x)));

String getProgressStatusToJson(List<GetProgressStatus> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetProgressStatus {
  GetProgressStatus({
    required this.userId,
    required this.locationCode,
    required this.audittypes,
  });

  String userId;
  String locationCode;
  List<Audittype> audittypes;

  factory GetProgressStatus.fromJson(Map<String, dynamic> json) => GetProgressStatus(
    userId: json["userId"],
    locationCode: json["locationCode"],
    audittypes: List<Audittype>.from(json["audittypes"].map((x) => Audittype.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "locationCode": locationCode,
    "audittypes": List<dynamic>.from(audittypes.map((x) => x.toJson())),
  };
}

class Audittype {
  Audittype({
    required this.auditType,
    required this.locationdetails,
  });

  String auditType;
  List<Locationdetail> locationdetails;

  factory Audittype.fromJson(Map<String, dynamic> json) => Audittype(
    auditType: json["auditType"],
    locationdetails: List<Locationdetail>.from(json["locationdetails"].map((x) => Locationdetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "auditType": auditType,
    "locationdetails": List<dynamic>.from(locationdetails.map((x) => x.toJson())),
  };
}

class Locationdetail {
  Locationdetail({
    required this.region,
    required this.location,
    required this.checklistProgressSatus,
  });

  String region;
  String location;
  String checklistProgressSatus;

  factory Locationdetail.fromJson(Map<String, dynamic> json) =>
      Locationdetail(
        region: json["region"],
        location: json["location"],
        checklistProgressSatus: json["checklistProgressSatus"],
      );

  Map<String, dynamic> toJson() =>
      {
        "region": region,
        "location": location,
        "checklistProgressSatus": checklistProgressSatus,
      };
}