import 'dart:convert';
import 'package:admin/Admin/screen/main_screen.dart';
import 'package:admin/Admin/screen/screenNew.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String message = "";
  Future<void> _Login() async {
    String input = _emailController.text.trim();

    if (int.tryParse(input) != null) {
      final url = Uri.parse(
        "http://10.0.2.2:5000/Admin/employee/employee-login",
      );
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'account_employee_id': int.parse(_emailController.text.trim()),
            'password': _passwordController.text.trim(),
          }),
        );

        final data = json.decode(response.body);

        final employee = data["employee"];
        final messageFromApi = employee["message"];

        if (employee["status"] == 200) {
          setState(() {
            message = "✅ $messageFromApi";
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', input);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      MainScreen(userEmail: _emailController.text.trim()),
            ),
          );
        } else {
          setState(() {
            message = "❌ Đăng nhập thất bại: $messageFromApi";
          });
        }
      } catch (e) {
        setState(() {
          message = "⚠️ Lỗi kết nối: $e";
          print(message);
        });
      }
    } else {
      final url = Uri.parse("http://10.0.2.2:5000/users/login");
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }),
        );

        final data = json.decode(response.body);

        final user = data["user"];
        final messageFromApi = user["message"];

        if (user["status"] == 200) {
          setState(() {
            message = "✅ $messageFromApi";
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', _emailController.text.trim());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      MainScreen(userEmail: _emailController.text.trim()),
            ),
          );
        } else {
          setState(() {
            message = "❌ Đăng nhập thất bại: $messageFromApi";
          });
        }
      } catch (e) {
        setState(() {
          message = "⚠️ Lỗi kết nối: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email or Number"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mật khẩu"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _Login, child: const Text("Đăng nhập")),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
