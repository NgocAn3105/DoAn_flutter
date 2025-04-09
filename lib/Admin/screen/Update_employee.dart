import 'package:flutter/material.dart';

class UpdateEmployee extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onSave; // callback để truyền ngược lại dữ liệu

  const UpdateEmployee({
    super.key,
    required this.label,
    required this.value,
    required this.onSave,
  });

  @override
  State<UpdateEmployee> createState() => _UpdateEmployeeState();
}

class _UpdateEmployeeState extends State<UpdateEmployee> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cập nhật ${widget.label}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: widget.label),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Lưu"),
              onPressed: () {
                widget.onSave(_controller.text); // Gọi lại hàm callback
                Navigator.pop(context); // Quay lại trang trước
              },
            ),
          ],
        ),
      ),
    );
  }
}
