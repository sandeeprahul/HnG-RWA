import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hng_flutter/AmAcceptSelectionScreen.dart';
import 'package:hng_flutter/checkListItem_virtualMerch_page.dart';
import 'package:hng_flutter/data/Answeroption.dart';
import 'package:hng_flutter/data/HeaderQuestion.dart';
import 'package:hng_flutter/PageHome.dart';
import 'package:hng_flutter/checkListItemScreen.dart';
import 'package:hng_flutter/data/activeCheckList_virtualMerch_entity.dart';
import 'package:hng_flutter/main.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/constants.dart';
import 'data/ActiveCheckListModel.dart';
import 'data/GetActvityTypes.dart';
import 'data/HeaderQuestion_VirtualMerch_Entity.dart';
import 'data/QuestionAnswers.dart';

class submitCheckListVirtualMerchPage extends StatefulWidget {
  final HeaderQuestionVirtualMerchEntity checkList;
  final ActiveCheckListVirtualMerchEntity activeCheckList;
  final int i;

  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  submitCheckListVirtualMerchPage(this.checkList, this.activeCheckList, this.i,
      this.mGetActvityTypes, this.locationsList);

  // submitCheckListScreen({Key? key}) : super(key: key);

  @override
  State<submitCheckListVirtualMerchPage> createState() => _submitCheckListVirtualMerchPageState(
      this.checkList,
      this.activeCheckList,
      this.mGetActvityTypes,
      this.locationsList);
}

List<QuestionAnswers>? list;
List<Question>? listQues;
String item_name = "Loading....";
String checklist_id = "Loading....";
String dropdownText = "";
int quesLength = 0;
var subQues = [];
var questionTitles = [];
List<QuestionAnswers> quesAnsList = [];

var options = [];
var nonCompFlag = [];
var option_mandatory_Flags = [];
var checkList_Answer_Option_Id = [];
var checkList_Answer_Option_Id_;
var non_Compliance_Flag;
var option_mandatory_Flag;

var checkList_Answer_Id;

var showpopup = false;
XFile? photo;
bool loading = false;
var _croppedFile;
var imageList = [];

class _submitCheckListVirtualMerchPageState extends State<submitCheckListVirtualMerchPage> {
  HeaderQuestionVirtualMerchEntity checkList;
  ActiveCheckListVirtualMerchEntity activeCheckList;
  final GetActvityTypes mGetActvityTypes;
  final String locationsList;

  _submitCheckListVirtualMerchPageState(this.checkList, this.activeCheckList,
      this.mGetActvityTypes, this.locationsList);

  var mandy;
  TextEditingController sealnoCntrl = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    dropdownText = "";
    _croppedFile = null;
    // imageList.clear();
    // options.clear();

    item_name = "Loading....";
    checklist_id = "Loading....";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imageList.clear();
    dropdownText = '';
    showpopup = false;
    _croppedFile = null;

    option_mandatory_Flag = "0";
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                'DILO',
                                style: TextStyle(color: Colors.black),
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
                          visible: subQues.contains(4) ? true : false,
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

                      //attach proof
                      Visibility(
                          visible: option_mandatory_Flag == "-1"
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 10, top: 10),
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
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
                          visible: option_mandatory_Flag == "-1"
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
                                          hintText:
                                              'Enter your response here',
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
              Visibility(
                visible: showpopup,
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
                              itemCount: answerOptions
                                  .length, // subQues.contains(4) ? 4 :
                              itemBuilder: (context, pos) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      showpopup = false;
                                      // mandatory = quesAnsList[0].questions[0].options[]
                                    });
                                    setAnswerOptionData(answerOptions[pos]);
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
                child: InkWell(
                  onTap: () {
                    if (loading != true) {
                      if (option_mandatory_Flag == "1") {
                        if (subQues.contains(3) && base64img_.isEmpty) {
                          _showAlertWithMSG('Please take photo');
                        } else if (subQues.contains(1) &&
                            sealnoCntrl.text.toString().isEmpty) {
                          _showAlertWithMSG('Please fill all details');
                        } else {
                          _showProceedAlert();
                        }
                      } else {
                        _showProceedAlert();
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    color: Colors.blue,
                    child: const Center(
                      child: Text(
                        'SUBMIT',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
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
                  ))
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
        photo = await _picker.pickImage(
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
    ///no

    if (photo != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: Platform.isAndroid ? photo : photo!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality :40,//1280 x 720//1920 x 1080
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

  Future<void> getData() async {
    try {
      setState(() {
        loading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userCode') ?? '0';

      //remove in prodcution
      //VirtualMerchandiser/QuestionAnswers/{vm_checklist_assign_id}/{checklist_Item_Mst_Id}/{Questionstaus}/{updatedby}
      //QuestionAnswers/{vm_checklist_assign_id}/{checklist_Item_Mst_Id}/{Questionstaus}/{updatedby}
      String url =
          "${Constants.apiHttpsUrl}/VirtualMerchandiser/QuestionAnswers/${widget.checkList.vm_assign_id}/${widget.checkList.checklistItemMstId}/InProcess/$userId"; //

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      // var responseData = json.decode(response.body);
      final decodedJson = jsonDecode(response.body); // dynamic

      // final data = decodedJson[0];

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
      checkList_Answer_Option_Id_ = "";
      for (var loop in questionslist) {
        var getCName = loop['answer_Type_Id'];
        print(getCName);
        setState(() {
          checkList_Answer_Id = loop['checkList_Answer_Id'];
          subQues.add(loop['answer_Type_Id']);
          questionTitles.add(loop['question']);
        });
        // options.clear();
        /*for(var options in loop['options']){
          List<Answeroption> temp =

        }*/

        if (loop['answer_Type_Id'] == 4) {
          List<Answeroption> parseAnswerOptions(List<dynamic> jsonList) {
            return jsonList.map((json) => Answeroption.fromJson(json)).toList();
          }

          answerOptions.clear();
          answerOptions = parseAnswerOptions(loop['options']);
        }
        if (loop['answer_Type_Id'] == 3) {
          List<Answeroption> parseAnswerOptions(List<dynamic> jsonList) {
            return jsonList.map((json) => Answeroption.fromJson(json)).toList();
          }

          answerOptionsAttachProof_3.clear();
          answerOptionsAttachProof_3 = parseAnswerOptions(loop['options']);
        }
        if (loop['answer_Type_Id'] == 1) {
          List<Answeroption> parseAnswerOptions(List<dynamic> jsonList) {
            return jsonList.map((json) => Answeroption.fromJson(json)).toList();
          }

          answerOptionsComment_1.clear();
          answerOptionsComment_1 = parseAnswerOptions(loop['options']);
        }

        for (var inLoop in loop['options']) {
          if (loop['answer_Type_Id'] == 4) {
            options.add(inLoop['answer_Option']);
          }
          // options.add(inLoop['answer_Option']);
          nonCompFlag.add(inLoop['non_Compliance_Flag']);
          checkList_Answer_Option_Id.add(inLoop['checkList_Answer_Option_Id']);
          option_mandatory_Flags.add(inLoop['option_mandatory_Flag']);
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
      print(e);
      setState(() {
        loading = false;
      });
      _showRetryAlert__(0);
    }
  }

  List<Answeroption> answerOptions = [];
  List<Answeroption> answerOptionsAttachProof_3 = [];
  List<Answeroption> answerOptionsComment_1 = [];

  Future<void> _showRetryAlert__(int i) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: const Text('Network issue\nPlease retry'),
// Please retry?'),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white))),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (i == 0) {
                      getData();
                    } else {
                      questionCancel();
                    }
                    // submitCheckList();
                  },
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white))),
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

  Future<void> _showProceedAlert() async {
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
                    submitCheckList();
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
          content: Text('$msg'),
          actions: <Widget>[
            InkWell(
              onTap: () {
                // Navigator.of(context,rootNavigator: true).pop();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => widget.i == 0
                          ? checkListItemVirtualMerchPage(widget.activeCheckList,
                              widget.mGetActvityTypes, widget.locationsList)
                          ://for timebeeing , after remove this
                      checkListItemVirtualMerchPage(widget.activeCheckList,
                          widget.mGetActvityTypes, widget.locationsList)
                      // AmAcceptSelectionScreen(
                      //         widget.activeCheckList.checklistAssignId,
                      //         activeCheckList,
                      //         widget.mGetActvityTypes,
                      //         widget.locationsList)
                      ,
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

  Future<void> _showAlert(var msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text('$msg'),
          actions: <Widget>[
            Container(
              // margin: EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text(
                    'Got it',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAlertWithMSG(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Text('$msg'),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text('Got it',
                      style: TextStyle(color: Colors.white))),
            ),
          ],
        );
      },
    );
  }

  int tried = 0;



  Future<bool> questionCancel() async {
    // bool goBack ;
    try {
      setState(() {
        loading = true;
      });
       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/CheckList/QuestionCancel',
      );
      var sendJson = {
        "vm_assign_id": widget.checkList.vm_assign_id,
        "checklist_mst_item_id": widget.checkList.checklistItemMstId,
      };
      print(sendJson);

      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "vm_assign_id": widget.checkList.vm_assign_id,
              "checklist_mst_item_id": widget.checkList.checklistItemMstId,
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

        _showMyDialog("Something went wrong\nPlease contact it support ");
      }
    } catch (w) {
      print(w);
      setState(() {
        loading = false;
        goBack = false;
      });
      _showRetryAlert__(1);
      // return false;
    }
    print('goBack');
    print(goBack);
    return goBack;
  }

  submitCheckList() async {
    try {
      setState(() {
        loading = true;
      });
      String datetime_ =
          DateFormat("yyyy-MM-dd'T'hh:mm:ss.S'Z'").format(DateTime.now());
      String datetime = DateFormat("yyyy-MM-dd hh:mm:ss")
          .format(DateTime.now()); //2023-02-25 10:30:10

      final prefs = await SharedPreferences.getInstance();

      var url =
         ' ${Constants.apiHttpsUrl}/CheckList/AddQuestionAnswer';

      var locationCode = prefs.getString('locationCode');
      var usercode = int.tryParse(prefs.getString('userCode') ?? "");

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
        if (quesAnsList[0].questions[i].answerTypeId == 4) {
          sendJson.add({
            "checkList_Item_Mst_Id": widget.checkList.checklistItemMstId,
            "checklist_Id": widget.checkList.checklistId,
            "item_name": quesAnsList[0].itemName,
            "checkList_Answer_Id":
                quesAnsList[0].questions[i].checkListAnswerId,
            "question": questionTitles[i],
            "answer_Type_Id": subQues[0],
            "mandatory_Flag": widget.checkList.mandatoryFlag,
            "active_Flag": widget.checkList.activeFlag,
            "checkList_Answer_Option_Id": checkList_Answer_Option_Id_,
            "answer_Option": dropdownText,
            "we_Care_Flag": widget.activeCheckList.weCareFlag,
            "non_Compliance_Flag": non_Compliance_Flag,
            // "non_Compliance_Flag": non_Compliance_Flag,
            "pos_bos_flag": widget.activeCheckList.posBosFlag,
            "order_flag": int.parse(quesAnsList[0].questions[i].orderFlag),
            "vm_checklist_assign_id": widget.activeCheckList.vm_assign_id,
            "created_by": usercode,
            "empcode": usercode,
            "created_datetime": "$datetime",
            "updated_by": usercode,
            "updated_by_datetime": "$datetime",
            "checklist_applicable_type":
                widget.activeCheckList.checklistApplicableType,
            "checklist_progress_status": "",
            "questionstatus": "Completed",
            "imagename": "",
            "branD_CODE": widget.checkList.branD_CODE,
            "branD_NAME": widget.checkList.branD_NAME,
            "elemenT_ID": widget.checkList.elemenT_ID,
            "elemenT_NAME": widget.checkList.elemenT_NAME,
            "demO_URL": widget.checkList.demO_URL,

          });
        } else if (quesAnsList[0].questions[i].answerTypeId == 1) {
          sendJson.add({
            "checkList_Item_Mst_Id": widget.checkList.checklistItemMstId,
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
            "we_Care_Flag": widget.activeCheckList.weCareFlag,
            "non_Compliance_Flag": answerOptionsComment_1[0].nonComplianceFlag,
            "pos_bos_flag": widget.activeCheckList.posBosFlag,
            "order_flag": int.parse(quesAnsList[0].questions[i].orderFlag),
            "checklist_assign_id": widget.activeCheckList.vm_assign_id,
            "created_by": usercode,
            "empcode": usercode,
            "created_datetime": "$datetime",
            "updated_by": usercode,
            "updated_by_datetime": "$datetime",
            "checklist_applicable_type":
                widget.activeCheckList.checklistApplicableType,
            "checklist_progress_status": "",
            "questionstatus": "Completed",
            "imagename": "",
            "branD_CODE": widget.checkList.branD_CODE,
            "branD_NAME": widget.checkList.branD_NAME,
            "elemenT_ID": widget.checkList.elemenT_ID,
            "elemenT_NAME": widget.checkList.elemenT_NAME,
            "demO_URL": widget.checkList.demO_URL,
          });
        } else if (quesAnsList[0].questions[i].answerTypeId == 3) {
          sendJson.add({
            "checkList_Item_Mst_Id": widget.checkList.checklistItemMstId,
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
            "vm_checklist_assign_id": widget.activeCheckList.vm_assign_id,
            "created_by": usercode,
            "empcode": usercode,
            "created_datetime": "$datetime",
            "updated_by": usercode,
            "updated_by_datetime": "$datetime",
            "checklist_applicable_type":
                widget.activeCheckList.checklistApplicableType,
            "checklist_progress_status": "",
            "questionstatus": "Completed",
            "imagename": "$empCode.jpg",
            "branD_CODE": widget.checkList.branD_CODE,
            "branD_NAME": widget.checkList.branD_NAME,
            "elemenT_ID": widget.checkList.elemenT_ID,
            "elemenT_NAME": widget.checkList.elemenT_NAME,
            "demO_URL": widget.checkList.demO_URL,
          });
        }
      }

      print('AddanswerParams=>$sendJson');
      print('imagename=>');
      print('$empCode.jpg');

      var response = await http
          .post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(sendJson),
          )
          .timeout(const Duration(seconds: 10));
      print(response.body);
      print(response.request);
      print(response.statusCode);
      var respo = jsonDecode(response.body);

      print(respo['statusCode']);
      if (respo['statusCode'] == '200') {
        if (option_mandatory_Flag == "1" && subQues.contains(3)) {
          print(subQues.contains(3));
          if (base64img_.isNotEmpty) {
            setState(() {
              loading = false;
            });
            cloudstorageRef(base64img_, empCode);
          } else if (mandy == 1) {
            if (imageList.length == 1) {
              cloudstorageRef(base64img_, empCode);
            } else {
              _showAlertWithMSG("Please Upload photo");
            }
          }
        } else {
          _showSuccessAlert(respo['message'].toString());
        }
      }
      else {
        setState(() {
          loading = false;
        });

        _showMyDialog("Error: ${respo['statusCode']}");
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showMyDialog("Network issue!\nPlease retry");
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

      _showSuccessAlert("CheckList Item submitted successfully");

      // String downloadUrl = (await FirebaseStorage.instanceFor(bucket: "gs://hng-offline-marketing.appspot.com").ref().getDownloadURL()).toString();
      String downloadUrl = (await FirebaseStorage.instanceFor(
                  bucket: "gs://hng-offline-marketing.appspot.com")
              .ref())
          .toString();

      print(downloadUrl);
      setState(() {
        loading = false;
      });
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

  //base64img_
  Future<void> uploadImage(int imgs, var userCode) async {
    try {
      // cloudstorageRef(base64img_);
      print('uploadImage');
      setState(() {
        loading = true;
      });
      String datetime_ = DateFormat("yyyyMMddhhmmssS").format(DateTime.now());
      print('DATATIME $datetime_');

      final prefs = await SharedPreferences.getInstance();

      // String url = staticUrlString + "Login/validateLogin";
       var url = Uri.https(
      'RWAWEB.HEALTHANDGLOWONLINE.CO.IN',
      '/RWA_GROOMING_API/api/CheckList/ImageUpload',
      );

      var image = [];
      for (int i = 0; i < imageList.length; i++) {
        image.add({
          'id': i,
          'imageFarmat': "jpg",
          'fileName': "EMP$userCode$datetime_",
          'imageBase64': "",
          // 'imageBase64': base64Imgg.toString().replaceAll('+', ''),
        });
      }

      var questionId = '', checklisT_ANSWER_OPTION_ID = '';
      for (int i = 0; i < quesAnsList[0].questions.length; i++) {
        if (quesAnsList[0].questions[i].answerTypeId == 3) {
          questionId = quesAnsList[0].questions[i].checkListAnswerId;
          checklisT_ANSWER_OPTION_ID = quesAnsList[0]
              .questions[i]
              .options[0]
              .checkListAnswerOptionId
              .toString();
        }
      }
      print('questionId');
      print(questionId);
      print(checklisT_ANSWER_OPTION_ID);
      // ?
      var response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "checkList_Item_Mst_Id": widget.checkList.checklistItemMstId,
              "checklist_Id": checklist_id,
              "CHECKLIST_ANSWER_OPTION_ID": checklisT_ANSWER_OPTION_ID,
              "question": questionTitles[0],
              "question_Id": questionId,
              "answer_Type_Id": 3,
              "checklist_assign_id": widget.activeCheckList.vm_assign_id,
              "getImages": image,
            }),
          )
          .timeout(const Duration(seconds: 10));

      var json = jsonEncode({
        "checkList_Item_Mst_Id": widget.checkList.checklistItemMstId,
        "checklist_Id": checklist_id,
        "CHECKLIST_ANSWER_OPTION_ID": checklisT_ANSWER_OPTION_ID,
        "question": questionTitles[0],
        "question_Id": questionId,
        "answer_Type_Id": "3",
        "checklist_assign_id": widget.activeCheckList.vm_assign_id,
        "getImages": image,
      });
      print(response.statusCode);
      print(response.request);
      print(json);
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        // Get.off(checkListItemScreen());

        _showSuccessAlert("CheckList Item submitted successfully");
      } else {
        setState(() {
          loading = false;
        });
        // _showProceedAlert();
        _showAlert('Something went wrong\nStatusCode:${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showRetryAlert(imgs, userCode);
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
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
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

  Future<void> _showRetryAlert(int imgs, var userCode) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: const Text(Constants.networkIssue),
// Please retry?'),
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(15),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    // submitCheckList();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white))),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration:
                  const BoxDecoration(color: CupertinoColors.activeBlue),
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    uploadImage(imgs, userCode);
                    // submitCheckList();
                  },
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white))),
            ),
          ],
        );
      },
    );
  }

  void setAnswerOptionData(Answeroption answerOption) {
    dropdownText = answerOption.answerOption;
    checkList_Answer_Option_Id_ = answerOption.checkListAnswerOptionId;
    non_Compliance_Flag = answerOption.nonComplianceFlag;
    option_mandatory_Flag = answerOption.optionMandatoryFlag;
  }
}
