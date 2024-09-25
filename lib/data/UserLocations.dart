
/*class UserLocations {
    String statusCode;
    String status;
    List<Location> locations;

    UserLocations({
        required this.statusCode,
        required this.status,
        required this.locations,
    });

    factory UserLocations.fromJson(Map<String, dynamic> json) => UserLocations(
        statusCode: json["statusCode"],
        status: json["status"],
        locations: List<Location>.from(json["locations"].map((x) => Location.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "status": status,
        "locations": List<dynamic>.from(locations.map((x) => x.toJson())),
    };
}*/

class UserLocations {
    String locationCode;
    String locationName;
    String latitude;
    String longitude;

    UserLocations({
        required this.locationCode,
        required this.locationName,
        required this.latitude,
        required this.longitude,
    });

    factory UserLocations.fromJson(Map<String, dynamic> json) => UserLocations(
        locationCode: json["locationCode"],
        locationName: json["locationName"],
        latitude: json["latitude"],
        longitude: json["longitude"],
    );

    Map<String, dynamic> toJson() => {
        "locationCode": locationCode,
        "locationName": locationName,
        "latitude": latitude,
        "longitude": longitude,
    };
}