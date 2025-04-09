// models/admin_employee.dart
class AdminEmployee {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String address;
  final String phone;
  final String role;

  AdminEmployee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.phone,
    required this.role,
  });

  factory AdminEmployee.fromJson(Map<String, dynamic> json) {
    return AdminEmployee(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      address: json['address'],
      phone: json['phone'],
      role: json['role'],
    );
  }
}
