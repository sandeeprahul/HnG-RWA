class WeCareLocation {
  final String locationCode;
  final String locationName;
  final String latitude;
  final String longitude;
  final String weCareUserId;
  final String weCareLocationCode;
  final String weCareFlag;

  WeCareLocation({
    required this.locationCode,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.weCareUserId,
    required this.weCareLocationCode,
    required this.weCareFlag,
  });

  factory WeCareLocation.fromJson(Map<String, dynamic> json) {
    return WeCareLocation(
      locationCode: json['location_code'],
      locationName: json['location_name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      weCareUserId: json['wecare_userid'],
      weCareLocationCode: json['wecare_location_code'],
      weCareFlag: json['wecare_flag'],
    );
  }
}