import '../Admin/Admin_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/model_employee.dart';
import '../Admin/Admin_state.dart';

class AdminEmployeeBloc extends Bloc<AdminEmployeeEvent, AdminEmployeeState> {
  AdminEmployeeBloc() : super(AdminEmployeeInitial()) {
    on<FetchAdminEmployees>(_onFetchAdminEmployees);
    on<AddAdminEmployee>(_onAddAdminEmployee); // 👈 thêm dòng này
  }

  Future<void> _onFetchAdminEmployees(
    FetchAdminEmployees event,
    Emitter<AdminEmployeeState> emit,
  ) async {
    emit(AdminEmployeeLoading());
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/Admin/employee-info'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> jsonList = data['respone']['message'];

        final employees =
            jsonList.map((e) => AdminEmployee.fromJson(e)).toList();
        emit(AdminEmployeeLoaded(employees));
      } else {
        emit(AdminEmployeeError('Failed to load admin employees'));
      }
    } catch (e) {
      emit(AdminEmployeeError(e.toString()));
    }
  }

  // 👇 HÀM POST NHÂN VIÊN MỚI
  Future<void> _onAddAdminEmployee(
    AddAdminEmployee event,
    Emitter<AdminEmployeeState> emit,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/employee-add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'account_employee_id': event.accountEmployeeId,
          'password': event.password,
        }),
      );

      if (response.statusCode == 200) {
        // Gửi lại sự kiện load danh sách
        add(FetchAdminEmployees());
      } else {
        emit(
          AdminEmployeeError('Thêm nhân viên thất bại: ${response.statusCode}'),
        );
      }
    } catch (e) {
      emit(AdminEmployeeError('Lỗi khi thêm nhân viên: $e'));
    }
  }
}
