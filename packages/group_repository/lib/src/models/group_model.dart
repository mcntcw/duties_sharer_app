import 'package:equatable/equatable.dart';
import 'package:group_repository/src/entities/group_entity.dart';
import 'package:group_repository/src/models/activity_model.dart';
import 'package:user_repository/user_repository_library.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final List<Profile> members;
  final List<Activity> activities;
  final List<String> duties;

  Group({
    required this.id,
    required this.name,
    List<Profile>? members,
    List<Activity>? activities,
    List<String>? duties,
  })  : members = members ?? [],
        activities = activities ?? [],
        duties = duties ?? [];

  static final empty = Group(
    id: '',
    name: '',
    members: const [],
    activities: const [],
  );

  Group copyWith({String? id, String? name, List<Profile>? members, List<Activity>? activities, List<String>? duties}) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      activities: activities ?? this.activities,
      duties: duties ?? this.duties,
    );
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name,
      members: members,
      activities: activities,
      duties: duties,
    );
  }

  static fromEntity(GroupEntity entity) {
    return Group(
      id: entity.id,
      name: entity.name,
      members: entity.members,
      activities: entity.activities,
      duties: entity.duties,
    );
  }

  @override
  List<Object?> get props => [id, name, members, activities, duties];
}
