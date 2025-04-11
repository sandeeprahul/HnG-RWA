// models/checkin_status_model.dart
import 'dart:convert';

class CheckinStatusModel {
  final String checkinFlag;
  final String checkoutFlag;
  final String checkinTime;
  final String checkoutTime;
  final MenuJson menuJson;

  CheckinStatusModel({
    required this.checkinFlag,
    required this.checkoutFlag,
    required this.checkinTime,
    required this.checkoutTime,
    required this.menuJson,
  });

  factory CheckinStatusModel.fromJson(Map<String, dynamic> json) {
    return CheckinStatusModel(
      checkinFlag: json['checkin_flag'],
      checkoutFlag: json['checkiout_flag'],
      checkinTime: json['chekin_time'],
      checkoutTime: json['chekout_time'],
      menuJson: MenuJson.fromJson(
        jsonDecode(json['menu_json']),
      ),
    );
  }
}

class MenuJson {
  final PageSection homePage;
  final PageSection profile;

  MenuJson({
    required this.homePage,
    required this.profile,
  });

  factory MenuJson.fromJson(Map<String, dynamic> json) {
    return MenuJson(
      homePage: PageSection.fromJson(json['Home_Page']),
      profile: PageSection.fromJson(json['Profile']),
    );
  }
}

class PageSection {
  final List<Map<String, String>> menus;
  final List<Map<String, String>> label;
  final List<Map<String, String>> grid;

  PageSection({
    required this.menus,
    required this.label,
    required this.grid,
  });

  factory PageSection.fromJson(Map<String, dynamic> json) {
    return PageSection(
      menus: List<Map<String, String>>.from(
        json['Menus'].map((item) => Map<String, String>.from(item)),
      ),
      label: List<Map<String, String>>.from(
        json['Label']?.map((item) => Map<String, String>.from(item)) ?? [],
      ),
      grid: List<Map<String, String>>.from(
        json['Grid']?.map((item) => Map<String, String>.from(item)) ?? [],
      ),
    );
  }
}
