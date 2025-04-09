abstract class AdminEmployeeEvent {}

class FetchAdminEmployees extends AdminEmployeeEvent {}

class AddAdminEmployee extends AdminEmployeeEvent {
  final int accountEmployeeId;
  final String password;

  AddAdminEmployee({required this.accountEmployeeId, required this.password});
}
