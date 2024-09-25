class Locationlist {
  String locationCode;
  String locationName;

  Locationlist({
    required this.locationCode,
    required this.locationName,
  });

  factory Locationlist.fromJson(Map<String, dynamic> json) => Locationlist(
    locationCode: json["locationCode"],
    locationName: json["locationName"],
  );

  Map<String, dynamic> toJson() => {
    "locationCode": locationCode,
    "locationName": locationName,
  };
}