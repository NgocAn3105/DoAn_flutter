import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/employee_bloc.dart';
import '../events/employee_event.dart';
import '../states/employee_state.dart';
import 'package:admin/Admin/screen/Update_employee.dart';
import 'package:admin/Admin_bloc/screen/Login_screen.dart';

class HomeEmployeeScreennew extends StatefulWidget {
  const HomeEmployeeScreennew({super.key});

  @override
  State<HomeEmployeeScreennew> createState() => _HomeEmployeeScreennewState();
}

class _HomeEmployeeScreennewState extends State<HomeEmployeeScreennew> {
  String? savedEmail;
  late final EmployeeBloc _employeeBloc;

  @override
  void initState() {
    super.initState();
    _employeeBloc = EmployeeBloc();
    _loadEmailAndFetch();
  }

  Future<void> _loadEmailAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null && email.isNotEmpty) {
      setState(() => savedEmail = email);
      _employeeBloc.add(FetchEmployeeData(email));
    }
  }

  void _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Xác nhận"),
            content: const Text("Bạn có chắc muốn đăng xuất không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Không"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Đăng xuất"),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _employeeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _employeeBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sửa hồ sơ"),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              onPressed: () {
                final state = _employeeBloc.state;
                if (state is EmployeeLoaded && savedEmail != null) {
                  _employeeBloc.add(
                    UpdateEmployeeData(state.employee, savedEmail!),
                  );
                }
              },
              icon: const Icon(Icons.check),
              tooltip: "Cập nhật",
            ),
          ],
        ),
        body:
            savedEmail == null
                ? const Center(child: CircularProgressIndicator())
                : BlocConsumer<EmployeeBloc, EmployeeState>(
                  listener: (context, state) {
                    if (state is EmployeeUpdated) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                      _employeeBloc.add(FetchEmployeeData(savedEmail!));
                    } else if (state is EmployeeError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    if (state is EmployeeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is EmployeeLoaded) {
                      final userData = state.employee;
                      return ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          _buildInfoTile(
                            "Họ tên",
                            "${userData['first_name']} ${userData['last_name']}",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => UpdateEmployee(
                                        label: "Họ tên",
                                        value:
                                            "${userData['first_name']} ${userData['last_name']}",
                                        onSave: (newValue) {
                                          final parts = newValue.trim().split(
                                            ' ',
                                          );
                                          _employeeBloc.add(
                                            UpdateEmployeeData({
                                              ...userData,
                                              'first_name': parts.first,
                                              'last_name':
                                                  parts.length > 1
                                                      ? parts
                                                          .sublist(1)
                                                          .join(' ')
                                                      : '',
                                            }, savedEmail!),
                                          );
                                        },
                                      ),
                                ),
                              );
                            },
                          ),
                          _buildInfoTile("Email", userData['email'], () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => UpdateEmployee(
                                      label: "Email",
                                      value: userData['email'],
                                      onSave: (newValue) {
                                        _employeeBloc.add(
                                          UpdateEmployeeData({
                                            ...userData,
                                            'email': newValue,
                                          }, savedEmail!),
                                        );
                                      },
                                    ),
                              ),
                            );
                          }),
                          _buildInfoTile("Địa chỉ", userData['address'], () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => UpdateEmployee(
                                      label: "Địa chỉ",
                                      value: userData['address'],
                                      onSave: (newValue) {
                                        _employeeBloc.add(
                                          UpdateEmployeeData({
                                            ...userData,
                                            'address': newValue,
                                          }, savedEmail!),
                                        );
                                      },
                                    ),
                              ),
                            );
                          }),
                          _buildInfoTile(
                            "Số điện thoại",
                            userData['phone'],
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => UpdateEmployee(
                                        label: "Số điện thoại",
                                        value: userData['phone'],
                                        onSave: (newValue) {
                                          _employeeBloc.add(
                                            UpdateEmployeeData({
                                              ...userData,
                                              'phone': newValue,
                                            }, savedEmail!),
                                          );
                                        },
                                      ),
                                ),
                              );
                            },
                          ),
                          _buildInfoTile("Chức vụ", userData['role'], () {
                            if (userData['role'].toLowerCase() != 'admin') {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text("Không thể chỉnh sửa"),
                                      content: const Text(
                                        "Bạn không có quyền cập nhật vai trò.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => UpdateEmployee(
                                        label: "Chức vụ",
                                        value: userData['role'],
                                        onSave: (newValue) {
                                          _employeeBloc.add(
                                            UpdateEmployeeData({
                                              ...userData,
                                              'role': newValue,
                                            }, savedEmail!),
                                          );
                                        },
                                      ),
                                ),
                              );
                            }
                          }),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text("Đăng xuất"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      );
                    } else if (state is EmployeeError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "Không có dữ liệu",
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }
                  },
                ),
      ),
    );
  }
}

Widget _buildInfoTile(String label, String? value, VoidCallback onTap) {
  return ListTile(
    title: Text(label),
    subtitle: Text(value ?? 'Chưa có'),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: onTap,
  );
}
