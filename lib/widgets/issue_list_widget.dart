import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hng_flutter/data/opeartions/store_visit/issue_list.dart';

class IssueListWidget extends ConsumerStatefulWidget {
  final IssuesList issueList;

  const IssueListWidget(this.issueList, {Key? key}) : super(key: key);

  @override
  ConsumerState<IssueListWidget> createState() => _IssueListWidgetState();
}

class _IssueListWidgetState extends ConsumerState<IssueListWidget> {
  List<IssuesList> selectedIssueList = [];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.issueList.valueName),
          Checkbox(
              value:
                  selectedIssueList.contains(widget.issueList) ? true : false,
              onChanged: (value) {
                if (selectedIssueList.contains(widget.issueList)) {
                  setState(() {
                    selectedIssueList.remove(widget.issueList);
                  });
                } else {
                  setState(() {
                    selectedIssueList.add(widget.issueList);
                  });
                }
              })
        ],
      ),
    );
  }



}
