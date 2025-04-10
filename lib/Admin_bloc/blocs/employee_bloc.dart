import 'dart:convert';
import 'package:admin/Admin_bloc/events/employee_event.dart';
import 'package:admin/Admin_bloc/states/employee_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc() : super(EmployeeInitial()) {
    on<FetchEmployeeData>(_onFetchEmployee);
    on<UpdateEmployeeData>(_onUpdateEmployee);
  }

  Future<void> _onFetchEmployee(
    FetchEmployeeData event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    final url = Uri.parse("http://10.0.2.2:5000/Admin/employee/employee-info");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'account_employee_id': event.account_customer_id}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final employee = data["employee"]["message"][0];
        emit(EmployeeLoaded(employee));
      } else {
        emit(EmployeeError("Không tìm thấy nhân viên"));
      }
    } catch (e) {
      emit(EmployeeError("Lỗi kết nối: $e"));
    }
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployeeData event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    final url = Uri.parse("http://10.0.2.2:5000/Admin/employee-update");

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...event.updatedData,
          'account_employee_id': event.accountId,
        }),
      );

      if (response.statusCode == 200) {
        emit(EmployeeUpdated("Cập nhật thành công!"));
      } else {
        emit(EmployeeError("Cập nhật thất bại: ${response.body}"));
      }
    } catch (e) {
      emit(EmployeeError("Lỗi khi cập nhật: $e"));
    }
  }
}
