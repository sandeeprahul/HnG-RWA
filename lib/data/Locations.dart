class Locations {
    Locations({
        required this.userId,
        required this.locationCode,
        required this.locationName,
        this.latitude,
        this.longitude,
        this.currentCount,
        this.pendingCount,
    });

    String userId;
    String locationCode;
    String locationName;
    String? latitude;
    String? longitude;
    int? currentCount;
    int? pendingCount;

    factory Locations.fromJson(Map<String, dynamic> json) => Locations(
        userId: json["userId"],
        locationCode: json["locationCode"],
        locationName: json["locationName"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        currentCount: json["currentCount"],
        pendingCount: json["pendingCount"],
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "locationCode": locationCode,
        "locationName": locationName,
        "latitude": latitude,
        "longitude": longitude,
        "currentCount": currentCount,
        "pendingCount": pendingCount,
    };
}