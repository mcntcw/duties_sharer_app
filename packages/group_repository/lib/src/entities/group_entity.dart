import 'package:equatable/equatable.dart';
import 'package:group_repository/group_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final List<Profile> members;
  final List<Activity> activities;
  final List<String> duties;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.members,
    required this.activities,
    required this.duties,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'activities': activities.map((activity) => activity.toEntity().toDocument()).toList(),
      'duties': duties,
    };
  }

  static GroupEntity fromDocument(Map<String, dynamic> document) {
    return GroupEntity(
      id: document['id'],
      name: document['name'],
      members: (document['members'] as List<dynamic>?)?.map((memberId) {
            return Profile(id: memberId.toString(), email: '', name: '');
          }).toList() ??
          [],
      activities: (document['activities'] as List<dynamic>)
          .map((activityDoc) => Activity.fromEntity(ActivityEntity.fromDocument(activityDoc)))
          .toList(),
      duties: (document['duties'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, name, members, activities, duties];
}
