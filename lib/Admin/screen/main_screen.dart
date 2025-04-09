import 'package:admin/Admin/screen/info_employee.dart';
import 'package:admin/Admin/screen/screenNew.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final String userEmail;
  const MainScreen({Key? key, required this.userEmail}) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectdIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text("trang chu")),
    Center(child: Text("Thong tin ca ")),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeEmployeeScreennew()),
      );
    } else {
      setState(() {
        _selectdIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("trang chu"), centerTitle: true),
      body: _screens[_selectdIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectdIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "trang chu"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "ca nhan"),
        ],
      ),
    );
  }
}
