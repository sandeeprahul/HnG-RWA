// selected_dates_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/opeartions/weekoff_entity.dart';

class SelectedDatesList extends StatelessWidget {
  final List<WeekoffEntity> selectedDates;

  const SelectedDatesList({super.key, required this.selectedDates});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: selectedDates.length,
        itemBuilder: (context, index) {
          final details = selectedDates[index];
          final dayName = DateFormat('EEE').format(details.date);
          final monthName = DateFormat('MMM').format(details.date);
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${index + 1}.$dayName ${details.date.day} $monthName ${details.date.year} - ${details.leaveType} ',
            ),
          );
        },
      ),
    );
  }
}
