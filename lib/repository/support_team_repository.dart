import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../common/constants.dart';
import '../data/opeartions/support_team_entity.dart';

class SupportTeamRepository {
  Future<List<SupportTeamEntity>?> fetchSupportTeamData() async {
    try {
      String url =
          "${Constants.apiHttpsUrl}/Login/ITSupport";
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 300));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final statusCode = jsonData['statusCode'];
        final teams = jsonData['teams'];
        if(statusCode=="200"){
          if (kDebugMode) {
            print(statusCode);
            print(teams);
          }
          final supportTeams = (teams as List)
              .map((team) => SupportTeamEntity.fromJson(team))
              .toList();
          return supportTeams;
        }else{
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error:$e");
      }
      return null;
    }
  }
}
