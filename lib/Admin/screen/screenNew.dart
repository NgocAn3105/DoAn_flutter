import 'dart:convert';
import 'package:admin/Admin/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreennew extends StatefulWidget {
  const HomeScreennew({super.key});

  @override
  State<HomeScreennew> createState() => _HomeScreennewState();
}

class _HomeScreennewState extends State<HomeScreennew> {
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

  Future<void> _callApi(String email) async {
    final url = Uri.parse("http://10.0.2.2:5000/users/info-users");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body} $email");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);
        final user = data["user"]["message"][0];
        setState(() {
          userData = user;
          result = "Lấy thông tin thành công";
        });
      } else if (response.statusCode == 404) {
        setState(() {
          result = "Không tìm thấy user!";
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

  void _clearBody() {
    setState(() {
      userData = null;
      result = "Đây là trang chủ";
    });
    if (savedEmail != null) {
      _callApi(savedEmail!);
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
            onPressed: _clearBody,
            icon: const Icon(Icons.refresh),
            tooltip: "Làm mới",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            userData != null
                ? ListView(
                  children: [
                    _buildInfoTile("Tên", userData!['last_name']),
                    _buildInfoTile("Email", userData!['email']),
                    _buildInfoTile("Địa chỉ", userData!['address']),
                    _buildInfoTile("Số điện thoại", userData!['phone']),

                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  ],
                )
                : Center(
                  child: Text(result, style: const TextStyle(fontSize: 18)),
                ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value ?? 'Chưa có'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Chỉnh sửa $label")));
      },
    );
  }
}
