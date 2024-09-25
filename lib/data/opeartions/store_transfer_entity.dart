import 'package:hng_flutter/data/opeartions/employee_list_transfer.dart';

import 'locations_entity.dart';

class StoreTransferData {
    String statusCode;
    String status;
    String minAllowedDays;
    String maxAllowedDays;
    List<Employeelist> employeelist;
    List<Locationlist> locationlist;

    StoreTransferData({
        required this.statusCode,
        required this.status,
        required this.minAllowedDays,
        required this.maxAllowedDays,
        required this.employeelist,
        required this.locationlist,
    });

    factory StoreTransferData.fromJson(Map<String, dynamic> json) => StoreTransferData(
        statusCode: json["statusCode"],
        status: json["status"],
        minAllowedDays: json["minAllowedDays"],
        maxAllowedDays: json["maxAllowedDays"],
        employeelist: List<Employeelist>.from(json["employeelist"].map((x) => Employeelist.fromJson(x))),
        locationlist: List<Locationlist>.from(json["locationlist"].map((x) => Locationlist.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "status": status,
        "minAllowedDays": minAllowedDays,
        "maxAllowedDays": maxAllowedDays,
        "employeelist": List<dynamic>.from(employeelist.map((x) => x.toJson())),
        "locationlist": List<dynamic>.from(locationlist.map((x) => x.toJson())),
    };
}