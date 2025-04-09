import '../model/model_employee.dart';

abstract class AdminEmployeeState {}

class AdminEmployeeInitial extends AdminEmployeeState {}

class AdminEmployeeLoading extends AdminEmployeeState {}

class AdminEmployeeLoaded extends AdminEmployeeState {
  final List<AdminEmployee> employees;

  AdminEmployeeLoaded(this.employees);
}

class AdminEmployeeError extends AdminEmployeeState {
  final String message;

  AdminEmployeeError(this.message);
}
