abstract class EmployeeEvent {}

class FetchEmployeeData extends EmployeeEvent {
  final String account_customer_id;
  FetchEmployeeData(this.account_customer_id);
}

class UpdateEmployeeData extends EmployeeEvent {
  final Map<String, dynamic> updatedData;
  final String accountId;
  UpdateEmployeeData(this.updatedData, this.accountId);
}
