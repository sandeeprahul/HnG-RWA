import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/AmAcceptSelectionScreen.dart';
import 'package:hng_flutter/data/ActiveCheckListLpd.dart';
import 'package:hng_flutter/data/ActiveCheckListStoreAudit.dart';
import 'package:hng_flutter/data/HeaderQuesLpd.dart';
import 'package:hng_flutter/data/HeaderQuesStoreAM.dart';
import 'package:hng_flutter/data/HeaderQuesStoreAudit.dart';
import 'package:hng_flutter/data/HeaderQuestion.dart';
import 'package:hng_flutter/data/LPDSection.dart';
import 'package:hng_flutter/PageHome.dart';
import 'package:hng_flutter/checkListItemScreen.dart';
import 'package:hng_flutter/checkListItemScreen_Lpd.dart';
import 'package:hng_flutter/checkListItemScreen_StoreAudit.dart';
import 'package:hng_flutter/helper/confirmDialog.dart';
import 'package:hng_flutter/helper/simpleDialog.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/constants.dart';
import 'data/ActiveCheckListAm.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/Answeroption.dart';
import 'data/QuestionAnswers.dart';
import 'checkListItemScreen_AM.dart';

class submitCheckListScreen_AM extends StatefulWidget {
  final HeaderQuesStoreAM checkList;
  final ActiveCheckListAm activeCheckList;
  final int i;
  final LPDSection mLpdChecklist;
  final List<HeaderQuesStoreAM> headerQuestion;
  final int position;

  const submitCheckListScreen_AM(this.checkList, this.activeCheckList, this.i,
      this.mLpdChecklist, this.headerQuestion,
      {super.key, required this.position});

  // submitCheckListScreen({Key? key}) : super(key: key);

  @override
  State<submitCheckListScreen_AM> createState() =>
      _submitCheckListScreen_AMState(
          this.checkList, this.activeCheckList, this.mLpdChecklist);
}

List<QuestionAnswers>? list;
List<Question>? listQues;
String item_name = "Loading....";
String checklist_id = "Loading....";
String dropdownText = "";
int quesLength = 0;
var subQues = [];
var questionTitles = [];
var rating_ = 0.0, rating2_ = 0.0;
List<QuestionAnswers> quesAnsList = [];

var options = [];
var nonCompFlag = [];
var checkList_Answer_Option_Id = [];
int checkList_Answer_Option_Id_ = -1;
var non_Compliance_Flag;
var checkList_Answer_Id;

var showpopup = false;
XFile? photo;
bool loading = false;
var _croppedFile;
var imageList = [];
var optionMandatoryFlags = [];
String optionMandatoryFlag = "-1";

class _submitCheckListScreen_AMState extends State<submitCheckListScreen_AM> {
  HeaderQuesStoreAM checkList;
  ActiveCheckListAm activeCheckList;
  LPDSection mLpdChecklist;

  _submitCheckListScreen_AMState(
      this.checkList, this.activeCheckList, this.mLpdChecklist);

  var mandy;
  TextEditingController sealnoCntrl = TextEditingController();

  // String position='';
  late int currentPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getData();
    currentPosition = widget.position; // Store initial position in state
    fetchQuestionData();
    dropdownText = "";
    _croppedFile = null;
    // imageList.clear();
    // options.clear();

    item_name = "Loading....";
    checklist_id = "Loading....";
  }

  void fetchQuestionData() async {
    await getData(widget.position); // Ensure proper async handling
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imageList.clear();
    dropdownText = '';
    _croppedFile = null;
    optionMandatoryFlag = "-1";
    rating_ = 0.0;
    rating2_ = 0.0;
  }

  bool goBack = false;

  Future<bool> _onWillPop() async {
    goBack = false; //false
    setState(() {});
    /* Future.delayed(Duration(milliseconds: 1),(){
      f = false;
    });*/
    return goBack;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: questionCancel,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: ListView(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 15),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              // Navigator.pop(context);
                              /* Get.off(() =>
                                  checkListItemScreen(widget.activeCheckList));*/
                              // Navigator.pushReplacement(context,)
                              // questionCancel();

                              Navigator.of(context).maybePop();
                            },
                            child: const Icon(Icons.arrow_back),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'Area Manager',
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item_name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                      child: Text(
                        '$item_name*',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),

                    //choose the answer
                    Visibility(
                        // visible: quesAnsList[0].questions[0].answerTypeId==4?true:false,
                        visible: false,
                        // visible: subQues.contains(8) ? true : false,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.grey)),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                showpopup = true;
                              });
                              /* if (widget.checkList.checklistEditStatus == 'E') {
                                setState(() {
                                  showpopup = true;
                                });
                              }*/
                            },
                            child: Row(
                              children: [
                                Expanded(child: Text(dropdownText)),
                                const Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        )),
        ListView.separated(
          shrinkWrap: true,
          itemCount: answerOptions.length,
          itemBuilder: (context, pos) {
            return RadioListTile<int>(
              title: Text(
                maxLines: 3,
                answerOptions[pos].answerOption,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              value: answerOptions[pos].checkListAnswerOptionId,
              groupValue: checkList_Answer_Option_Id_,
              onChanged: (value) {
                setState(() {
                  checkList_Answer_Option_Id_ = value!;
                  non_Compliance_Flag = answerOptions[pos].nonComplianceFlag;
                  optionMandatoryFlag = answerOptions[pos].optionMandatoryFlag;
                });
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider();
          },
        ),

                    Visibility(
                      visible: false,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount:
                        options.length, // subQues.contains(4) ? 4 :
                        itemBuilder: (context, pos) {
                          return InkWell(
                            onTap: () {
                              if (widget.checkList.checklistEditStatus ==
                                  'E') {}
                              setState(() {
                                showpopup = false;
                                dropdownText =
                                    answerOptions[pos].answerOption;
                                checkList_Answer_Option_Id_ =
                                    answerOptions[pos]
                                        .checkListAnswerOptionId;
                                non_Compliance_Flag =
                                    answerOptions[pos].nonComplianceFlag;
                                optionMandatoryFlag = answerOptions[pos]
                                    .optionMandatoryFlag;
                              });
                              print('000000non_Compliance_Flag');
                              print(non_Compliance_Flag);
                              print(checkList_Answer_Option_Id_);
                            },
                            child: Text(
                              answerOptions[pos].answerOption,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          );
                        },
                        separatorBuilder:
                            (BuildContext context, int index) {
                          return const Divider();
                        },
                      ),
                    ),
                    //attach proof
                    Visibility(
                        visible: optionMandatoryFlag == "-1"
                            ? false
                            : subQues.contains(3)
                                ? true
                                : false,
                        child: Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subQues.contains(3)
                                    ? mandy == 1
                                        ? 'ATTACH PROOF*'
                                        : 'ATTACH PROOF'
                                    : '',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(bottom: 10, top: 10),
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    border: Border.all(color: Colors.grey)),
                                child: Row(
                                  children: [
                                    InkWell(
                                      child: Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 10, top: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5)),
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: subQues.contains(6)
                                              ? imageList.isEmpty
                                                  ? _body()
                                                  : imageList.isEmpty
                                                      ? _body()
                                                      : multipleImages()
                                              : _body() /*imageList.isEmpty
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

                                        if (widget.checkList
                                                .checklistEditStatus ==
                                            'E') {
                                          // getPhoto();
                                          // checkList_Answer_Option_Id_ = checkList_Answer_Option_Id[pos];
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),

                    //
                    Visibility(
                        visible: optionMandatoryFlag == "-1"
                            ? false
                            : subQues.contains(1)
                                ? true
                                : false,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.grey)),
                          child: Row(
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.4,
                                  height: 40,
                                  child: Center(
                                    child: TextField(
                                      controller: sealnoCntrl,
                                      // enabled:
                                      //     widget.checkList.checklistEditStatus ==
                                      //             'P'
                                      //         ? false
                                      //         : true,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        hintText: 'Comment',
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        )),

                    Visibility(
                        visible: optionMandatoryFlag == "-1"
                            ? false
                            : subQues.contains(5)
                                ? true
                                : false,
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            // border: Border.all(color: Colors.grey)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Store Rating',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              RatingBar.builder(
                                initialRating: 0,
                                minRating: 0.5,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                  setState(() {
                                    rating_ = rating;
                                  });
                                },
                              ),
                            ],
                          ),
                        )),
                    Visibility(
                        visible: false,
                        // visible: optionMandatoryFlag == "-1"
                        //     ? false
                        //     : subQues.contains(5)
                        //         ? true
                        //         : false,
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            // border: Border.all(color: Colors.grey)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Department Rating',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              RatingBar.builder(
                                initialRating: 0,
                                minRating: 0.5,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                  setState(() {
                                    rating2_ = rating;
                                  });
                                },
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(
                      height: 60,
                    )
                  ],
                ),
              ),
              Visibility(
                visible: false,
                // visible: showpopup,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.black26,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.white,
                      height: 200,
                      child: Column(
                        children: [
                          const Center(
                            child: Text(
                              'Select',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount:
                                  options.length, // subQues.contains(4) ? 4 :
                              itemBuilder: (context, pos) {
                                return InkWell(
                                  onTap: () {
                                    if (widget.checkList.checklistEditStatus ==
                                        'E') {}
                                    setState(() {
                                      showpopup = false;
                                      dropdownText =
                                          answerOptions[pos].answerOption;
                                      checkList_Answer_Option_Id_ =
                                          answerOptions[pos]
                                              .checkListAnswerOptionId;
                                      non_Compliance_Flag =
                                          answerOptions[pos].nonComplianceFlag;
                                      optionMandatoryFlag = answerOptions[pos]
                                          .optionMandatoryFlag;
                                    });
                                    print('000000non_Compliance_Flag');
                                    print(non_Compliance_Flag);
                                    print(checkList_Answer_Option_Id_);
                                  },
                                  child: Text(
                                    answerOptions[pos].answerOption,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // if (widget.checkList.checklistEditStatus == 'E') {
                          // submitCheckList();
                          /*  for (int i = 0; i < quesAnsList[0].questions.length; i++) {
                            if (subQues.contains(3) &&
                                quesAnsList[0].questions[i].mandatoryFlag == '1') {
                              print("mandatoryFlag==1");
                              setState(() {
                                mandy = 1;
                              });
                            } else {
                              print("mandatoryFlag==0");
                              setState(() {
                                mandy = 0;
                              });
                            }
                          }
                          print("mandatoryasdfeasfadsfFlag==$mandy");*/
                          // print();

                          // if (optionMandatoryFlag == "1" ||
                          //     optionMandatoryFlag == "0") {
                          //   if (base64img_.isEmpty) {
                          //     showSimpleDialog(title: "Alert!", msg: "Please take photo");
                          //
                          //   } else if (sealnoCntrl.text.toString().isEmpty) {
                          //     showSimpleDialog(title: "Alert!", msg: "Please enter comments");
                          //   } else if (rating_ == 0.0) {
                          //     showSimpleDialog(title: "Alert!", msg: "Please give Store rating");
                          //
                          //   } /*else if (rating2_ == 0.0) {
                          //     showSimpleDialog(title: "Alert!", msg: "Please give Department rating");
                          //
                          //   }*/ else {
                          //     print('$rating2_ ,$rating_');
                          //     _showProceedAlert();
                          //   }
                          // } else {
                          //   _showProceedAlert();
                          // }
                          // }
                          // _showProceedAlert();


                          // _showProceedAlert(0);
                          goToPrevious();
                        },
                        child: Container(
                          height: 50,
                          color: Colors.blue,
                          child: const Center(
                            child: Text(
                              'Previous',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // if (widget.checkList.checklistEditStatus == 'E') {
                          // submitCheckList();
                          /*  for (int i = 0; i < quesAnsList[0].questions.length; i++) {
                            if (subQues.contains(3) &&
                                quesAnsList[0].questions[i].mandatoryFlag == '1') {
                              print("mandatoryFlag==1");
                              setState(() {
                                mandy = 1;
                              });
                            } else {
                              print("mandatoryFlag==0");
                              setState(() {
                                mandy = 0;
                              });
                            }
                          }
                          print("mandatoryasdfeasfadsfFlag==$mandy");*/
                          // print();

                          // if (optionMandatoryFlag == "1" ||
                          //     optionMandatoryFlag == "0") {
                          //   if (base64img_.isEmpty) {
                          //     showSimpleDialog(title: "Alert!", msg: "Please take photo");
                          //
                          //   } else if (sealnoCntrl.text.toString().isEmpty) {
                          //     showSimpleDialog(title: "Alert!", msg: "Please enter comments");
                          //   } else if (rating_ == 0.0) {
                          //     showSimpleDialog(title: "Alert!", msg: "Please give Store rating");
                          //
                          //   } /*else if (rating2_ == 0.0) {
                          //     showSimpleDialog(title: "Alert!", msg: "Please give Department rating");
                          //
                          //   }*/ else {
                          //     print('$rating2_ ,$rating_');
                          //     _showProceedAlert();
                          //   }
                          // } else {
                          //   _showProceedAlert();
                          // }
                          // }
                          // _showProceedAlert();

                          if(checkList_Answer_Option_Id_!=-1){
                            _showProceedAlert(1);
                          }else{
                            Get.snackbar('Alert', "Please select an option",backgroundColor: Colors.red);
                          }
                        },
                        child: Container(
                          height: 50,
                          color: Colors.blue,
                          child: const Center(
                            child: Text(
                              'Next',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: loading,
                  child: Container(
                    color: const Color(0x80000000),
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
                            ))),
                  )),
              Visibility(
                  visible: Camcontroller == null ? false : camVisible,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    // aspectRatio: controller!.value.aspectRatio,
                    child: Stack(
                      children: [
                        SizedBox(
                            height: double.infinity,
                            // height: MediaQuery.of(context).size.height,
                            // width: MediaQuery.of(context).size.width,
                            width: double.infinity,
                            child: Camcontroller == null
                                ? const CircularProgressIndicator()
                                : CameraPreview(Camcontroller!)),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              onTap: () async {
                                // final image = await Camcontroller!.takePicture();
                                try {
                                  final image =
                                      await Camcontroller!.takePicture();
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
                            ))
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget multipleImages() {
    return SizedBox(
      width: 200,
      height: 100,
      child: ListView.builder(
          itemCount: imageList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, pos) {
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Image.file(File(imageList[pos])),
            );
          }),
    );
  }
  void goToPrevious() {
    if (currentPosition > 0) {
      setState(() {
        currentPosition--; // Move to previous position
      });
      getData(currentPosition); // Fetch previous data
    }
    else{
      Get.snackbar("End", "You are at the first question!",snackPosition: SnackPosition.BOTTOM,backgroundColor: Colors.red);

    }
  }
  void goToNext() {
    if (currentPosition < widget.headerQuestion.length - 1) {
      setState(() {
        currentPosition++; // Move to next position
      });
      getData(currentPosition); // Fetch next data
    }
    else {

      Navigator.pop(context);
      // Get.snackbar("End", "You are at the last question!",snackPosition: SnackPosition.BOTTOM,backgroundColor: Colors.red);

      // Get.snackbar("End", "You are at the last question!");
    }
  }
  CameraController? Camcontroller;
  String imagePath = "";
  bool camVisible = false;

  getPhoto() async {
    final ImagePicker _picker = ImagePicker();

    if (cameraOpen == 0) {
      setState(() {
        cameraOpen = 1;
      });

      if (Platform.isAndroid) {
        try {
          final cameras =
              await availableCameras(); //get list of available cameras
          final frontCam = cameras[0];

          Camcontroller = CameraController(frontCam, ResolutionPreset.medium);
          Camcontroller?.initialize().then((_) {
            if (!mounted) {
              return;
            }
            setState(() {
              camVisible = true;
            });
          });
        } on CameraException catch (e) {
          print('Error in fetching the cameras: $e');
        }
      } else {
        photo = await _picker?.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.rear);
        _cropImage(photo);
      }
      /* photo = await _picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);*/
/*
      if (Platform.isAndroid) {

      }*/
      // _cropImage(photo);
    }
  }

  int cameraOpen = 0;
  var base64img_ = '';

  Future<void> _cropImage(var photo) async {
    if (photo != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: Platform.isAndroid ? photo : photo!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 40,
        //1280 x 720//1920 x 1080
        maxWidth: 1920,
        maxHeight: 1080,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          /* IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),*/
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
          // imageList.add(path);
        });
        final path = _croppedFile!.path;
        print("imageList" + path);
        imageList.add(path);
        print("imageList${imageList.length}");

        croppedFile.readAsBytes().then((value) {
          final imageEncoded = base64.encode(value);

          setState(() {
            base64img_ = imageEncoded;
          });
        });
        print("img_pan : $base64img_");

        /* final bytes = File(croppedFile.path).readAsBytesSync();
        String base64Image = base64Encode(bytes);
        setState(() {
          base64img_ = base64Image;
        });*/

        // print("img_pan : $base64Image");
      }
    }
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

  Widget _imageCard() {
    return Center(
      child: SizedBox(height: 100, width: 110, child: _image()),
    );
  }

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

  List<Answeroption> answerOptions = [];
  List<Answeroption> answerOptionsAttachProof_3 = [];
  List<Answeroption> answerOptionsComment_1 = [];

  Future<void> getData(int position) async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userCode') ?? '0';

      //remove in prodcution
      String url =
          "${Constants.apiHttpsUrlTest}/AreaManager/QuestionAnswers/${widget.checkList.am_checklist_assign_id}/${widget.headerQuestion[position].checklisTItemMstId}/InProcess/$userId"; //

      print(url);
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(milliseconds: 5000));
      print(response.body);

      var responseData = json.decode(response.body);
      final decodedJson = jsonDecode(response.body); // dynamic

      final data = decodedJson[0];
      print(response.body);

      List<dynamic> list = json.decode(response.body);

      quesAnsList = [];
      Iterable l = json.decode(response.body);
      quesAnsList = List<QuestionAnswers>.from(
          l.map((model) => QuestionAnswers.fromJson(model)));
      print("quesAnsList.length");
      print(quesAnsList.length);

      // setOptionData();

      QuestionAnswers questionAnswers = QuestionAnswers.fromJson(list[0]);
      print("QUESLENGTHT${questionAnswers.questions.length}");
      setState(() {
        item_name = questionAnswers.itemName;
        quesLength = questionAnswers.questions.length;
        checklist_id = questionAnswers.checklistId.toString();
      });

      // Map<String, dynamic> map = list as Map<String, dynamic>;
      // print(map['item_name']);
      // item_name =  map['item_name'];

      final questions = decodedJson[0]['questions'];

      List<dynamic> questionslist = questions;
      print('SubQues length${questionslist.length}');

      subQues.clear();
      questionTitles.clear();
      options.clear();
      options = [];

      checkList_Answer_Option_Id.clear();
      checkList_Answer_Option_Id_ = -1;
      for (var loop in questionslist) {
        var getCName = loop['answer_Type_Id'];
        print(getCName);
        setState(() {
          checkList_Answer_Id = loop['checkList_Answer_Id'];
          subQues.add(loop['answer_Type_Id']);
          questionTitles.add(loop['question']);
        });
        // options.clear();
        // List<Answeroption> parseAnswerOptions(List<dynamic> jsonList) {
        //   return jsonList.map((json) => Answeroption.fromJson(json)).toList();
        // }
        //
        // answerOptions.clear();
        // answerOptions = parseAnswerOptions(loop['options']);
        //
        // for (var inLoop in loop['options']) {
        //   // if (loop['answer_Type_Id'] == 4) {
        //     options.add(inLoop['answer_Option']);
        //   // }
        //   // options.add(inLoop['answer_Option']);
        //   nonCompFlag.add(inLoop['non_Compliance_Flag']);
        //   checkList_Answer_Option_Id.add(inLoop['checkList_Answer_Option_Id']);
        //   optionMandatoryFlags.add(inLoop['option_mandatory_Flag']);
        // }

        if (loop['answer_Type_Id'] == 8) {
          List<Answeroption> parseAnswerOptions(List<dynamic> jsonList) {
            return jsonList.map((json) => Answeroption.fromJson(json)).toList();
          }

          answerOptions.clear();
          answerOptions = parseAnswerOptions(loop['options']);
        }
        // if (loop['answer_Type_Id'] == 3) {
        //   List<Answeroption> parseAnswerOptions(List<dynamic> jsonList) {
        //     return jsonList.map((json) => Answeroption.fromJson(json)).toList();
        //   }
        //
        //   answerOptionsAttachProof_3.clear();
        //   answerOptionsAttachProof_3 = parseAnswerOptions(loop['options']);
        // }
        // if (loop['answer_Type_Id'] == 1) {
        //   List<Answeroption> parseAnswerOptions(List<dynamic> jsonList) {
        //     return jsonList.map((json) => Answeroption.fromJson(json)).toList();
        //   }
        //
        //   answerOptionsComment_1.clear();
        //   answerOptionsComment_1 = parseAnswerOptions(loop['options']);
        // }
        //
        for (var inLoop in loop['options']) {
          if (loop['answer_Type_Id'] == 8) {
            options.add(inLoop['answer_Option']);
          }
          // options.add(inLoop['answer_Option']);
          nonCompFlag.add(inLoop['non_Compliance_Flag']);
          checkList_Answer_Option_Id.add(inLoop['checkList_Answer_Option_Id']);
          optionMandatoryFlags.add(inLoop['option_mandatory_Flag']);
        }
      }

      print("subQues$subQues");
      print("questionTitles$questionTitles");
      print("questionoptions$options");

      print(
          'questionsData: $questions'); /*
      List<QuestionAnswers> users = [];
      return users;*/
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showAlert("Something went wrong\nPlease contact it support\n$e");

    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _showRetryAlert__(int i,String error) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content:  Text('Something went wrong\n$error'),
// Please retry?'),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();

                    // submitCheckList();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text('Ok', style: TextStyle(color: Colors.white)),
                  )),
            ),
          ],
        );
      },
    );
  }

  setOptionData() {
    for (int i = 0; i < quesAnsList[0].questions.length; i++) {
      if (quesAnsList[0].questions[i].answerTypeId == 4) {
        options.add(quesAnsList[0].questions[i].options);
        // options.add(inLoop['answer_Option']);
      }
    }
  }

  Future<void> _showProceedAlert(int history) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to proceed?'),
          // content: Text('$msg'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 35, right: 35, top: 15, bottom: 15),
                    margin: const EdgeInsets.only(left: 15, bottom: 10),
                    decoration: const BoxDecoration(
                        color: CupertinoColors.systemGrey3,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: const Text('No',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();

                    submitCheckList(history);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 35, right: 35, top: 15, bottom: 15),
                    margin: const EdgeInsets.only(right: 15, bottom: 10),
                    decoration: const BoxDecoration(
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessAlert(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(msg),
          actions: <Widget>[
            InkWell(
              onTap: () {
                // Navigator.of(context,rootNavigator: true).pop();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => checkListItemScreen_AM(
                          widget.activeCheckList, widget.mLpdChecklist),
                    ));

                Navigator.pop(contextt);
                Navigator.pop(context);

                // submitCheckList();
                // Get.off(() => checkListItemScreen(widget.activeCheckList));
                // Navigator.pushReplacement(context, newRoute)
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 35, right: 35, top: 15, bottom: 15),
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: const Text('OK',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAlert(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextt) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Close the dialog
                // Get.back();
                Navigator.of(contextt).pop();
                Navigator.of(context).pop();
                // Execute the callback function
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        16), // Adjust the radius for rounded corners
                  )),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

//QuestionCancel

  Future<bool> questionCancel() async {
    // bool goBack ;
    try {
      setState(() {
        loading = true;
      });
      var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        '/RWASTAFFMOVEMENT_TEST/api/AreaManager/QuestionCancel',
      );
      var sendJson = {
        "checklist_assign_id": widget.checkList.am_checklist_assign_id,
        "checklist_mst_item_id": widget.checkList.checklisTItemMstId,
      };
      print(sendJson);

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "checklist_assign_id": widget.checkList.am_checklist_assign_id,
              "checklist_mst_item_id": widget.checkList.checklisTItemMstId,
            }),
          )
          .timeout(const Duration(seconds: 3));

      var respo = jsonDecode(response.body);

      print(respo);
      if (respo['statusCode'] == '200') {
        print(respo['message']);
        setState(() {
          loading = false;
          goBack = true;
        });

        // Navigator.pop(context);
      } else {
        setState(() {
          loading = false;
          goBack = false;
        });

        // _showMyDialog("Something went wrong\nPlease contact it support ");
        showSimpleDialog(
            title: 'Alert!',
            msg: 'Something went wrong\nPlease contact it support');
      }
    } catch (w) {
      setState(() {
        loading = false;
        goBack = false;
      });
      showSimpleDialog(
          title: 'Alert!',
          msg: 'Something went wrong\nPlease contact it support\n$w');
    }
    return goBack;
  }

  submitCheckList(int history) async {
    try {
      setState(() {
        loading = true;
      });
      String datetime_ =
          DateFormat("yyyy-MM-dd'T'hh:mm:ss.S'Z'").format(DateTime.now());
      String datetime = DateFormat("yyyy-MM-dd hh:mm:ss")
          .format(DateTime.now()); //2023-02-25 10:30:10

      final prefs = await SharedPreferences.getInstance();

      var url = Uri.https(
        'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
        '/RWASTAFFMOVEMENT_TEST/api/AreaManager/AddQuestionAnswer',
      );

      var locationCode = prefs.getString('locationCode');
      var userCode = int.tryParse(prefs.getString('userCode') ?? "");
      String dateForEmpCode_ =
          DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
      var userId = prefs.getString("userCode");
      String empCode = "EMP$userId$dateForEmpCode_";

      var sendJson = [];

      var length;
      if (subQues.contains(3)) {
        length = quesAnsList[0].questions.length - 1;
      }

      for (int i = 0; i < quesAnsList[0].questions.length; i++) {
        /* for(int j=0;j<quesAnsList[i].questions.length;j++){

      }*/
        if (quesAnsList[0].questions[i].answerTypeId == 8) {
          sendJson.add({
            "checkList_Item_Mst_Id":
                widget.headerQuestion[widget.position].checklisTItemMstId,
            "checklist_Id": widget.headerQuestion[widget.position].checklistId,
            "item_name": quesAnsList[0].itemName,
            "checkList_Answer_Id":
                quesAnsList[0].questions[i].checkListAnswerId,
            "question": questionTitles[i],
            "answer_Type_Id": subQues[0],
            "mandatory_Flag":
                widget.headerQuestion[widget.position].mandatoryFlag,
            "active_Flag": widget.headerQuestion[widget.position].activeFlag,
            "checkList_Answer_Option_Id": checkList_Answer_Option_Id_,
            "answer_Option": dropdownText,
            "we_Care_Flag": widget.activeCheckList.weCareFlag,
            "non_Compliance_Flag": non_Compliance_Flag,
            "pos_bos_flag": widget.activeCheckList.posBosFlag,
            "order_flag": int.parse(quesAnsList[0].questions[i].orderFlag),
            "am_checklist_assign_id":
                widget.activeCheckList.amChecklistAssignId,
            "created_by": userCode,
            "created_datetime": datetime,
            "updated_by": userCode,
            "updated_by_datetime": datetime,
            "checklist_applicable_type":
                widget.activeCheckList.checklistApplicableType,
            "checklist_progress_status": "",
            "questionstatus": "Completed",
            "imagename": "",
          });
        } else if (quesAnsList[0].questions[i].answerTypeId == 1) {
          sendJson.add({
            "checkList_Item_Mst_Id": widget.checkList.checklisTItemMstId,
            "checklist_Id": widget.checkList.checklistId,
            "item_name": quesAnsList[0].itemName,
            "checkList_Answer_Id":
                quesAnsList[0].questions[i].checkListAnswerId,
            "question": questionTitles[i],
            "answer_Type_Id": quesAnsList[0].questions[i].answerTypeId,
            "mandatory_Flag": widget.checkList.mandatoryFlag,
            "active_Flag": widget.checkList.activeFlag,
            "checkList_Answer_Option_Id":
                answerOptionsComment_1[0].checkListAnswerOptionId,
            "answer_Option": sealnoCntrl.text.toString(),
            "we_Care_Flag": answerOptionsComment_1[0].weCareFlag,
            "non_Compliance_Flag": answerOptionsComment_1[0].nonComplianceFlag,
            "pos_bos_flag": widget.activeCheckList.posBosFlag,
            "order_flag": int.parse(quesAnsList[0].questions[i].orderFlag),
            "am_checklist_assign_id":
                widget.activeCheckList.amChecklistAssignId,
            "created_by": userCode,
            // "empcode": usercode,
            "created_datetime": datetime,
            "updated_by": userCode,
            "updated_by_datetime": datetime,
            "checklist_applicable_type":
                widget.activeCheckList.checklistApplicableType,
            "checklist_progress_status": "",
            "questionstatus": "Completed",
            "imagename": "",
          });
        } else if (quesAnsList[0].questions[i].answerTypeId == 3) {
          sendJson.add({
            "checkList_Item_Mst_Id": widget.checkList.checklisTItemMstId,
            "checklist_Id": widget.checkList.checklistId,
            "item_name": questionTitles[i],
            "checkList_Answer_Id":
                quesAnsList[0].questions[i].checkListAnswerId,
            "question": questionTitles[i],
            "answer_Type_Id": quesAnsList[0].questions[i].answerTypeId,
            "mandatory_Flag": widget.checkList.mandatoryFlag,
            "active_Flag": widget.checkList.activeFlag,
            "checkList_Answer_Option_Id":
                answerOptionsAttachProof_3[0].checkListAnswerOptionId,
            "answer_Option": '',
            "we_Care_Flag": answerOptionsAttachProof_3[0].weCareFlag,
            "non_Compliance_Flag":
                answerOptionsAttachProof_3[0].nonComplianceFlag,
            "pos_bos_flag": widget.activeCheckList.posBosFlag,
            "order_flag": int.parse(quesAnsList[0].questions[i].orderFlag),
            "am_checklist_assign_id":
                widget.activeCheckList.amChecklistAssignId,
            "created_by": userCode,
            // "empcode": usercode,
            "created_datetime": datetime,
            "updated_by": userCode,
            "updated_by_datetime": datetime,
            "checklist_applicable_type":
                widget.activeCheckList.checklistApplicableType,
            "checklist_progress_status": "",
            "questionstatus": "Completed",
            "imagename": "$empCode.jpg",
          });
        } else if (quesAnsList[0].questions[i].answerTypeId == 5) {
          sendJson.add({
            "checkList_Item_Mst_Id": widget.checkList.checklisTItemMstId,
            "checklist_Id": widget.checkList.checklistId,
            "item_name": questionTitles[i],
            "checkList_Answer_Id":
                quesAnsList[0].questions[i].checkListAnswerId,
            "question": questionTitles[i],
            "answer_Type_Id": quesAnsList[0].questions[i].answerTypeId,
            "mandatory_Flag": widget.checkList.mandatoryFlag,
            "active_Flag": widget.checkList.activeFlag,
            "checkList_Answer_Option_Id":
                quesAnsList[0].questions[i].options[0].checkListAnswerOptionId,
            "answer_Option": rating_.toString(),
            "we_Care_Flag": widget.activeCheckList.weCareFlag,
            "non_Compliance_Flag": 0,
            "pos_bos_flag": widget.activeCheckList.posBosFlag,
            "order_flag": int.parse(quesAnsList[0].questions[i].orderFlag),
            "am_checklist_assign_id":
                widget.activeCheckList.amChecklistAssignId,
            "created_by": userCode,
            // "empcode": usercode,
            "created_datetime": datetime,
            "updated_by": userCode,
            "updated_by_datetime": datetime,
            "checklist_applicable_type":
                widget.activeCheckList.checklistApplicableType,
            "checklist_progress_status": "",
            "questionstatus": "Completed",
            "imagename": "",
          });
        }
      }

      print('AddanswerParams=>$sendJson');

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(sendJson),
          )
          .timeout(const Duration(seconds: 5));
      print(response.body);
      print(response.request);
      print(response.statusCode);
      var respo = jsonDecode(response.body);

      print(respo['statusCode']);
      if (respo['statusCode'] == '200') {
        setState(() {
          loading = false;
        });
        if (optionMandatoryFlag == "1" && subQues.contains(3)) {
          print('subQues.contains(3)');
          print(subQues.contains(3));
          if (base64img_.isNotEmpty) {
            print('imageList.length == 1');

            // uploadImage(0, usercode);
            cloudstorageRef(base64img_, empCode);
          } else if (mandy == 1) {
            if (imageList.length == 1) {
              // uploadImage(0, usercode);
              cloudstorageRef(base64img_, empCode);
            } else {
              showSimpleDialog(title: 'Alert!', msg: "Please Upload photo");
            }
          }
        } else {
          setState(() {
            dropdownText="";
          });
          if(history==0){
            goToPrevious();
          }else{
            goToNext();
          }
          showSnackbar(respo['message']);
          // _showSuccessAlert(respo['message'].toString());
        }
      } else {
        setState(() {
          loading = false;
        });

        _showMyDialog("Something went wrong\nPlease contact it support\n${response.body}");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showRetryAlert__(2,"$e");
    }
  }

  Future<void> cloudstorageRef(var img, var empcode) async {
    setState(() {
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String dateForEmpCode_ =
        DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
    var userId = prefs.getString("userCode");
    // String empCode = "EMP$userId$dateForEmpCode_";
    String empCode = empcode;

    // final storageRef = FirebaseStorage.instance.ref();
    // FirebaseStorage storageRefd = FirebaseStorage.instanceFor(bucket: "gs://hgstores_rwa_dilo");
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://hng-offline-marketing.appspot.com")
        .ref();

    var locationCode = widget.activeCheckList.locationCode;
    // var locationCode = prefs.getString('locationCode') ?? '106';

    final imagesRef = storageRef.child("$locationCode/QuesAns/$empCode.jpg");

    // String dataUrl = base64img;
// Create a reference to "mountains.jpg"
    final mountainsRef = imagesRef.child("$empCode.jpg");

// Create a reference to 'images/mountains.jpg'
    try {
      // await imagesRef.putString(img, format: PutStringFormat.dataUrl);
      await imagesRef
          .putString(img,
              format: PutStringFormat.base64,
              metadata: SettableMetadata(contentType: 'image/png'))
          .then((p0) {
        print('uploaded to firebase storage successfully${p0}');
      });
      setState(() {
        loading = false;
      });
      _showSuccessAlert("CheckList Item submitted successfully");

      // String downloadUrl = (await FirebaseStorage.instanceFor(bucket: "gs://hng-offline-marketing.appspot.com").ref().getDownloadURL()).toString();
      String downloadUrl = (await FirebaseStorage.instanceFor(
                  bucket: "gs://hng-offline-marketing.appspot.com")
              .ref())
          .toString();

      print(downloadUrl);
      /*  setState(() {
        loading = false;
      });*/
    } on FirebaseException catch (e) {
      print('FirebaseException');
      print(e.message);
      // _showAlert(e.message);
      // ...
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _showMyDialog(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text(msg),
          actions: <Widget>[
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              child: TextButton(
                child:
                    const Text('Got it', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void showSnackbar(String respo) {
    Get.snackbar(
      "Success",
      respo,
      colorText: Colors.white,
      backgroundColor: Colors.lightBlue,
      icon: const Icon(Icons.add_alert),
    );
  }
}
