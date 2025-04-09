// screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './screen/form_add_employee.dart'; // Import form_add_employee.dart

import 'Admin_bloc.dart';
import 'Admin_event.dart';
import 'Admin_state.dart';

class AdminEmployeeScreen extends StatelessWidget {
  const AdminEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminEmployeeBloc()..add(FetchAdminEmployees()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý nhân viên'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Mở form thêm nhân viên
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEmployeeForm(),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AdminEmployeeBloc, AdminEmployeeState>(
          builder: (context, state) {
            if (state is AdminEmployeeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminEmployeeLoaded) {
              // Lọc bỏ những nhân viên có role là 'admin'
              final filteredEmployees =
                  state.employees
                      .where((emp) => emp.role.toLowerCase() != 'admin')
                      .toList();
              return ListView.builder(
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final emp = filteredEmployees[index];
                  return ListTile(
                    title: Text('${emp.id} - ${emp.firstName} ${emp.lastName}'),
                    subtitle: Text('${emp.role} - ${emp.email}'),
                  );
                },
              );
            } else if (state is AdminEmployeeError) {
              return Center(child: Text('Lỗi: ${state.message}'));
            }
            return const Center(child: Text('Không có dữ liệu'));
          },
        ),
      ),
    );
  }
}
