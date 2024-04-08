import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final List<String> groups;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.groups,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'groups': groups,
    };
  }

  static ProfileEntity fromDocument(Map<String, dynamic> document) {
    return ProfileEntity(
      id: document['id'],
      email: document['email'],
      name: document['name'],
      groups: (document['groups'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, email, name, groups];
}
