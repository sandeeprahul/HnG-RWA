import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hng_flutter/widgets/custom_elevated_button.dart';
import 'package:hng_flutter/widgets/image_preview.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/wecareScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NewProfilePage.dart';
import 'PageHome.dart';
import 'PageProfile.dart';
import 'PageRetail.dart';
import 'common/constants.dart';
import 'core/light_theme.dart';
import 'data/AuditSummary.dart';
import 'presentation/home/operations/operations_page.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

var locationCode = '';
var latGlobal = '';
var lngGlobal = '';

class _HomeScreenState extends State<HomeScreen> {
  var isSelected = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  var status_ = 0;
  bool isUpdated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getLoginDetails();
    // findUserGeoLoc();
    // getVersion();
    // getLocation();
    // _showLocationPermissionDialog(context);
    getHomeData();
    firebase();
  }

  firebase() async {
    await Firebase.initializeApp();
  }

/*  Future<void> getLoginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    var json = jsonDecode(prefs.getString('loginResponse') ?? '');

    setState(() {
      locationCode = json['location']['location_name'].toString();
      latGlobal = json['location']['latitude'].toString();
      lngGlobal = json['location']['longitude'].toString();
    });
  }*/

  bool showProgress = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Scaffold(
            body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          height: 50,
                          width: 100,
                          child: SvgPicture.network(
                              'https://ik.imagekit.io/hng/desktop-assets/svgs/logo.svg')),
                      const Icon(
                        Icons.notifications,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: PageView(
                  // physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) async {
                    if (page == 0) {
                      setState(() {
                        isSelected = 0;
                      });
                    } else if (page == 1) {
                      setState(() {
                        isSelected = 1;
                      });
                    } else if (page == 2) {
                      setState(() {
                        isSelected = 2;
                      });
                    } else if (page == 3) {
                      setState(() {
                        isSelected = 3;
                      });
                    }
                  },
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  children: const [
                    PageHome(),
                    PageSurvey(),
                    PageRetail(),
                    // NewPageProfilePage(),
                    PageProfile(),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSelected = 0;
                            _pageController.jumpToPage(0);
                            /*_pageController.animateToPage(
                                    0,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );*/
                          });
                        },
                        child: AnimatedContainer(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 3, top: 3),
                          decoration: BoxDecoration(
                            color: isSelected == 0
                                ? const Color(0xfff76613)
                                : Colors.transparent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              Icon(
                                Icons.home_filled,
                                color: isSelected == 0
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              Text(
                                'Home',
                                style: lightTheme.textTheme.labelSmall!
                                    .copyWith(
                                        fontSize: 12,
                                        color: isSelected == 0
                                            ? Colors.white
                                            : Colors.grey),

                                /*    style: TextStyle(
                                    fontSize: 12,
                                    ),*/
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSelected = 1;
                            _pageController.jumpToPage(1);
                            //
                            // _pageController.animateToPage(
                            //   1,
                            //   duration: const Duration(milliseconds: 400),
                            //   curve: Curves.easeInOut,
                            // );
                          });
                        },
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            color: isSelected == 1
                                ? const Color(0xfff76613)
                                : Colors.transparent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 3, top: 3),
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_box_outlined,
                                color: isSelected == 1
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              Text(
                                'Operations',
                                style: lightTheme.textTheme.labelSmall!
                                    .copyWith(
                                        fontSize: 12,
                                        color: isSelected == 1
                                            ? Colors.white
                                            : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSelected = 2;
                            _pageController.jumpToPage(2);

                            /*_pageController.animateToPage(
                                    2,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );*/
                          });
                        },
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            color: isSelected == 2
                                ? const Color(0xfff76613)
                                : Colors.transparent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 3, top: 3),
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shop_outlined,
                                color: isSelected == 2
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              Text(
                                'Retail',
                                style: lightTheme.textTheme.labelSmall!
                                    .copyWith(
                                        fontSize: 12,
                                        color: isSelected == 2
                                            ? Colors.white
                                            : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSelected = 3;
                            // _pageController.position==3;
                            _pageController.jumpToPage(3);

                            /*  _pageController.animateToPage(
                                    3,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );*/
                          });
                        },
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            color: isSelected == 3
                                ? const Color(0xfff76613)
                                : Colors.transparent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 3, top: 3),
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              Icon(
                                Icons.perm_identity_sharp,
                                color: isSelected == 3
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              Text(
                                'Profile',
                                style: lightTheme.textTheme.labelSmall!
                                    .copyWith(
                                        fontSize: 12,
                                        color: isSelected == 3
                                            ? Colors.white
                                            : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Visibility(
              visible: comp,
              child: Container(
                padding: const EdgeInsets.only(bottom: 65, right: 10),
                margin: const EdgeInsets.only(),
                width: double.infinity,
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  children: [
                    const Spacer(),
                    Visibility(
                      visible: comp,
                      child: SizedBox(
                        // height:comp?200:0 ,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 5),
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Text(
                                    'We care',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                FloatingActionButton(
                                  backgroundColor: Colors.green,
                                  child: const Icon(Icons.airplane_ticket),
                                  onPressed: () {
                                    setState(() {
                                      comp = false;
                                    });
                                    // showAuditSummaryDialog(context);
                                    Get.to(const WeCareScreen());
                                  },
                                ),
                                // IconButton(onPressed: (){}, icon: Icon(Icons.airplane_ticket),),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        // backgroundColor: Colors.grey,
                        child: Icon(comp ? Icons.close : Icons.add),
                        onPressed: () {
                          setState(() {
                            if (comp) {
                              comp = false;
                            } else {
                              comp = true;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 65, right: 10),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  // backgroundColor: Colors.grey,
                  child: Icon(comp ? Icons.close : Icons.add),
                  onPressed: () {
                    setState(() {
                      if (comp) {
                        comp = false;
                      } else {
                        comp = true;
                      }
                    });
                  },
                ),
              ),
            ),
            Visibility(
                visible: loading,
                child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.all(20),
                        height: 115,
                        width: 150,
                        child: const Column(
                          children: [
                            CircularProgressIndicator(),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Please wait..'),
                            )
                          ],
                        )))),
          ],
        )),
      ),
    );
  }

  bool loading = false;

  var comp = false;

  Future<void> getHomeData() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      locationCode = prefs.getString('locationCode') ?? '106';
      var userID = prefs.getString('userCode') ?? '105060';

      String url = "${Constants.apiHttpsUrl}/Login/gethomepage/$userID";
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var respo = jsonDecode(response.body);

        if (respo['statuscode'] == "200") {
          setState(() {
            loading = false;
          });
          if (respo['imageUrl'] != "" && respo['desctext'] == "") {
            _showImageAlert(context, respo['imageUrl']);
          } else if (respo['imageUrl'] == "" && respo['desctext'] != "") {
            _showTextAlert(context, respo['desctext']);
          }
        }
      } else {
        /*_showRetryAlert(
            'Status Code:${response.statusCode}\n${Constants.networkIssue}');*/
        setState(() {
          isUpdated = false;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        isUpdated = false;
      });
      // _showRetryAlert(Constants.networkIssue);
    }
  }
  void showAuditSummaryDialog(BuildContext context) async {
    AuditSummary? summary = await fetchAuditSummary();

    if (summary != null) {
      Get.defaultDialog(
        title: "Audit Summary",
        content: SizedBox(
          height: MediaQuery.of(context).size.height /
              1.7, // Set a fixed height to allow scrolling
          width: double.maxFinite, // Make sure it takes full width
          child: Scrollbar(
            thumbVisibility: true, // Always show the scrollbar

            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Start: ${summary.auditStartTime}"),
                        Text("End: ${summary.auditEndTime}"),
                      ],
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      // Ensures ListView takes only necessary space
                      physics: const NeverScrollableScrollPhysics(),
                      // Prevents ListView from scrolling separately
                      itemCount: summary.sections.length,
                      itemBuilder: (context, index) {
                        final section = summary.sections[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "${section.sectionName} ",
                                    style: const TextStyle(
                                      // fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    " Score: ${section.yourRatingScore}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                    Text(
                      "Your Score: ${summary.yourRatingScore}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      "Percentage: ${summary.percentage}%",
                      style: const TextStyle(
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        textConfirm: "Continue",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        cancelTextColor: Colors.white,
        confirm: InkWell(
          onTap: () {
            // submitAllDilo();
            Get.back(); // Close dialog
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(16)),
            child:
            const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ),
        cancel: InkWell(
          onTap: () {
            Get.back(); // Close dialog
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(16)),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ),
        onConfirm: () {
          Get.back(); // Close dialog
        },
        onCancel: () {
          Get.back(); // Close dialog

        },
      );
    } else {
      Get.snackbar(
        "Error",
        "Failed to load audit summary.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<AuditSummary?> fetchAuditSummary() async {
    final response = await http.get(
      Uri.parse('https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/AreaManager/GetAreamanagerSummary/777052324900043'),
    );

    if (response.statusCode == 200) {
      return AuditSummary.fromJson(jsonDecode(response.body));
    } else {
      // Handle the error accordingly
      print('Failed to load audit summary');
      return null;
    }
  }
  void _showImageAlert(BuildContext context, String image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(image, loadingBuilder: (BuildContext context,
                  Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      Text(
                        'Please wait while image loading',
                        style: lightTheme.textTheme.labelSmall!
                            .copyWith(fontSize: 12),
                      )
                    ],
                  ); // Show loading indicator
                }
              }),
              const SizedBox(height: 16),
              CustomElevatedButton(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  }),
            ],
          ),
        );
      },
    );
  }

  void _showTextAlert(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Text(text)), // Replace with your image path
              const SizedBox(height: 16),
              CustomElevatedButton(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  }),
            ],
          ),
        );
      },
    );
  }



  BottomNavigationBarItem buildBottomNavigationBarItem(
      IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: ClipRRect(
          child: Column(
            children: [
              Icon(icon),
              Text(label),
            ],
          ),
        ),
      ),
      label: '',
    );
  }

  Future<void> _showRetryAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(msg),
          actions: <Widget>[
            CustomElevatedButton(
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            const SizedBox(
              width: 10,
            ),
            CustomElevatedButton(
                text: 'Retry',
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }
}
