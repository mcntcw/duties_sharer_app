part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetUser extends UserEvent {
  final String id;

  const GetUser({required this.id});
}

class UpdateUser extends UserEvent {
  final String id;

  const UpdateUser({required this.id});
}

class NewGroupAdded extends UserEvent {
  final String id;

  const NewGroupAdded({required this.id});
}
