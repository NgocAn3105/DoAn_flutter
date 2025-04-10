abstract class LoginEvent {}

class LoginSubmited extends LoginEvent {
  final String emailOrId;
  final String password;

  LoginSubmited(this.emailOrId, this.password);
}
