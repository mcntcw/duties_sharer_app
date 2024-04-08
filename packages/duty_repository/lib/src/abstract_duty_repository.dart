import 'package:duty_repository/duty_repository_library.dart';

abstract class DutyRepository {
  Future<List<Duty>> getGroupDuties(String groupId);
  Future<Duty> addDuty(Duty duty, String groupId, String authorId);
  Future<Duty> acceptDuty(Duty duty, String groupId, String accepterId);
  Future<void> deleteDuty(Duty duty);
}
