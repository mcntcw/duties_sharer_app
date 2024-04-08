import 'package:equatable/equatable.dart';

class ActivityEntity extends Equatable {
  final String name;
  final int color;

  const ActivityEntity({
    required this.name,
    required this.color,
  });

  Map<String, Object?> toDocument() {
    return {
      'name': name,
      'color': color,
    };
  }

  static ActivityEntity fromDocument(Map<String, dynamic> document) {
    return ActivityEntity(
      name: document['name'] as String,
      color: document['color'] as int,
    );
  }

  @override
  List<Object?> get props => [name, color];
}
