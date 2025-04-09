import 'dart:convert';
import 'package:admin/Admin/screen/Update_employee.dart';
import 'package:admin/Admin/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeEmployeeScreennew extends StatefulWidget {
  const HomeEmployeeScreennew({super.key});

  @override
  State<HomeEmployeeScreennew> createState() => _HomeScreennewState();
}

class _HomeScreennewState extends State<HomeEmployeeScreennew> {
  String? savedEmail;
  Map<String, dynamic>? userData;
  String result = "Đây là trang chủ";

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  void _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null && email.isNotEmpty) {
      setState(() {
        savedEmail = email;
      });
      _callApi(email);
    } else {
      setState(() {
        result = "Không tìm thấy email đã lưu.";
      });
    }
  }

  Future<void> _callApi(String account_employee_id) async {
    final url = Uri.parse("http://10.0.2.2:5000/Admin/employee/employee-info");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'account_employee_id': account_employee_id}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);
        final employee = data["employee"]["message"][0]; // lấy đúng employee
        setState(() {
          userData = employee;
          result = "Lấy thông tin thành công";
        });
      } else if (response.statusCode == 404) {
        setState(() {
          result = "Không tìm thấy nhân viên!";
        });
      } else {
        setState(() {
          result = "Lỗi: Response không hợp lệ";
        });
      }
    } catch (e) {
      setState(() {
        result = "Lỗi kết nối: $e";
      });
    }
  }

  Future<void> updateEmployeeInfo() async {
    if (userData == null || savedEmail == null) {
      setState(() {
        result = "Dữ liệu không hợp lệ để cập nhật.";
      });
      return;
    }

    final url = Uri.parse("http://10.0.2.2:5000/Admin/employee-update");
    final body = {
      'first_name': userData!['first_name'],
      'last_name': userData!['last_name'],
      'email': userData!['email'],
      'address': userData!['address'],
      'phone': userData!['phone'],
      'role': userData!['role'],
      'account_employee_id': savedEmail,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print("Update body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          result = "Cập nhật thành công!";
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Thành công"),
              content: const Text("Thông tin đã được cập nhật."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // đóng alert
                    _callApi(savedEmail!); // gọi lại API để cập nhật giao diện
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          result = "Cập nhật thất bại: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Lỗi kết nối khi cập nhật: $e";
      });
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
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sửa hồ sơ"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: updateEmployeeInfo,
            icon: const Icon(Icons.check),
            tooltip: "cap nhat",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            userData != null
                ? ListView(
                  children: [
                    _buildInfoTile(
                      "Họ tên",
                      "${userData!['first_name']} ${userData!['last_name']}",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => UpdateEmployee(
                                  label: "Họ tên",
                                  value:
                                      "${userData!['first_name']} ${userData!['last_name']}",
                                  onSave: (newValue) {
                                    final parts = newValue.trim().split(' ');
                                    setState(() {
                                      userData!['first_name'] = parts.first;
                                      userData!['last_name'] =
                                          parts.length > 1
                                              ? parts.sublist(1).join(' ')
                                              : '';
                                    });
                                  },
                                ),
                          ),
                        );
                      },
                    ),
                    _buildInfoTile("Email", userData!['email'], () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => UpdateEmployee(
                                label: "Email",
                                value: userData!['email'],
                                onSave: (newValue) {
                                  setState(() {
                                    userData!['email'] = newValue;
                                  });
                                },
                              ),
                        ),
                      );
                    }),
                    _buildInfoTile("Địa chỉ", userData!['address'], () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => UpdateEmployee(
                                label: "Địa chỉ",
                                value: userData!['address'],
                                onSave: (newValue) {
                                  setState(() {
                                    userData!['address'] = newValue;
                                  });
                                },
                              ),
                        ),
                      );
                    }),
                    _buildInfoTile("Số điện thoại", userData!['phone'], () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => UpdateEmployee(
                                label: "Số điện thoại",
                                value: userData!['phone'],
                                onSave: (newValue) {
                                  setState(() {
                                    userData!['phone'] = newValue;
                                  });
                                },
                              ),
                        ),
                      );
                    }),
                    _buildInfoTile("Chức vụ", userData!['role'], () {
                      if (userData!['role'].toLowerCase() != 'admin') {
                        // Hiển thị alert nếu không phải admin
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Không thể chỉnh sửa"),
                                content: const Text(
                                  "You Not Have Permission To Update Role !",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                        );
                        return; // Không cho đi tiếp
                      }

                      // Nếu là admin thì được sửa
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => UpdateEmployee(
                                label: "Chức vụ",
                                value: userData!['role'],
                                onSave: (newValue) {
                                  setState(() {
                                    userData!['role'] = newValue;
                                  });
                                },
                              ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                )
                : Center(
                  child: Text(result, style: const TextStyle(fontSize: 18)),
                ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value, VoidCallback onTap) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value ?? 'Chưa có'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
