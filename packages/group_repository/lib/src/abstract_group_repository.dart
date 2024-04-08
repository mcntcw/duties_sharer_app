import 'package:group_repository/group_repository_library.dart';

abstract class GroupRepository {
  Future<List<Group>> getUserGroups(String userId);
  Future<Group> addGroup(Group group, String initiatorId);
  Future<void> updateGroup(Group currentGroup);
  Future<void> deleteGroup(Group group);
  Future<Group> joinGroup(String id, String joiningId);
  Future<void> leaveGroup(String id, String leavingId);
}
