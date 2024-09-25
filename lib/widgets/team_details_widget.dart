import 'package:flutter/material.dart';
import 'package:hng_flutter/data/opeartions/support_team_employee_details.dart';
import 'package:url_launcher/url_launcher.dart';

class teamDetailsWidget extends StatelessWidget {
  final SupportTeamEmployeeDetails employee;

  const teamDetailsWidget(this.employee, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Text(
              employee.userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              employee.region,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                _makePhoneCall(employee.mobileNo);
              },
              child: Text(
                employee.mobileNo,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    bool canLaunch = await canLaunchUrl(Uri.parse('tel:$phoneNumber'));

    // If the URL can be launched, launch it.
    if (canLaunch) {
      await launchUrl(Uri.parse('tel:$phoneNumber'));
    } else {
      print('can launch');
    }
  }
}
