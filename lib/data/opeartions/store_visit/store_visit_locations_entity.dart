

class StoreVisitLocationsEntity {
  String locationCode;
  String locationName;
  String latitude;
  String longitude;
  String visitstatus;

  StoreVisitLocationsEntity({
    required this.locationCode,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.visitstatus,
  });

  factory StoreVisitLocationsEntity.fromJson(Map<String, dynamic> json) => StoreVisitLocationsEntity(
    locationCode: json["location_code"],
    locationName: json["location_name"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    visitstatus: json["visitstatus"],
  );

  Map<String, dynamic> toJson() => {
    "location_code": locationCode,
    "location_name": locationName,
    "latitude": latitude,
    "longitude": longitude,
    "visitstatus": visitstatus,
  };
}