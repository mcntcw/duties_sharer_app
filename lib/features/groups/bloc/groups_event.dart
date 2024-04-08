part of 'groups_bloc.dart';

sealed class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object> get props => [];
}

class GetUserGroups extends GroupsEvent {
  final String userId;

  const GetUserGroups({required this.userId});
}

class AddGroup extends GroupsEvent {
  final Group group;
  final String initiatorId;

  const AddGroup({required this.group, required this.initiatorId});

  @override
  List<Object> get props => [group, initiatorId];
}

class DeleteGroup extends GroupsEvent {
  final String id;

  const DeleteGroup({required this.id});

  @override
  List<Object> get props => [id];
}

class UpdateGroup extends GroupsEvent {
  final Group group;

  const UpdateGroup({required this.group});

  @override
  List<Object> get props => [group];
}

class JoinGroup extends GroupsEvent {
  final String groupId;
  final String joiningId;

  const JoinGroup({required this.groupId, required this.joiningId});

  @override
  List<Object> get props => [groupId, joiningId];
}

class LeaveGroup extends GroupsEvent {
  final String groupId;
  final String leavingId;

  const LeaveGroup({required this.groupId, required this.leavingId});

  @override
  List<Object> get props => [groupId, leavingId];
}
