import 'package:equatable/equatable.dart';
import 'package:user_repository/src/entities/profile_entity.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String name;
  final List<String> groups;

  Profile({
    required this.id,
    required this.email,
    required this.name,
    List<String>? groups,
  }) : groups = groups ?? [];

  static final empty = Profile(
    id: '',
    email: '',
    name: '',
    groups: const [],
  );

  Profile copyWith({String? id, String? email, String? name, List<String>? groups}) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      groups: groups ?? this.groups,
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      email: email,
      name: name,
      groups: groups,
    );
  }

  static Profile fromEntity(ProfileEntity entity) {
    return Profile(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      groups: entity.groups,
    );
  }

  @override
  List<Object?> get props => [id, email, name, groups];
}
