import 'package:admin/Admin_bloc/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/login_bloc.dart';
import '../events/login_event.dart';
import '../states/login_state.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Đăng nhập")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            MainScreen(userEmail: _emailController.text.trim()),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email hoặc ID",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Mật khẩu"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final bloc = context.read<LoginBloc>();
                      bloc.add(
                        LoginSubmited(
                          _emailController.text,
                          _passwordController.text,
                        ),
                      );
                    },

                    child: const Text("Đăng nhập"),
                  ),
                  const SizedBox(height: 20),
                  if (state is loginLoading)
                    const CircularProgressIndicator()
                  else if (state is LoginFailure)
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    )
                  else if (state is LoginSuccess)
                    Text(
                      "✅ ${state.message}",
                      style: const TextStyle(color: Colors.green),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
