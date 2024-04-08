import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';
import 'package:group_repository/group_repository_library.dart';

class DutyEntity extends Equatable {
  final String id;
  final Profile author;
  final Group group;
  final Activity category;
  final DateTime doneAt;
  final List<Profile> acceptances;
  final bool isApproved;

  const DutyEntity({
    required this.id,
    required this.author,
    required this.group,
    required this.category,
    required this.doneAt,
    required this.acceptances,
    required this.isApproved,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'author': author,
      'group': group.toEntity().toDocument(),
      'category': category.toEntity().toDocument(),
      'doneAt': doneAt.toUtc().toIso8601String(),
      'acceptances': acceptances,
      'isApproved': isApproved,
    };
  }

  static DutyEntity fromDocument(Map<String, dynamic> document) {
    return DutyEntity(
      id: document['id'],
      author: Profile(id: document['author'].toString(), email: '', name: ''),
      group: Group(id: document['group'].toString(), name: ''),
      category: Activity.fromEntity(ActivityEntity.fromDocument(document['category'] as Map<String, dynamic>)),
      doneAt: (document['doneAt'] as Timestamp).toDate().toLocal(),
      acceptances: (document['acceptances'] as List<dynamic>?)?.map((acceptingId) {
            return Profile(id: acceptingId.toString(), email: '', name: '');
          }).toList() ??
          [],
      isApproved: document['isApproved'],
    );
  }

  @override
  List<Object?> get props => [id, author, group, category, doneAt, acceptances, isApproved];
}
