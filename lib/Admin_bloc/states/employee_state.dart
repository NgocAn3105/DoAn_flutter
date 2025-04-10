abstract class EmployeeState {}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final Map<String, dynamic> employee;
  EmployeeLoaded(this.employee);
}

class EmployeeError extends EmployeeState {
  final String message;
  EmployeeError(this.message);
}

class EmployeeUpdated extends EmployeeState {
  final String message;
  EmployeeUpdated(this.message);
}
