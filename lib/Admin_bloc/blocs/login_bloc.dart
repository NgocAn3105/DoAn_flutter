import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../events/login_event.dart';
import '../states/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(loginInitial()) {
    on<LoginSubmited>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmited event,
    Emitter<LoginState> emit,
  ) async {
    emit(loginLoading());

    String input = event.emailOrId.trim();
    String password = event.password.trim();

    try {
      if (int.tryParse(input) != null) {
        // Employee login
        final url = Uri.parse(
          "http://10.0.2.2:5000/Admin/employee/employee-login",
        );
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'account_employee_id': int.parse(input),
            'password': password,
          }),
        );

        final data = json.decode(response.body);
        final employee = data["employee"];
        final message = employee["message"];

        if (employee["status"] == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', input);
          emit(LoginSuccess(message));
        } else {
          emit(LoginFailure("Đăng nhập thất bại: $message"));
        }
      } else {
        // User login
        final url = Uri.parse("http://10.0.2.2:5000/users/login");
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': input, 'password': password}),
        );

        final data = json.decode(response.body);
        final user = data["user"];
        final message = user["message"];

        if (user["status"] == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', input);
          emit(LoginSuccess(message));
        } else {
          emit(LoginFailure("Đăng nhập thất bại: $message"));
        }
      }
    } catch (e) {
      emit(LoginFailure("Lỗi kết nối: $e"));
    }
  }
}
