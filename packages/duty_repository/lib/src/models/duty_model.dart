import 'package:duty_repository/duty_repository_library.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';
import 'package:group_repository/group_repository_library.dart';

class Duty extends Equatable {
  final String id;
  final Profile author;
  final Group group;
  final Activity category;
  final DateTime doneAt;
  final List<Profile> acceptances;
  final bool isApproved;

  Duty({
    required this.id,
    required this.author,
    required this.group,
    required this.category,
    required this.doneAt,
    List<Profile>? acceptances,
    bool? isApproved,
  })  : acceptances = acceptances ?? [],
        isApproved = isApproved ?? false;

  static final empty = Duty(
    id: '',
    author: Profile.empty,
    group: Group.empty,
    category: Activity.empty,
    doneAt: DateTime(0),
  );

  Duty copyWith(
      {String? id,
      Profile? author,
      Group? group,
      Activity? category,
      DateTime? doneAt,
      List<Profile>? acceptances,
      bool? isApproved}) {
    return Duty(
      id: id ?? this.id,
      author: author ?? this.author,
      group: group ?? this.group,
      category: category ?? this.category,
      doneAt: doneAt ?? this.doneAt,
      acceptances: acceptances ?? this.acceptances,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  DutyEntity toEntity() {
    return DutyEntity(
      id: id,
      author: author,
      group: group,
      category: category,
      doneAt: doneAt,
      acceptances: acceptances,
      isApproved: isApproved,
    );
  }

  static fromEntity(DutyEntity entity) {
    return Duty(
      id: entity.id,
      author: entity.author,
      group: entity.group,
      category: entity.category,
      doneAt: entity.doneAt,
      acceptances: entity.acceptances,
      isApproved: entity.isApproved,
    );
  }

  @override
  List<Object?> get props => [id, author, group, category, doneAt, acceptances, isApproved];
}
