import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/common/constants.dart';
import 'package:hng_flutter/common/zoomable_image.dart';
import 'package:hng_flutter/presentation/camera_page.dart';
import 'package:hng_flutter/repository/employee_checklist_submit_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'checkListScreen_lpd.dart';
import 'controllers/camerapageController.dart';
import 'controllers/progressController.dart';
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
  // final PageController _pageController = PageController();
  List<CheckListItem> checkListItems = [];
  bool isLoading = false;
  final CameraPageController cameraPageController =
      Get.put(CameraPageController());

  final ProgressController progressController = Get.put(ProgressController());
  Question? _question;
  var dropDownOptionAnswer = '';
  var dropDownOptionAnswerID = '';
  var non_Compliance_Flag = '';
  bool photoMandatoryFlag = false;
  List<GlobalKey> itemKeys = [];

  @override
  void initState() {
    super.initState();
    loadCheckListData(); // Fetch data from the API

    _scrollController.addListener(_scrollListener);
    // If there's only one item, we consider it as being at the "bottom" initially
    if (checkListItems.length == 1) {
      setState(() {
        isAtBottom = true;
      });
    }
  }

  // Fetch checklist data from API
  Future<void> loadCheckListData() async {
    try {
      setState(() {
        isLoading = true;
      });
      // Replace this with your API endpoint
      final pref = await SharedPreferences.getInstance();
      var empCode = pref.getString("userCode");

      final response = await http.get(Uri.parse(
          'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Employee/QuestionAnswersList/${widget.activeCheckList.empChecklistAssignId}/$empCode/$empCode'));
      print(
          'https://rwaweb.healthandglowonline.co.in/RWA_GROOMING_API/api/Employee/QuestionAnswersList/${widget.activeCheckList.empChecklistAssignId}/$empCode/$empCode');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          checkListItems =
              data.map((item) => CheckListItem.fromJson(item)).toList();
          isLoading = false;
        });
        itemKeys = List.generate(checkListItems.length, (index) => GlobalKey());
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
    camController?.dispose();
    // _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    submittedItems.clear();
    cameraPageController.clearCroppedImageFile();
    super.dispose();
  }

  void _scrollListener() {
    // Check if scrolled to the bottom
    if (_scrollController.position.atEdge) {
      bool isBottom = _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      if (isBottom && !isAtBottom) {
        setState(() {
          isAtBottom = true;
        });
        print("Reached the bottom of the list");
      } else if (!isBottom && isAtBottom) {
        setState(() {
          isAtBottom = false;
        });
      }
    }
  }

  Future<void> hitQuestionCancel() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    ApiService apiService = ApiService(baseUrl: Constants.apiHttpsUrl);

    final EmployeeSubmitChecklistRepository checklistRepo =
        EmployeeSubmitChecklistRepository(
            apiService: apiService,
            preferences: sharedPreferences); // Initialize the repository

    setState(() {
      isLoading = true;
    });

    bool success = await checklistRepo.questionCancel(
      checklistAssignId: widget.activeCheckList.empChecklistAssignId,
      checklistMstItemId: widget.activeCheckList.checklisTId,
    );

    setState(() {
      isLoading = false;
    });
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => checkListScreen_lpd(
            1,
            widget.mGetActivityTypes,
            widget.locationsList,
          ),
        ));
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
    progressController.show();
    final sharedPreferences = await SharedPreferences.getInstance();

    ApiService apiService = ApiService(baseUrl: Constants.apiHttpsUrl);

    final EmployeeSubmitChecklistRepository checklistRepo =
        EmployeeSubmitChecklistRepository(
            apiService: apiService,
            preferences: sharedPreferences); // Initialize the repository

    /* setState(() {
      loading = true;
    });*/

    var success = await checklistRepo.submitAllDilo(
      checklistAssignId: widget.activeCheckList.empChecklistAssignId,
      checklistMstItemId: widget.activeCheckList.checklisTId,
    );

    /* setState(() {
      loading = false;
    });
*/
    progressController.hide();

    // showConfirmDialog(onConfirmed: (){}, title: 'Success', msg: '')
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => checkListScreen_lpd(
            1,
            widget.mGetActivityTypes,
            widget.locationsList,
          ),
        ));
  }

  final ScrollController _scrollController = ScrollController();
  bool isAtBottom = false;

  // List<CheckListItem> checkListItems = [];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (isConsumed, result) async {
        // Trigger the question cancel method on back press

        if (isConsumed) {
        } else {
          onBackPressed();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Questions List')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
             isLoading
                ? const Center(
              child:
              CircularProgressIndicator(), // Display progress indicator
            )
                : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    // shrinkWrap: true, // Allows ListView to work within a SingleChildScrollView
                    // physics: const NeverScrollableScrollPhysics(), // Disables inner ListView scroll
                    // itemCount:1,
                    itemCount: checkListItems.length,
                    itemBuilder: (context, questionIndex) {
                      var checkListItem = checkListItems[
                      questionIndex]; // Get the current checklist item

                      return Card(
                        key: itemKeys[questionIndex],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                // Allows ListView to work within a SingleChildScrollView
                                physics:
                                const NeverScrollableScrollPhysics(),
                                // Disables inner ListView scroll
                                itemCount:
                                checkListItem.questions!.length,
                                itemBuilder:
                                    (context, subQuestionIndex) {
                                  var question = checkListItem
                                      .questions![subQuestionIndex];

                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 20),

                                      // Display question text
                                      // if (question.answerTypeId != 7)
                                      buildQuestionText(question),
                                      const SizedBox(height: 10),

                                      // Different UI for each answer type
                                      if (question.answerTypeId == 1)
                                        buildCommentField(question),
                                      if (question.answerTypeId == 4)
                                        buildDropdown(question),
                                      if (question.answerTypeId == 3)
                                        buildAttachProofWidget(
                                            question),

                                      /*if(question.answerTypeId==8)
                                        buildAttachMultipleProofWidget(question),*/

                                      // if (question.answerTypeId == 7) buildImageWidget(question),
                                      // Separate each question visually
                                    ],
                                  );
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  _submitCheckListItem(
                                      checkListItem, questionIndex);
                                },
                                child: Container(
                                  height: 45,
                                  margin: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    color: !submittedItems.contains(checkListItem.checkListItemId)?Colors.blue:Colors.green,
                                  ),
                                  width: double.infinity,
                                  child:  Center(
                                      child: Obx(
                                         () {
                                          return Text(progressController.isLoading.value?'Submitting..': !submittedItems.contains(checkListItem.checkListItemId)?'Submit':'Submitted',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18));
                                        }
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder:
                        (BuildContext context, int index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          thickness: 2.0,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: isAllSubmitted
                      ? () {
                    showConfirmDialog(
                      onConfirmed: () {
                        submitAllDilo();
                      },
                      title: "Submit all?",
                      msg: "Are you sure?",
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAllSubmitted
                        ? Colors.green
                        : Colors.grey[700],
                    // Background color
                    // onPrimary: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(
                        double.infinity, 50), // Width and height
                  ),
                  child: const Text(
                    'Submit All',
                    style:
                    TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            )
          ,
        ),
      ),
    );
  }

// Modular helper widgets

  Widget buildQuestionText(Question question) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${question.questionText}: ' ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (question.answerTypeId == 7) buildImageWidget(question),
      ],
    );
  }

  Widget buildCommentField(Question question) {
    return TextField(
      decoration: InputDecoration(
        hintText: question.questionText,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        question.answer = value;
      },
    );
  }

  Widget buildDropdown(Question question) {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButton<String>(
        underline: const SizedBox(),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_outlined),
        value: question.selectedOption,
        hint: const Text('Select an option'),
        items: question.options!
            .map((option) => DropdownMenuItem<String>(
                  value: option.answerOption,
                  child: Text(option.answerOption ?? ''),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            question.selectedOption = value;
            dropDownOptionAnswer = value!;

            // Find the selected option based on the answerOption
            Option selectedOption = question.options!
                .firstWhere((option) => option.answerOption == value);

            dropDownOptionAnswerID =
                "${selectedOption.checkListAnswerOptionId}";
            non_Compliance_Flag = "${selectedOption.nonComplianceFlag}";
            print(
                "$dropDownOptionAnswer , $dropDownOptionAnswerID , $non_Compliance_Flag");
          });
        },
      ),
    );
  }

  Widget buildAttachProofWidget(Question question) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.questionText ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 10),
              width: double.infinity,
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  InkWell(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _body(),
                    ),
                    onTap: () {
                      Get.to(() => const CameraPage());

                      /*   setState(() {
                        cameraOpen = 0;
                      });
                      getPhoto();*/
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildAttachMultipleProofWidget(Question question) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            question.questionText ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Obx(() {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // Display captured images
                ...cameraPageController.croppedImageFiles.map((image) {
                  return Stack(
                    children: [
                      Image.file(
                        File(image.path),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            cameraPageController.croppedImageFiles.remove(image);
                          },
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                // Add new image button
                InkWell(
                  onTap: () {
                    cameraPageController.captureAndCropImage();
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.add_a_photo, size: 50),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              print("Captured Images: ${cameraPageController.croppedImageFiles.length}");
            },
            child: const Text("Submit Images"),
          ),
        ],
      ),
    );
  }


  Widget buildImageWidget(Question question) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          Get.to(ZoomableImage(
              imageUrl:
                  'https://storage.googleapis.com/hng-offline-marketing.appspot.com${question.options![0].answerOption}'));
        },
        child: SizedBox(
          height: 100,
          width: 100,
          child: Card(
            color: Colors.orange,
            child: Image.network(
              'https://storage.googleapis.com/hng-offline-marketing.appspot.com${question.options![0].answerOption}',
              height: 200,
              width: 150,
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return Obx(() {
      if (cameraPageController.croppedImageFile.value != null) {
        return Image.file(
          File(cameraPageController.croppedImageFile.value!.path),
          height: 100,
          width: 100,
        );
      } else {
        return const Icon(
          Icons.photo,
          size: 50,
        );
      }
    });
  }

  /*if (_croppedFile != null) {
      return _imageCard();
    } else {
      return const Icon(
        Icons.photo,
        size: 50,
      );
    }
  }*/

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

  void _submitCheckListItem(CheckListItem checkListItem, int questionIndex) {
    // Submit the checklist item data
    print('Submitting checklist item: ${checkListItem.itemName}');
    // Here you can add logic to send the answers back to the server or handle locally
    for (var question in checkListItem.questions!) {
      print('Question: ${question.questionText}');
      print('Answer: ${question.answer ?? question.selectedOption}');
    }
    showConfirmDialog(
        onConfirmed: () {
          handleChecklistSubmission(checkListItem, questionIndex);
        },
        title: 'Alert!',
        msg: "Are you sure you want to proceed?");
  }




  void scrollToKey(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context != null) {
        // Scroll to the widget using ensureVisible
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  CameraController? camController;
  String imagePath = "";
  bool camVisible = false;
  int cameraOpen = 0;
  var base64img_ = '';
  List<String> imageList = [];

  List<int> submittedItems = []; // Tracks submitted items by ID or index
  bool isAllSubmitted = false; // Controls the "Submit All" button state

  Future<void> addToJson(
      int answerTypeId,
      String itemName,
      String question,
      String checkListAnswerId,
      String answerOption,
      int orderFlag,
      String imageName,
      String checkList_Answer_Option_Id_,
      String non_Compliance_Flag,
      Question currentQuestion,
      CheckListItem checkListItem,
      int questionIndex) async {
    final prefs = await SharedPreferences.getInstance();

    final cameraPageController = Get.find<CameraPageController>();


    var userId = prefs.getString("userCode");
    String datetime = DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());

    List<Map<String, dynamic>> sendJson = [];
    sendJson.add({
      "emp_checklist_assign_id": widget.activeCheckList.empChecklistAssignId,
      "checkList_Item_Mst_Id": widget.isEdit == 0
          ? checkListItem.checkListItemId
          : checkListItem.checkListItemId,
      "checklist_Id": widget.activeCheckList.checklisTId,
      "empcode": userId,
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

    final sharedPreferences = await SharedPreferences.getInstance();
    ApiService apiService = ApiService(baseUrl: Constants.apiHttpsUrl);
    EmployeeSubmitChecklistRepository checklistRepo =
        EmployeeSubmitChecklistRepository(
            apiService: apiService, preferences: sharedPreferences);

    progressController.show();
    try {
      // setState(() {
      //   isLoading = true;
      // });
      // Check if the answer type requires a photo
      if (currentQuestion.answerTypeId == 3 &&
          photoMandatoryFlag &&
          cameraPageController.base64img.value.isEmpty) {
        // If photo is mandatory and not provided, show alert
        showSimpleDialog(title: 'Alert!', msg: 'Please take photo');
        progressController.hide();
      } else {
        // If photo is provided or not mandatory, proceed with posting data
        if (currentQuestion.answerTypeId == 3 &&
            cameraPageController.base64img.value.isNotEmpty) {
          cloudstorageRef(cameraPageController.base64img.value, imageName,
              sendJson, checkListItem, questionIndex);
        } else {
          final apiResponse = await checklistRepo.postChecklistData(sendJson);

          if (apiResponse.statusCode == "200") {
            showSimpleDialog(
                title: 'Alert!', msg: 'Checklist posted successfully!');

            // Add to submittedItems if successful
            if (!submittedItems.contains(checkListItem.checkListItemId)) {
              setState(() {
                submittedItems.add(checkListItem.checkListItemId!);
              });
            }
            _checkAllSubmitted();
          } else {
            showSimpleDialog(
                title: 'Alert!',
                msg: '${apiResponse.message}\n${apiResponse.statusCode}');
          }
        }

        /* Get.snackbar(
          'Alert!', 'Checklist posted successfully!',
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM, // Set gravity to bottom
        );*/

        // Move to the next page

        print('Checklist posted successfully!');
      }
    } catch (e) {
      showSimpleDialog(title: 'Alert!', msg: 'Failed to post checklist:$e');
      print('Failed to post checklist: $e');
    } finally {
      progressController.hide();

      // scrollToKey(itemKeys[questionIndex]);
      //
      // setState(() {
      //   isLoading = false;
      // });
      // scrollToIndex(questionIndex);
    }
  }


  // Function to check if all items are submitted
  void _checkAllSubmitted() {
    setState(() {
      // isAllSubmitted = submittedItems.isNotEmpty;
      isAllSubmitted = submittedItems.length == checkListItems.length;
    });
  }

  Future<void> cloudstorageRef(var img, var empcode, var sendJson,
      CheckListItem checkListItem, int questionIndex) async {
    final prefs = await SharedPreferences.getInstance();

    String empCode = empcode;

    // FirebaseStorage storageRefd = FirebaseStorage.instanceFor(bucket: "gs://hgstores_rwa_dilo");
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://hng-offline-marketing.appspot.com")
        .ref();
    //gs://loghng-942e6.appspot.com //testing
    //gs://hng-offline-marketing.appspot.com //original

    var locationCode = widget.activeCheckList.locationCode;

    final imagesRef = storageRef.child("$locationCode/QuesAns/$empCode");
    progressController.show();
    try {
     /* setState(() {
        isLoading = true;
      });*/
      // await imagesRef.putString(img, format: PutStringFormat.dataUrl);
      await imagesRef
          .putString(img,
              format: PutStringFormat.base64,
              metadata: SettableMetadata(contentType: 'image/png'))
          .then((p0) {
        print('uploaded to firebase storage successfully$p0');
      });

      Get.defaultDialog(
          title: "Info",
          middleText: "Image post success",
          backgroundColor: Colors.white,
          titleStyle: const TextStyle(color: Colors.black),
          middleTextStyle: const TextStyle(color: Colors.black),
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            // Navigator.pop(context);
            // Navigator.pop(context);
          },
          radius: 15);
      final sharedPreferences = await SharedPreferences.getInstance();

      ApiService apiService = ApiService(baseUrl: Constants.apiHttpsUrl);
      EmployeeSubmitChecklistRepository checklistRepo =
          EmployeeSubmitChecklistRepository(
              apiService: apiService, preferences: sharedPreferences);
      try {
        final response = await checklistRepo.postChecklistData(sendJson);
        if (response.statusCode == "200") {

          showSimpleDialog(title: 'Alert!', msg: response.message);
          // Add to submittedItems if successful
          if (!submittedItems.contains(checkListItem.checkListItemId)) {
            setState(() {
              submittedItems.add(checkListItem.checkListItemId!);
            });
          }
          _checkAllSubmitted();
        } else {
          showSimpleDialog(title: 'Alert!', msg: response.message);
        }
      } catch (e) {
        showSimpleDialog(title: 'Alert!', msg: 'Failed to post checklist: $e');
      } finally {
        progressController.hide();

        // scrollToKey(itemKeys[questionIndex]);

        // setState(() {
        //   isLoading = false;
        // });
        // scrollToIndex(questionIndex);
      }
    } on FirebaseException catch (e) {
      progressController.hide();

      showSimpleDialog(title: 'Alert!', msg: 'Failed to upload image');

    }
  }

  Future<void> handleChecklistSubmission(
      CheckListItem checkListItem, int questionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    String dateForEmpCode_ =
        DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
    var userId = prefs.getString("userCode");
    String empCode = "EMP$userId$dateForEmpCode_";

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
          currentQuestion.questionText!,
          currentQuestion.questionText!,
          currentQuestion.checkListAnswerId!,
          currentQuestion.answerTypeId == 4
              ? dropDownOptionAnswer
              : (currentQuestion.answerTypeId == 1 ? _question!.answer! : ''),
          int.parse(currentQuestion.orderFlag!),
          imageName,
          currentQuestion.answerTypeId == 3
              ? '${currentQuestion.options![0].checkListAnswerOptionId}'
              : dropDownOptionAnswerID,
          currentQuestion.answerTypeId == 3
              ? '${currentQuestion.options![0].nonComplianceFlag}'
              : non_Compliance_Flag,
          currentQuestion,
          checkListItem,
          questionIndex);
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
