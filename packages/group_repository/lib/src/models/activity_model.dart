import 'package:equatable/equatable.dart';
import 'package:group_repository/src/entities/activity_entity.dart';

class Activity extends Equatable {
  final String name;
  final int color;

  const Activity({
    required this.name,
    required this.color,
  });

  static const empty = Activity(
    name: '',
    color: 0xFFFFFFFF,
  );

  Activity copyWith({String? name, int? color}) {
    return Activity(
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  ActivityEntity toEntity() {
    return ActivityEntity(
      name: name,
      color: color,
    );
  }

  static Activity fromEntity(ActivityEntity entity) {
    return Activity(
      name: entity.name,
      color: entity.color,
    );
  }

  @override
  List<Object?> get props => [name, color];
}
