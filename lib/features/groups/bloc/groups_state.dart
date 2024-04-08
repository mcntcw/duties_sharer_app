part of 'groups_bloc.dart';

sealed class GroupsState extends Equatable {
  final List<Group> groups;

  const GroupsState({required this.groups});

  @override
  List<Object> get props => [groups];
}

final class GroupsInitial extends GroupsState {
  const GroupsInitial() : super(groups: const []);
}

final class GroupsProcess extends GroupsState {
  const GroupsProcess() : super(groups: const []);
}

final class GroupsSuccess extends GroupsState {
  const GroupsSuccess({
    required super.groups,
  });
}

final class GroupsFailure extends GroupsState {
  const GroupsFailure() : super(groups: const []);
}

//ADD NEW GROUP

final class GroupAddProcess extends GroupsState {
  const GroupAddProcess({
    required super.groups,
  });
}

final class GroupAddSuccess extends GroupsState {
  const GroupAddSuccess() : super(groups: const []);
}

final class GroupAddFailure extends GroupsState {
  final String errorMessage;
  const GroupAddFailure({required this.errorMessage}) : super(groups: const []);
}

//UPDATE GROUP

final class GroupUpdateProcess extends GroupsState {
  const GroupUpdateProcess({
    required super.groups,
  });
}

final class GroupUpdateSuccess extends GroupsState {
  const GroupUpdateSuccess() : super(groups: const []);
}

final class GroupUpdateFailure extends GroupsState {
  final String errorMessage;
  const GroupUpdateFailure({required this.errorMessage}) : super(groups: const []);
}

//JOIN GROUP

final class GroupJoinProcess extends GroupsState {
  const GroupJoinProcess({
    required super.groups,
  });
}

final class GroupJoinSuccess extends GroupsState {
  const GroupJoinSuccess() : super(groups: const []);
}

final class GroupJoinFailure extends GroupsState {
  final String errorMessage;
  const GroupJoinFailure({required this.errorMessage}) : super(groups: const []);
}

//LEAVE GROUP

final class GroupLeaveProcess extends GroupsState {
  const GroupLeaveProcess({
    required super.groups,
  });
}

final class GroupLeaveSuccess extends GroupsState {
  const GroupLeaveSuccess() : super(groups: const []);
}

final class GroupLeaveFailure extends GroupsState {
  final String errorMessage;
  const GroupLeaveFailure({required this.errorMessage}) : super(groups: const []);
}
