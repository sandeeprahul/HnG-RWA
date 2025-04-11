import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/controllers/taskCheckerController.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/CheckinStatus.dart';
import '../data/CheckinStatusModel.dart';


class CheckinController extends GetxController {
  final Rxn<CheckinStatusModel> checkinStatus = Rxn<CheckinStatusModel>();
  final isLoading = false.obs;

  var statusMessage = "".obs;
  var chekinFormattedTime = "".obs;
  var chekoutFormattedTime = "".obs;
  var startendTimeText = "".obs;

  bool get isMyTeamActivitiesEnabled {
    final status = checkinStatus.value;
    if (status == null) return false;

    for (var item in status.menuJson.homePage.menus) {
      if (item.containsKey("My Team Activities")) {
        return item["My Team Activities"]?.toLowerCase() == 'y';
      }
    }
    return false;
  }

  bool get isProductEnquiryEnabled {
    final status = checkinStatus.value;
    if (status == null) return false;

    for (var item in status.menuJson.homePage.menus) {
      if (item.containsKey("Product Quick Enquiry")) {
        return item["Product Quick Enquiry"]?.toLowerCase() == 'y';
      }
    }
    return false;
  }

  bool get isExploreCompanyEnabled {
    final status = checkinStatus.value;
    if (status == null) return false;

    for (var item in status.menuJson.homePage.label) {
      if (item.containsKey("Explore Company")) {
        return item["Explore Company"]?.toLowerCase() == 'y';
      }
    }
    return false;
  }

  bool get isAttendanceEnabled {
    final status = checkinStatus.value;
    if (status == null) return false;

    for (var item in status.menuJson.profile.menus) {
      if (item.containsKey("Attendance")) {
        return item["Attendance"]?.toLowerCase() == 'y';
      }
    }
    return false;
  }

  bool get isStaffMovementEnabled {
    final status = checkinStatus.value;
    if (status == null) return false;

    for (var item in status.menuJson.profile.menus) {
      if (item.containsKey("Staff Movement")) {
        return item["Staff Movement"]?.toLowerCase() == 'y';
      }
    }
    return false;
  }

  bool get isStaffMovementApplyEnabled {
    final status = checkinStatus.value;
    if (status == null) return false;

    for (var item in status.menuJson.profile.menus) {
      if (item.containsKey("Staff Movement Apply")) {
        return item["Staff Movement Apply"]?.toLowerCase() == 'y';
      }
    }
    return false;
  }

  bool get isStaffMovementHistoryEnabled {
    final status = checkinStatus.value;
    if (status == null) return false;

    for (var item in status.menuJson.profile.menus) {
      if (item.containsKey("Staff Movement History")) {
        return item["Staff Movement History"]?.toLowerCase() == 'y';
      }
    }
    return false;
  }

  bool get isCouponValidationEnabled {
    final status = checkinStatus.value;
    if (status == null) return false;

    for (var item in status.menuJson.profile.menus) {
      if (item.containsKey("Coupon Validation")) {
        return item["Coupon Validation"]?.toLowerCase() == 'y';
      }
    }
    return false;
  }

}
