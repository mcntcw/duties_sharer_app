part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  final Profile user;
  const UserState({required this.user});

  @override
  List<Object> get props => [user];
}

final class UserInitial extends UserState {
  UserInitial() : super(user: Profile.empty);
}

class UserProcess extends UserState {
  const UserProcess({
    required super.user,
  });
}

final class UserSuccess extends UserState {
  const UserSuccess({
    required super.user,
  });
}

class UserFailure extends UserState {
  final String errorMessage;

  const UserFailure({
    required super.user,
    required this.errorMessage,
  });
}

//UPDATE USER

final class UpdateUserSuccess extends UserState {
  const UpdateUserSuccess({
    required super.user,
  });
}
