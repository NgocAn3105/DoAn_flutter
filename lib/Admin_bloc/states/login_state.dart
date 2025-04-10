abstract class LoginState {}

class loginInitial extends LoginState {}

class loginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String message;
  LoginSuccess(this.message);
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}
