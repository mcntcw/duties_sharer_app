part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class SignInRequested extends SignInEvent {
  final String email;
  final String password;

  const SignInRequested(this.email, this.password);
}

class SignOutRequested extends SignInEvent {
  const SignOutRequested();
}
