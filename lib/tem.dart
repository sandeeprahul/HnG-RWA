import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/common/zoomable_image.dart';
import 'package:hng_flutter/repository/employee_checklist_submit_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'data/ActiveCheckListEmployee.dart';
import 'data/GetActvityTypes.dart';
import 'helper/confirmDialog.dart';
import 'helper/simpleDialog.dart';

class CheckListPage extends StatefulWidget {
  final ActiveCheckListEmployee activeCheckList;
  final int isEdit;
  final String locationsList;
  final GetActvityTypes mGetActivityTypes;
  final int sendingToEditAmHeaderQuestion;
  final String checkListItemMstId;

  const CheckListPage(
      {super.key,
      required this.activeCheckList,
      required this.isEdit,
      required this.locationsList,
      required this.mGetActivityTypes,
      required this.sendingToEditAmHeaderQuestion,
      required this.checkListItemMstId});

  @override
  _CheckListPageState createState() => _CheckListPageState();
}

class _CheckListPageState extends State<CheckListPage> {
  final PageController _pageController = PageController();
  List<CheckListItem> checkListItems = [];
  bool isLoading = true;

  Question? _question;
  var dropDownOptionAnswer = '';
  var dropDownOptionAnswerID = '';
  var non_Compliance_Flag = '';
  bool photoMandatoryFlag = false;
  int _currentPage = 0; // To track the current page

  @override
  void initState() {
    super.initState();
    loadCheckListData(); // Fetch data from the API
  }

  // Fetch checklist data from API
  Future<void> loadCheckListData() async {
    try {
      // Replace this with your API endpoint
      final response = await http.get(Uri.parse(
          'https://rwaweb.healthandglowonline.co.in/RWASTAFFMOVEMENT_TEST/api/Employee/QuestionAnswersList/777042324000132/70002/70002'));
      // final response = await http.get(Uri.parse('https://your-api-endpoint.com/checklist'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          checkListItems =
              data.map((item) => CheckListItem.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load checklist items');
      }
    } catch (e) {
      print('Error loading checklist items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    camController?.dispose();

    super.dispose();
  }

  bool loading = false;

  Future<void> hitQuestionCancel() async {
    ApiService apiService = ApiService(baseUrl: Constants.apiHttpsUrl);

    final EmployeeSubmitChecklistRepository checklistRepo =
        EmployeeSubmitChecklistRepository(
            apiService: apiService); // Initialize the repository

    setState(() {
      loading = true;
    });

    bool success = await checklistRepo.questionCancel(
      checklistAssignId: widget.activeCheckList.empChecklistAssignId,
      checklistMstItemId: widget.activeCheckList.checklisTId,
    );

    setState(() {
      loading = false;
    });
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void onBackPressed() async {
    showConfirmDialog(
        onConfirmed: () {
          Get.back();
          hitQuestionCancel();
        },
        title: 'Alert!',
        msg: 'Are you sure to want go back?');
  }

  Future<void> submitAllDilo() async {
    ApiService apiService = ApiService(baseUrl: Constants.apiHttpsUrl);

    final EmployeeSubmitChecklistRepository checklistRepo =
        EmployeeSubmitChecklistRepository(
            apiService: apiService); // Initialize the repository

    /* setState(() {
      loading = true;
    });*/

    var success = await checklistRepo.submitAllDilo(
      checklistAssignId: widget.activeCheckList.empChecklistAssignId,
      checklistMstItemId: widget.activeCheckList.checklisTId,
    );

    // setState(() {
    //   loading = false;
    // });
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (isConsumed, result) async {
        // Trigger the question cancel method on back press
        // bool canGoBack = ;

        if (isConsumed) {
        } else {
          onBackPressed();
        }
        // print('1');
        /*  if (canGoBack) {
          return true; // Allow pop and consume result
        } else {
          return false; // Reject if question cancel failed
        }*/
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.activeCheckList.empChecklistAssignId}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        body: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator()) // Show loader while loading data
            : PageView.builder(
                controller: _pageController,
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: checkListItems.length,
                // Number of checklist items (pages)

                itemBuilder: (context, index) {
                  var checkListItem =
                      checkListItems[index]; // Get the current checklist item
                  return camVisible
                      ? Visibility(
                          visible: camController == null ? false : camVisible,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: double.infinity,
                                  width: double.infinity,
                                  child: camController == null
                                      ? const CircularProgressIndicator()
                                      : CameraPreview(camController!),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: InkWell(
                                    onTap: () async {
                                      try {
                                        final image =
                                            await camController!.takePicture();
                                        setState(() {
                                          imagePath = image.path;
                                          camVisible = false;
                                        });
                                        _cropImage(image.path);
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 35,
                                        child: Icon(Icons.camera),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                checkListItem
                                    .itemName!, // Display the checklist item name
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView.builder(
                                itemCount: checkListItem.questions!.length,
                                // Number of questions for this checklist item
                                itemBuilder: (context, questionIndex) {
                                  var question =
                                      checkListItem.questions![questionIndex];
                                  _question =
                                      checkListItem.questions![questionIndex];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: Column(
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.start,
                                      children: [
                                        if (question.answerTypeId != 7)
                                          Text(
                                            question
                                                .questionText!, // Display question
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        const SizedBox(height: 10),
                                        if (question.answerTypeId ==
                                            1) // Comment type question
                                          TextField(
                                            decoration: InputDecoration(
                                              hintText: question.questionText,
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                            onChanged: (value) {
                                              // Handle comment input
                                              question.answer = value;
                                            },
                                          ),
                                        if (question.answerTypeId ==
                                            4) // Dropdown question
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            child: DropdownButton<String>(
                                              underline: const SizedBox(),
                                              isExpanded: true,
                                              icon: const Icon(Icons
                                                  .keyboard_arrow_down_outlined),
                                              value: question.selectedOption,
                                              hint: const Text(
                                                  'Select an option'),
                                              items: question.options!
                                                  .map((option) =>
                                                      DropdownMenuItem<String>(
                                                        value:
                                                            option.answerOption,
                                                        child: Text(option
                                                                .answerOption ??
                                                            ''),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  question.selectedOption =
                                                      value;
                                                  dropDownOptionAnswer =
                                                      value!; // Store selected answer

                                                  // Find the selected option based on the answerOption
                                                  Option selectedOption = question
                                                      .options!
                                                      .firstWhere((option) =>
                                                          option.answerOption ==
                                                          value);

                                                  // Now store the corresponding answerOptionId
                                                  dropDownOptionAnswerID =
                                                      "${selectedOption.checkListAnswerOptionId}";

                                                  non_Compliance_Flag =
                                                      "${selectedOption.nonComplianceFlag}";
                                                });
                                                print(dropDownOptionAnswerID);
                                              },
                                            ),
                                            /*DropdownButton<String>(
                                  underline: const SizedBox(),
                                  isExpanded: true,
                                  icon: const Icon(Icons
                                      .keyboard_arrow_down_outlined),
                                  value: question.selectedOption,
                                  hint:
                                  const Text('Select an option'),
                                  items: question.options!
                                      .map((option) =>
                                      DropdownMenuItem<String>(
                                        value:
                                        option.answerOption,
                                        child: Text(
                                            option.answerOption!),
                                      ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      question.selectedOption =
                                          value;
                                      dropDownOptionAnswer =
                                      value!; // Store selected answer
                                      dropDownOptionAnswerID = question.selectedOption!;
                                    });
                                  },
                                )*/
                                          ),
                                        // Handle custom widget for answerTypeId == 3
                                        if (question.answerTypeId == 3)
                                          Padding(
                                              padding: const EdgeInsets.all(10),
                                              // Padding for the new widget
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'ATTACH PROOF',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10,
                                                              top: 10),
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          5)),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey)),
                                                      child: Row(
                                                        children: [
                                                          InkWell(
                                                            child: Container(
                                                                margin: const EdgeInsets
                                                                    .only(
                                                                    bottom: 10,
                                                                    top: 10),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        const BorderRadius.all(Radius.circular(
                                                                            5)),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey)),
                                                                child:
                                                                    _body() /*imageList.isEmpty
                                                ? _body()
                                                : imageList.isEmpty
                                                    ? _body()
                                                    :*/
                                                                ),
                                                            onTap: () {
                                                              setState(() {
                                                                cameraOpen = 0;
                                                              });
                                                              getPhoto();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        // if (question.answerTypeId == 3)
                                        //  ,

                                        if (question.answerTypeId == 7)
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: InkWell(
                                              onTap:(){
                                                Get.to(ZoomableImage(imageUrl: 'https://storage.googleapis.com/hng-offline-marketing.appspot.com${question.options![0].answerOption}'));
                                              },
                                              child: SizedBox(
                                                height: 200,
                                                width: 150,
                                                child: Card(
                                                  color:Colors.orange,
                                                  child: Image.network(
                                                    'https://storage.googleapis.com/hng-offline-marketing.appspot.com${question.options![0].answerOption}',
                                                    height: 200,

                                                    width: 150,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          const SizedBox.shrink()
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                _submitCheckListItem(checkListItem);
                              },
                              child: Container(
                                height: 50,
                                margin: EdgeInsets.zero,
                                // Remove margins

                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                ),
                                width: double.infinity,
                                child: const Center(
                                    child: Text('Submit',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18))),
                              ),
                            ),
                          ],
                        );
                },
                onPageChanged: (v) {
                  for (int v = 0; v < checkListItems.length; v++) {
                    bool hasMandatoryOption = checkListItems[v]
                        .questions![0]
                        .options!
                        .any((option) => option.option_mandatory_Flag == "1");

                    if (hasMandatoryOption) {
                      print(
                          "Checklist item ${checkListItems[v].checkListItemId} has at least one mandatory option.");
                      setState(() {
                        photoMandatoryFlag = true;
                      });
                    } else {
                      setState(() {
                        photoMandatoryFlag = false;
                      });
                      print(
                          "Checklist item ${checkListItems[v].checkListItemId} has no mandatory options.");
                    }
                  } // print(checkListItems[v].questions[0].options.contains(element));
                  setState(() {
                    _currentPage = v; // Update the current page
                  });
                },
              ),
      ),
    );
  }

  Widget _body() {
    if (_croppedFile != null) {
      return _imageCard();
    } else {
      return const Icon(
        Icons.photo,
        size: 50,
      );
    }
  }

  Widget multipleImages() {
    return Column(
      children: imageList
          .map((imgPath) => Image.file(
                File(imgPath),
                height: 100,
                width: 100,
              ))
          .toList(),
    );
  }

  Widget _imageCard() {
    return Center(
      child: SizedBox(height: 100, width: 110, child: _image()),
    );
  }

  var _croppedFile;

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _submitCheckListItem(CheckListItem checkListItem) {
    // Submit the checklist item data
    print('Submitting checklist item: ${checkListItem.itemName}');
    // Here you can add logic to send the answers back to the server or handle locally
    for (var question in checkListItem.questions!) {
      print('Question: ${question.questionText}');
      print('Answer: ${question.answer ?? question.selectedOption}');
    }
    showConfirmDialog(
        onConfirmed: () {
          handleChecklistSubmission(checkListItem);
        },
        title: 'Alert!',
        msg: "Are you sure you want to proceed?");
  }

  Future<void> getPhoto() async {
    final ImagePicker _picker = ImagePicker();

    if (cameraOpen == 0) {
      setState(() {
        cameraOpen = 1;
      });

      if (Platform.isAndroid) {
        try {
          final cameras = await availableCameras(); // get available cameras
          final frontCam = cameras[0];

          camController = CameraController(frontCam, ResolutionPreset.medium);
          await camController?.initialize();
          if (!mounted) return;

          setState(() {
            camVisible = true;
          });
        } on CameraException catch (e) {
          print('Error in fetching cameras: $e');
        }
      } else {
        // for iOS or other platforms
        var photo = await _picker.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.rear);
        _cropImage(photo);
      }
    }
  }

  CameraController? camController;
  String imagePath = "";
  bool camVisible = false;
  int cameraOpen = 0;
  var base64img_ = '';
  List<String> imageList = [];

  Future<void> _cropImage(var photo) async {
    if (photo != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: Platform.isAndroid ? photo : photo!.path,
        compressFormat: ImageCompressFormat.jpg,
        maxWidth: 1920,
        maxHeight: 1080,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _croppedFile = XFile(croppedFile.path);
          imageList.add(croppedFile.path);
        });

        final imageBytes = await File(croppedFile.path).readAsBytes();
        setState(() {
          base64img_ = base64.encode(imageBytes);
        });

        print("Base64 Image: $base64img_");
      }
    }
  }

  Future<void> addToJson(
      int answerTypeId,
      String itemName,
      String question,
      String checkListAnswerId,
      String answerOption,
      int orderFlag,
      String imageName,
      String checkList_Answer_Option_Id_,
      String non_Compliance_Flag) async {
    final prefs = await SharedPreferences.getInstance();

    String dateForEmpCode_ =
        DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
    var userId = prefs.getString("userCode");
    String empCode = "EMP$userId$dateForEmpCode_";
    String datetime = DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());

    List<Map<String, dynamic>> sendJson = [];
    sendJson.add({
      "emp_checklist_assign_id": widget.activeCheckList.empChecklistAssignId,
      "checkList_Item_Mst_Id": widget.isEdit == 0
          ? widget.activeCheckList.checklisTId
          : widget.activeCheckList.checklisTId,
      "checklist_Id": widget.activeCheckList.checklisTId,
      "empcode":
          widget.isEdit == 1 ? widget.sendingToEditAmHeaderQuestion : userId,
      "item_name": itemName,
      "checkList_Answer_Id": checkListAnswerId,
      "question": question,
      "answer_Type_Id": answerTypeId,
      "mandatory_Flag": 0,
      "active_Flag": 0,
      "checkList_Answer_Option_Id": checkList_Answer_Option_Id_,
      "answer_Option": answerOption,
      "we_Care_Flag": widget.activeCheckList.weCareFlag,
      "non_Compliance_Flag": non_Compliance_Flag,
      "pos_bos_flag": widget.activeCheckList.posBosFlag,
      "order_flag": orderFlag,
      "checklist_assign_id": 0,
      "created_by": userId,
      "created_datetime": datetime,
      "updated_by": userId,
      "updated_by_datetime": datetime,
      "checklist_applicable_type":
          widget.activeCheckList.checklistApplicableType,
      "checklist_progress_status": "",
      "checklist_edit_status": "C",
      "questionstatus": "Completed",
      "imagename": imageName
    });
    print("Data to submit: $sendJson");

    ApiService apiService = ApiService(baseUrl: Constants.apiHttpsUrl);
    EmployeeSubmitChecklistRepository checklistRepo =
        EmployeeSubmitChecklistRepository(apiService: apiService);

    try {
      // Check if the answer type requires a photo
      if (_question!.answerTypeId == 3 &&
          photoMandatoryFlag &&
          base64img_.isEmpty) {
        // If photo is mandatory and not provided, show alert
        showSimpleDialog(title: 'Alert!', msg: 'Please take photo');
      } else {
        // If photo is provided or not mandatory, proceed with posting data
        if (base64img_.isNotEmpty) {
          cloudstorageRef(base64img_, empCode, sendJson);
        } else {
          await checklistRepo.postChecklistData(sendJson);

          _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.linear);
        }

        /* Get.snackbar(
          'Alert!', 'Checklist posted successfully!',
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM, // Set gravity to bottom
        );*/
        showSimpleDialog(
            title: 'Alert!', msg: 'Checklist posted successfully!');
        // Move to the next page

        if (_currentPage == checkListItems.length - 1) {
          submitAllDilo();
          // Navigator.pop(context);
        }
        print('Checklist posted successfully!');
      }
    } catch (e) {
      print('Failed to post checklist: $e');
    }
  }

  Future<void> cloudstorageRef(var img, var empcode, var sendJson) async {
    final prefs = await SharedPreferences.getInstance();

    String empCode = empcode;

    // FirebaseStorage storageRefd = FirebaseStorage.instanceFor(bucket: "gs://hgstores_rwa_dilo");
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://hng-offline-marketing.appspot.com")
        .ref();
    //gs://loghng-942e6.appspot.com
    //gs://hng-offline-marketing.appspot.com//original

    var locationCode = widget.activeCheckList.locationCode;

    final imagesRef = storageRef.child("$locationCode/QuesAns/$empCode.jpg");

    try {
      // await imagesRef.putString(img, format: PutStringFormat.dataUrl);
      await imagesRef
          .putString(img,
              format: PutStringFormat.base64,
              metadata: SettableMetadata(contentType: 'image/png'))
          .then((p0) {
        print('uploaded to firebase storage successfully$p0');
      });

      // Navigator.pop(context);
      // String downloadUrl = (await FirebaseStorage.instanceFor(bucket: "gs://hng-offline-marketing.appspot.com").ref().getDownloadURL()).toString();
      String downloadUrl = (await FirebaseStorage.instanceFor(
                  bucket: "gs://loghng-942e6.appspot.com")
              .ref())
          .toString();

      print(downloadUrl);

      Get.defaultDialog(
          title: "Info",
          middleText: "Image post success",
          backgroundColor: Colors.white,
          titleStyle: const TextStyle(color: Colors.black),
          middleTextStyle: const TextStyle(color: Colors.black),
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            Navigator.pop(context);
            // Navigator.pop(context);
          },
          radius: 15);
      ApiService apiService = ApiService(baseUrl: Constants.apiHttpsUrl);
      EmployeeSubmitChecklistRepository checklistRepo =
          EmployeeSubmitChecklistRepository(apiService: apiService);
      try {
        await checklistRepo.postChecklistData(sendJson);
        showSimpleDialog(
            title: 'Alert!', msg: 'Checklist posted successfully!');
        if (_currentPage != checkListItems.length - 1) {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.linear);
        }
      } catch (e) {
        showSimpleDialog(title: 'Alert!', msg: 'Failed to post checklist: $e');
      }
    } on FirebaseException catch (e) {
      showSimpleDialog(title: 'Alert!', msg: 'Failed to upload image');
    }
  }

  Future<void> handleChecklistSubmission(CheckListItem checkListItem) async {
    final prefs = await SharedPreferences.getInstance();
    String dateForEmpCode_ =
        DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
    var userId = prefs.getString("userCode");
    String empCode = "EMP$userId$dateForEmpCode_";
    /*if (option_mandatory_Flag == "-1") {
      addToJson(
          quesAnsList[0].questions[0].answerTypeId,
          quesAnsList[0].itemName,
          quesAnsList[0].questions[0].question,
          quesAnsList[0].questions[0].checkListAnswerId,
          dropdownText,
          int.parse(quesAnsList[0].questions[0].orderFlag),
          "");
    }*/
    // else {
    for (int i = 0; i < checkListItem.questions!.length; i++) {
      var currentQuestion = checkListItem.questions![i];
      String answerOption = '';

      if (currentQuestion.answerTypeId == 4) {
        answerOption = dropDownOptionAnswer;
      } else if (currentQuestion.answerTypeId == 1) {
        answerOption = _question!.answer!;
      } else if (currentQuestion.answerTypeId == 3) {
        answerOption = '';
      }

      String imageName =
          currentQuestion.answerTypeId == 3 ? "$empCode.jpg" : "";

      addToJson(
          currentQuestion.answerTypeId!,
          _question!.questionText!,
          currentQuestion.questionText!,
          currentQuestion.checkListAnswerId!,
          answerOption,
          int.parse(currentQuestion.orderFlag!),
          imageName,
          dropDownOptionAnswerID,
          non_Compliance_Flag);
    }
    // }
  }
}

// Data Models
class CheckListItem {
  int? checkListItemId;
  int? checklistId;
  String? department_Name;
  dynamic questionstatus; // dynamic can stay as it is.
  String? itemName;
  List<Question>? questions;

  CheckListItem({
    this.checkListItemId,
    this.checklistId,
    this.department_Name,
    this.questionstatus,
    this.itemName,
    this.questions,
  });

  factory CheckListItem.fromJson(Map<String, dynamic> json) {
    return CheckListItem(
      checkListItemId: json['checkList_Item_Id'] ?? 0,
      // Default to 0 if null
      itemName: json['item_name'] ?? '',
      // Default to empty string if null
      checklistId: json['checklistId'] ?? 0,
      // Default to 0 if null
      department_Name: json['department_Name'] ?? 'Unknown',
      // Default to 'Unknown' if null
      questionstatus: json['questionstatus'] ?? 'Not Set',
      // Default to 'Not Set' if null
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [], // Default to empty list if null
    );
  }
}

class Question {
  String? checkListAnswerId;
  String? questionText;
  int? answerTypeId;
  List<Option>? options;
  String? orderFlag;
  String? answer; // Comment field (nullable)
  String? selectedOption; // Dropdown selected option (nullable)

  Question({
    this.checkListAnswerId,
    this.questionText,
    this.answerTypeId,
    this.options,
    this.orderFlag,
    this.answer,
    this.selectedOption,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      checkListAnswerId: json['checkList_Answer_Id'] ?? '0',
      // Default to empty string
      questionText: json['question'] ?? 'No question provided',
      // Default to fallback text
      answerTypeId: json['answer_Type_Id'] ?? 0,
      // Default to 0 if null
      orderFlag: json['order_Flag'] ?? 'N/A',
      // Default to 'N/A'
      options: (json['options'] as List<dynamic>?)
              ?.map((option) => Option.fromJson(option as Map<String, dynamic>))
              .toList() ??
          [], // Default to empty list if null
    );
  }
}

class Option {
  String? answerOption;
  String? weCareFlag;
  String? nonComplianceFlag;
  String? option_mandatory_Flag;
  int? checkListAnswerOptionId;

  Option({
    this.answerOption,
    this.checkListAnswerOptionId,
    this.weCareFlag,
    this.nonComplianceFlag,
    this.option_mandatory_Flag,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      answerOption: json['answer_Option'] ?? '',
      // Default to empty string
      weCareFlag: json['we_Care_Flag'] ?? 'No',
      // Default to 'No' if null
      nonComplianceFlag: json['non_Compliance_Flag'] ?? 'No',
      // Default to 'No'
      option_mandatory_Flag: json['option_mandatory_Flag'] ?? 'No',
      // Default to 'No'
      checkListAnswerOptionId:
          json['checkList_Answer_Option_Id'] ?? 0, // Default to 0 if null
    );
  }
}
