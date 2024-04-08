import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:group_repository/group_repository_library.dart';

part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GroupRepository _groupRepository;
  GroupsBloc({required GroupRepository groupRepository})
      : _groupRepository = groupRepository,
        super(const GroupsInitial()) {
    on<GetUserGroups>((event, emit) async {
      emit(const GroupsProcess());
      try {
        final loadedGroups = await _groupRepository.getUserGroups(event.userId);
        emit(GroupsSuccess(groups: loadedGroups));
      } catch (e) {
        emit(const GroupsFailure());
      }
    });
    on<AddGroup>((event, emit) async {
      emit(GroupAddProcess(groups: state.groups));
      try {
        final newGroup = await _groupRepository.addGroup(event.group, event.initiatorId);
        final newGroups = List.of(state.groups)..add(newGroup);
        emit(const GroupAddSuccess());
        emit(GroupsSuccess(groups: newGroups));
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.substring("Exception: ".length);
        }
        final groups = state.groups;
        emit(GroupAddFailure(errorMessage: errorMessage));
        emit(GroupsSuccess(groups: groups));
      }
    });

    on<UpdateGroup>((event, emit) async {
      emit(GroupUpdateProcess(groups: state.groups));
      try {
        await _groupRepository.updateGroup(event.group);
        final newGroups = state.groups.map((group) {
          if (group.id == event.group.id) {
            return event.group;
          } else {
            return group;
          }
        }).toList();
        emit(const GroupUpdateSuccess());
        emit(GroupsSuccess(groups: newGroups));
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.substring("Exception: ".length);
        }
        final groups = state.groups;
        emit(GroupUpdateFailure(errorMessage: errorMessage));
        emit(GroupsSuccess(groups: groups));
      }
    });

    on<JoinGroup>((event, emit) async {
      emit(GroupJoinProcess(groups: state.groups));
      try {
        final newGroup = await _groupRepository.joinGroup(event.groupId, event.joiningId);
        final newGroups = List.of(state.groups)..add(newGroup);
        emit(const GroupJoinSuccess());
        emit(GroupsSuccess(groups: newGroups));
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.substring("Exception: ".length);
        }
        final groups = state.groups;
        emit(GroupJoinFailure(errorMessage: errorMessage));
        emit(GroupsSuccess(groups: groups));
      }
    });

    on<LeaveGroup>((event, emit) async {
      emit(GroupLeaveProcess(groups: state.groups));
      try {
        await _groupRepository.leaveGroup(event.groupId, event.leavingId);
        final newGroups = state.groups.where((group) => group.id != event.groupId).toList();
        emit(const GroupLeaveSuccess());
        emit(GroupsSuccess(groups: newGroups));
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.substring("Exception: ".length);
        }
        final groups = state.groups;
        emit(GroupLeaveFailure(errorMessage: errorMessage));
        emit(GroupsSuccess(groups: groups));
      }
    });
  }
}
