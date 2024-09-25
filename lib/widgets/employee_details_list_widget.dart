import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hng_flutter/data/employee_leaveapply_list.dart';
import 'package:hng_flutter/extensions/string_extension.dart';

import '../presentation/home/operations/calendar_page.dart';
import '../presentation/home/operations/date_selection_page_weekoff.dart';
import '../provider/week_off_provider.dart';


class EmployeeDetailsListWidget extends ConsumerStatefulWidget {
  final EmployeeLeaveAplylist employeeDetails;
  final int sno;

  const EmployeeDetailsListWidget(this.employeeDetails, this.sno, {Key? key}) : super(key: key);

  @override
  ConsumerState<EmployeeDetailsListWidget> createState() => _EmployeeDetailsListWidgetState();
}

class _EmployeeDetailsListWidgetState extends ConsumerState<EmployeeDetailsListWidget> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ref.read(employeeCodeProvider.notifier).state  = widget.employeeDetails.empCode;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DateSelectionPageWeekOff(widget.employeeDetails,)),
        );


      },
      child: Container(
        // height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(widget.employeeDetails.empName.getInitials()),
            ),
            Expanded(
                child:
                Text(widget.employeeDetails.empName, textAlign: TextAlign.center)),
            Expanded(
                child:
                Text(widget.employeeDetails.empCode, textAlign: TextAlign.center)),
            Expanded(
                child: Text(widget.employeeDetails.scheduledDay,
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}


/*class EmployeeDetailsListWidget extends StatelessWidget {

  const EmployeeDetailsListWidget(this.employeeDetails, this.sno, {Key? key})
      : super(key: key);

}*/
