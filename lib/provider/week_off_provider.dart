import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/employee_leaveapply_list.dart';
import '../data/opeartions/employee_weekoff_entity.dart';
import '../data/opeartions/weekoff_entity.dart';
import '../repository/week_off_respository.dart';
//
// final weekOffProvider =
//     StreamProvider<List<EmployeeLeaveAplylist>?>((ref) async* {
//   final repository = WeekOffRepository();
//   try {
//     List<EmployeeLeaveAplylist>? employeeList =
//         await repository.getEmployeeList();
//     yield employeeList;
//   } catch (e) {
//     print("Error:$e");
//     yield* Stream.error(e);
//   }
// });

final weekOffProvider = FutureProvider<List<EmployeeLeaveAplylist>?>((ref) async {
  final repository = WeekOffRepository();
  try {
    List<EmployeeLeaveAplylist>? employeeList =
    await repository.getEmployeeList();
    return employeeList;
  } catch (e) {
    print("Error: $e");
    // You can return null, empty list, or rethrow the error depending on your handling.
    return [];
  }
});
/*
class EmployeeCodeNotifier extends StateNotifier<String> {
  EmployeeCodeNotifier() : super("");

  void setEmployeeCode(String code) {
    state = code;
  }
}

final employeeCodeProvider =
    StateNotifierProvider<EmployeeCodeNotifier, String>((ref) {
  return EmployeeCodeNotifier();
});
*/

final employeeCodeProvider = StateProvider<String>((ref) => "");

final employeeWeekOfDetailsProvider =
    StreamProvider<EmployeeWeekoffEntity?>((ref) async* {
  final repository = WeekOffRepository();
  final employeeCode = ref.watch(employeeCodeProvider);

  try {
    EmployeeWeekoffEntity? employeeList =
        await repository.getEmployeeWeekOffDetails(employeeCode);
    yield employeeList;
  } catch (e) {
    print("Error:$e");
    yield* Stream.error(e);
  }
});

final selectedDatesProvider =
    StateNotifierProvider<SelectedDatesNotifier, List<WeekoffEntity>>((ref) {
  return SelectedDatesNotifier();
});

class SelectedDatesNotifier extends StateNotifier<List<WeekoffEntity>> {
  SelectedDatesNotifier() : super([]);

  void addSelectedDate(WeekoffEntity selectedDate) {
    state = [...state, selectedDate];
  }

  void removeSelectedDate(DateTime date) {
    state = state
        .where((selectedDate) => !selectedDate.date.isAtSameMomentAs(date))
        .toList();
  }
}
