import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthAdminLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String secretKey;

  const AuthAdminLoginRequested(this.email, this.password, this.secretKey);

  @override
  List<Object> get props => [email, password, secretKey];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const AuthRegisterRequested(this.email, this.password, this.displayName);

  @override
  List<Object> get props => [email, password, displayName];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateProfileRequested extends AuthEvent {
  final String displayName;
  const AuthUpdateProfileRequested(this.displayName);

  @override
  List<Object> get props => [displayName];
}

class AuthChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  const AuthChangePasswordRequested(this.oldPassword, this.newPassword);

  @override
  List<Object> get props => [oldPassword, newPassword];
}

class AuthDeleteAccountRequested extends AuthEvent {}

class AuthOnboardingCompleted extends AuthEvent {}
