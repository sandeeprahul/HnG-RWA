import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hng_flutter/data/opeartions/employee_list_transfer.dart';
import 'package:hng_flutter/data/opeartions/store_transfer_entity.dart';
import 'package:hng_flutter/extensions/string_extension.dart';
import 'package:hng_flutter/helper/confirmDialog.dart';
import 'package:hng_flutter/repository/store_transfer_respository.dart';

import '../data/opeartions/locations_entity.dart';

class EmployeeTransferDetailsListWidget extends ConsumerStatefulWidget {
  final Employeelist employeeDetails;
  final StoreTransferData storeTransferData;
  final bool isPermanent;

  const EmployeeTransferDetailsListWidget(
      this.employeeDetails, this.storeTransferData, this.isPermanent,
      {Key? key})
      : super(key: key);

  @override
  ConsumerState<EmployeeTransferDetailsListWidget> createState() =>
      _EmployeeTransferDetailsListWidgetState();
}

class _EmployeeTransferDetailsListWidgetState
    extends ConsumerState<EmployeeTransferDetailsListWidget> {
  @override
  Widget build(BuildContext context) {
    TextEditingController daysController = TextEditingController();

    return InkWell(
      onTap: () {
        _showLocationListBottomSheet(
            context,
            widget.storeTransferData.locationlist,
            widget.employeeDetails,
            daysController);
      },
      child: Container(
        // height: ,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blueAccent,
              child: Text(widget.employeeDetails.empName.getInitials(),style: const TextStyle(color: Colors.white),),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      '${widget.employeeDetails.empCode}-${widget.employeeDetails.empName}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(widget.employeeDetails.designation,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                      '${widget.employeeDetails.currentLoactionCode} - ${widget.employeeDetails.currentLoactionName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationListBottomSheet(
      BuildContext context,
      List<Locationlist> locationList,
      Employeelist employeeDetails,
      TextEditingController daysController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 1. Allows the sheet to resize for the keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Consumer(builder: (context, ref, _) {
          final loading = ref.watch(loadingStateProvider);

          return Padding(
            // 2. This pushes the bottom sheet up when the keyboard opens
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 3. Only takes required space
              children: [
                Text(
                  widget.isPermanent
                      ? "Select Location"
                      : "Select Location & No.of days",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  // 4. Sets a max height so it doesn't fill the whole screen, but removes extra white space
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true, // 5. List only takes up space needed by items
                    itemCount: locationList.length,
                    itemBuilder: (context, index) {
                      Locationlist location = locationList[index];
                      bool isCurrentLocation = location.locationCode == employeeDetails.currentLoactionCode;

                      return InkWell(
                        onTap: () {
                          if (!isCurrentLocation) {
                            if (widget.isPermanent) {
                              var params = {
                                "empCode": widget.employeeDetails.empCode,
                                "locationCode": location.locationCode,
                                "transferType": "P",
                                "noofDays": ""
                              };
                              senData(params);
                            }
                          } else {
                            Fluttertoast.showToast(msg: 'Select different location');
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isCurrentLocation ? Colors.grey[200] : Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${location.locationName}\n${location.locationCode}',
                                  style: TextStyle(
                                    color: isCurrentLocation ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ),
                              if (!widget.isPermanent && !isCurrentLocation)
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: daysController,
                                    maxLength: 2,
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (value) {
                                      if (value.isNotEmpty && int.parse(value) <= 10) {
                                        var params = {
                                          "empCode": widget.employeeDetails.empCode,
                                          "locationCode": location.locationCode,
                                          "transferType": "T",
                                          "noofDays": value
                                        };
                                        senData(params);
                                      } else {
                                        Fluttertoast.showToast(msg: "Max 10 days allowed");
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      isDense: true,
                                      hintText: 'Days',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  /*void _showLocationListBottomSheet(
      BuildContext context,
      List<Locationlist> locationList,
      Employeelist employeeDetails,
      TextEditingController daysController)
  {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Consumer(builder: (context, watch, _) {
          final loading = ref.watch(loadingStateProvider);

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.isPermanent
                      ? "Select Location"
                      : "Select Location & No.of days",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: ListView.builder(
                    itemCount: locationList.length,
                    itemBuilder: (context, index) {
                      Locationlist location = locationList[index];
                      return InkWell(
                        onTap: () {
                          if (location.locationCode !=
                              employeeDetails.currentLoactionCode) {
                            if (widget.isPermanent) {
                              var params = {
                                "empCode": widget.employeeDetails.empCode,
                                "locationCode":
                                    locationList[index].locationCode,
                                "transferType": "P",
                                "noofDays": ""
                              };
                              senData(params);
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Select different location',
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: location.locationCode ==
                                    employeeDetails.currentLoactionCode
                                ? Colors.grey[300]
                                : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          child: Row(
                            children: [
                              Text(
                                '${location.locationName}\n${location.locationCode}',
                              ),

                              const Spacer(),
                              // Text('Location Code: ${location.locationCode}'),
                              Visibility(
                                visible: widget.isPermanent
                                    ? false
                                    : location.locationCode ==
                                            employeeDetails.currentLoactionCode
                                        ? false
                                        : true,
                                child: SizedBox(
                                  width: 150,
                                  child: TextField(
                                    enabled: location.locationCode ==
                                            employeeDetails.currentLoactionCode
                                        ? false
                                        : true,
                                    controller: daysController,
                                    onChanged: (value) async {
                                      if (value.isEmpty ||
                                          int.parse(value) > 10) {
                                        if (value.toString() == "0" ||
                                            value.toString() == "00") {
                                          Fluttertoast.showToast(
                                              msg: "Maximum no.of days is 10",
                                              gravity: ToastGravity.TOP);
                                          daysController.clear();
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "Maximum no.of days is 10",
                                              gravity: ToastGravity.TOP);
                                          daysController.clear();
                                        }
                                      } else {
                                        if (value.toString() == "0" ||
                                            value.toString() == "00") {
                                          Fluttertoast.showToast(
                                              msg: "Minimum no.of days is 7",
                                              gravity: ToastGravity.TOP);
                                          daysController.clear();
                                        } else {
                                          // ref.watch(storeTransferProvider);
                                          *//*  var params = {
                                            "empCode":
                                                widget.employeeDetails.empCode,
                                            "locationCode":
                                                locationList[index].locationCode,
                                            "transferType": "T",
                                            "noofDays":
                                                daysController.text.toString()
                                          };
                                          senData(params);*//*
                                        }
                                      }
                                    },
                                    onSubmitted: (value) {
                                      if (kDebugMode) {
                                        print(value);
                                      }
                                      var params = {
                                        "empCode":
                                            widget.employeeDetails.empCode,
                                        "locationCode":
                                            locationList[index].locationCode,
                                        "transferType": "T",
                                        "noofDays":
                                            daysController.text.toString()
                                      };
                                      senData(params);
                                    },
                                    maxLength: 2,
                                    keyboardType: TextInputType.number,

                                    // enabled: location.locationCode==employeeDetails.currentLoactionCode?false:true,
                                    // controller: ,
                                    decoration: const InputDecoration(
                                        counterText: '',
                                        isDense: true,
                                        hintText: 'No.of days',
                                        hintStyle: TextStyle(fontSize: 14),
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                              )

                              *//* ListTile(

                                  title:  Text('Location Name: ${location.locationName}'),
                                  subtitle:,
                                  onTap: () {
                                    // Handle the location selection here
                                    // For example, you can update the employeeDetails with the selected location
                                    Navigator.pop(context); // Close the bottom sheet
                                  },
                                ),*//*
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (loading)
                  const SizedBox(
                    height: 20,
                    child: CircularProgressIndicator(),
                  )
                else
                  const SizedBox()
              ],
            ),
          );
        });
      },
    );
  }*/

  final loadingStateProvider = StateProvider<bool>((ref) => false);

  // Shows a confirmation dialog before performing the transfer. This wraps
  // every call site, so the user must confirm before sendUpdatedLocation runs.
  Future<void> senData(Map<String, Object> params) async {
    showConfirmDialog(
      title: 'Confirm Store Transfer',
      msg:
          'Are you sure you want to transfer ${widget.employeeDetails.empName} (${widget.employeeDetails.empCode})?',
      onConfirmed: () => _performTransfer(params),
    );
  }

  Future<void> _performTransfer(Map<String, Object> params) async {
    ref.read(loadingStateProvider.notifier).state = true;

    try {
      var response = await StoreTransferRepository()
          .sendUpdatedLocation(widget.employeeDetails.empCode, params);
      if (response != "200") {
        Fluttertoast.showToast(
            msg: 'Store Transfer Failed\nPlease retry again');

        ref.read(loadingStateProvider.notifier).state = false;
      } else {
        Fluttertoast.showToast(msg: 'Transfer update  success');
        ref.read(loadingStateProvider.notifier).state = false;
      }

      Navigator.pop(context);
    } catch (e) {
      // Handle any errors that occurred during the API call
      Fluttertoast.showToast(
        msg: 'Network issue\nPlease submit again',
      );
      ref.read(loadingStateProvider.notifier).state = false;
      Navigator.pop(context);
    } finally {
      ref.read(loadingStateProvider.notifier).state = false;
      Navigator.pop(context);
    }
  }
}
