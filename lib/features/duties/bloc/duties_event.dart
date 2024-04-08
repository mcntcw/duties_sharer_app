part of 'duties_bloc.dart';

sealed class DutiesEvent extends Equatable {
  const DutiesEvent();

  @override
  List<Object> get props => [];
}

class GetGroupDuties extends DutiesEvent {
  final String groupId;

  const GetGroupDuties({required this.groupId});
}

class AddDuty extends DutiesEvent {
  final Duty duty;
  final String groupId;
  final String authorId;

  const AddDuty({required this.duty, required this.groupId, required this.authorId});

  @override
  List<Object> get props => [duty, groupId, authorId];
}

class DeleteDuty extends DutiesEvent {
  final Duty duty;

  const DeleteDuty({required this.duty});

  @override
  List<Object> get props => [duty];
}

class AcceptDuty extends DutiesEvent {
  final Duty duty;
  final String groupId;
  final String accepterId;

  const AcceptDuty({required this.duty, required this.groupId, required this.accepterId});

  @override
  List<Object> get props => [duty, groupId, accepterId];
}
