import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/constants.dart';
import '../../../data/opeartions/support_team_entity.dart';
import '../../../repository/support_team_repository.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/team_details_widget.dart';

class SupportTeamPage extends ConsumerStatefulWidget {
  const SupportTeamPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SupportTeamPage> createState() => _SupportTeamPageState();
}

class _SupportTeamPageState extends ConsumerState<SupportTeamPage>
    with SingleTickerProviderStateMixin {
  final SupportTeamRepository repository = SupportTeamRepository();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Support'),
        ),
        body: SafeArea(
            child: FutureBuilder<List<SupportTeamEntity>?>(
                future: repository.fetchSupportTeamData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Constants.networkIssue,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          CustomElevatedButton(
                              text: 'Retry',
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      ),
                    );
                  } else {
                    final supportTeamData = snapshot.data!;

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: convertStringToColor(
                                  supportTeamData[0].headerbgcolor)
                              // team.headerbgcolor
                              , /*borderRadius: BorderRadius.circular(8)*/
                            ),
                            child: Column(
                              children: [
                                /* ListTile(
                                          title:
                                        ),*/
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        supportTeamData[0].teamType,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 1,
                              color: convertStringToColor(
                                supportTeamData[0].headerbgcolor,
                              ),
                            )),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        'Name',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      // horizontalDivider(),
                                      Expanded(
                                          child: Text(
                                        'Region',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      // horizontalDivider(),
                                      Expanded(
                                          child: Text(
                                        'Mobile no',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: supportTeamData[0].empList.length,
                                  itemBuilder: (context, innerIndex) {
                                    final employee =
                                        supportTeamData[0].empList[innerIndex];
                                    return teamDetailsWidget(employee);
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider();
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          //1
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: convertStringToColor(
                                  supportTeamData[1].headerbgcolor)
                              // team.headerbgcolor
                              , /*borderRadius: BorderRadius.circular(8)*/
                            ),
                            child: Column(
                              children: [
                                /* ListTile(
                                          title:
                                        ),*/
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        supportTeamData[1].teamType,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 1,
                              color: convertStringToColor(
                                supportTeamData[1].headerbgcolor,
                              ),
                            )),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        'Name',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      // horizontalDivider(),
                                      Expanded(
                                          child: Text(
                                        'Region',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      // horizontalDivider(),
                                      Expanded(
                                          child: Text(
                                        'Mobile no',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: supportTeamData[1].empList.length,
                                  itemBuilder: (context, innerIndex) {
                                    final employee =
                                        supportTeamData[1].empList[innerIndex];
                                    return teamDetailsWidget(employee);
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          //2
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: convertStringToColor(
                                  supportTeamData[2].headerbgcolor)
                              // team.headerbgcolor
                              , /*borderRadius: BorderRadius.circular(8)*/
                            ),
                            child: Column(
                              children: [
                                /* ListTile(
                                          title:
                                        ),*/
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        supportTeamData[2].teamType,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 1,
                              color: convertStringToColor(
                                supportTeamData[2].headerbgcolor,
                              ),
                            )),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        'Name',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      // horizontalDivider(),
                                      Expanded(
                                          child: Text(
                                        'Region',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      // horizontalDivider(),
                                      Expanded(
                                          child: Text(
                                        'Mobile no',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: supportTeamData[2].empList.length,
                                  itemBuilder: (context, innerIndex) {
                                    final employee =
                                        supportTeamData[2].empList[innerIndex];
                                    return teamDetailsWidget(employee);
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          //3
                          Container(
                            // margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: convertStringToColor(
                                  supportTeamData[3].headerbgcolor),

                              // team.headerbgcolor
                              /*borderRadius: BorderRadius.circular(8)*/
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    supportTeamData[3].teamType,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 1,
                              color: convertStringToColor(
                                supportTeamData[3].headerbgcolor,
                              ),
                            )),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        'Name',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      // horizontalDivider(),
                                      Expanded(
                                          child: Text(
                                        'Region',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      // horizontalDivider(),
                                      Expanded(
                                          child: Text(
                                        'Mobile no',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: supportTeamData[3].empList.length,
                                  itemBuilder: (context, innerIndex) {
                                    final employee =
                                        supportTeamData[3].empList[innerIndex];
                                    return teamDetailsWidget(employee);
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                    return ListView.builder(
                        // shrinkWrap: true,
                        itemCount: supportTeamData.length,
                        itemBuilder: (context, index) {
                          final team = supportTeamData[index];

                          Color color =
                              convertStringToColor(team.headerbgcolor);
                          return Container(
                            decoration:
                                BoxDecoration(border: Border.all(color: color)),
                            margin: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: color
                                    // team.headerbgcolor
                                    , /*borderRadius: BorderRadius.circular(8)*/
                                  ),
                                  child: Column(
                                    children: [
                                      /* ListTile(
                                        title:
                                      ),*/
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              team.teamType,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      'Name',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    )),
                                    // horizontalDivider(),
                                    Expanded(
                                        child: Text(
                                      'Region',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    )),
                                    // horizontalDivider(),
                                    Expanded(
                                        child: Text(
                                      'Mobile no',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: team.empList.length,
                                  itemBuilder: (context, innerIndex) {
                                    final employee = team.empList[innerIndex];
                                    return teamDetailsWidget(employee);
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider();
                                  },
                                )
                                // teamDetailsWidget(team.empList),
                              ],
                            ),
                          );
                        });
                  }
                })));
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

  Color convertStringToColor(String colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors
          .transparent; // Return transparent color for empty or null string.
    }

    // Remove any leading '#' symbol from the color string.
    if (colorString[0] == '#') {
      colorString = colorString.substring(1);
    }

    // Convert the remaining hex value to an integer.
    int? colorValue = int.tryParse(colorString, radix: 16);

    if (colorValue == null) {
      return Colors
          .transparent; // Return transparent color if conversion fails.
    }

    // Handle different string lengths to determine the alpha value.
    if (colorString.length == 6) {
      // No alpha value provided, set alpha to 255 (opaque).
      colorValue = 0xFF000000 | colorValue;
    } else if (colorString.length == 8) {
      // Extract the alpha value from the color string.
      int alpha = (colorValue >> 24) & 0xFF;
      colorValue = (colorValue & 0x00FFFFFF) | (alpha << 24);
    } else {
      return Colors
          .transparent; // Invalid color string, return transparent color.
    }

    return Color(colorValue);
  }
}
