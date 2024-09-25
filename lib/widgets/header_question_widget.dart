import 'package:flutter/material.dart';

class HeaderQuestionWidget extends StatelessWidget {
  final String status;
  final String itemName;
  final String submissionDate;
  final int updatedBy;
  final String updatedName;
  final String updatedByDatetime;
  final String checklistEditStatus;
  final String non_compliance_flag;
  final String outputDate;

  const HeaderQuestionWidget(
      {Key? key,
      required this.status,
      required this.itemName,
      required this.submissionDate,
      required this.updatedBy,
      required this.updatedName,
      required this.updatedByDatetime,
      required this.checklistEditStatus,
      required this.non_compliance_flag,
      required this.outputDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [BoxShadow()]),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Visibility(
                    visible: status == 'Completed'
                        ? false
                        : status == 'InProcess'
                            ? false
                            : true,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.orangeAccent,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        const Text('Submission Timeline : ',
                            style: TextStyle(fontSize: 13)),
                        Text(outputDate,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: status == 'Completed'
                        ? true
                        : status == 'InProcess'
                            ? true
                            : false,
                    child: Row(
                      children: [
                        const Text('Updated by : ',
                            style: TextStyle(fontSize: 13)),
                        Text('$updatedBy $updatedName',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Visibility(
                    visible: status == 'Completed'
                        ? true
                        : status == 'InProcess'
                            ? true
                            : false,
                    child: Row(
                      children: [
                        const Text('Updated on : ',
                            style: TextStyle(fontSize: 13)),
                        Text(updatedByDatetime,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 1,
                bottom: 1,
                top: 1,
                child: checklistEditStatus != 'C'
                    ? const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 25,
                      )
                    : const Icon(
                        Icons.check,
                        color: Colors.blue,
                        size: 25,
                      ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: true,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 40, top: 10),
              child: CircleAvatar(
                radius: 4.5,
                backgroundColor: non_compliance_flag == "1"
                    ? Colors.red
                    : non_compliance_flag == "0"
                        ? Colors.green
                        : Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
