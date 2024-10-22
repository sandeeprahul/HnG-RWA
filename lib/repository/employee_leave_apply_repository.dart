import '../api_service.dart';
import '../data/employee_leaveapply_list.dart';

class EmployeeLeaveApplyRepository {
  final ApiService apiService;

  EmployeeLeaveApplyRepository({required this.apiService});

  Future<List<EmployeeLeaveAplylist>> getEmployeeList(String userId) async {
    try {
      final response =
          await apiService.getData(endpoint: '/Login/WeekoffEmployees/$userId');
      List<dynamic> data = response['employeelist'];
      List<EmployeeLeaveAplylist> employeeList =
          data.map((e) => EmployeeLeaveAplylist.fromJson(e)).toList();
      return employeeList;
    } catch (e) {
      throw Exception("Error fetching employee list: $e");
    }
  }
}
