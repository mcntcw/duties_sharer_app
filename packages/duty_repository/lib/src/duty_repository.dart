import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duty_repository/duty_repository_library.dart';
import 'package:group_repository/group_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';
import 'package:uuid/uuid.dart';

class FirebaseDutyRepository implements DutyRepository {
  final dutiesCollection = FirebaseFirestore.instance.collection('duties');
  final groupsCollection = FirebaseFirestore.instance.collection('groups');
  final usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Future<List<Duty>> getGroupDuties(String groupId) async {
    try {
      final groupDoc = await groupsCollection.doc(groupId).get();
      if (groupDoc.exists) {
        final groupData = groupDoc.data() as Map<String, dynamic>;

        List<String>? groupDuties = (groupData['duties'] as List<dynamic>?)?.cast<String>();

        if (groupDuties != null && groupDuties.isNotEmpty) {
          const batchSize = 30;
          final batches = <List<String>>[];

          for (var i = 0; i < groupDuties.length; i += batchSize) {
            final end = (i + batchSize < groupDuties.length) ? i + batchSize : groupDuties.length;
            final batch = groupDuties.sublist(i, end);
            batches.add(batch);
          }

          List<Duty> duties = [];

          for (var batch in batches) {
            final dutiesData = await dutiesCollection.where('id', whereIn: batch).get();

            for (var dutyDoc in dutiesData.docs) {
              final dutyEntity = DutyEntity.fromDocument(dutyDoc.data());
              final duty = Duty.fromEntity(dutyEntity);

              final authorData = await usersCollection.doc(duty.author.id).get();
              final author = Profile.fromEntity(
                ProfileEntity.fromDocument(authorData.data() as Map<String, dynamic>),
              );

              Duty newDuty = Duty(
                id: duty.id,
                author: author,
                group: Group.empty.copyWith(id: duty.group.id),
                category: duty.category,
                doneAt: duty.doneAt,
                acceptances: duty.acceptances,
                isApproved: duty.isApproved,
              );
              duties.add(newDuty);
            }
          }

          duties.sort((a, b) => b.doneAt.compareTo(a.doneAt));
          return duties;
        }
      }

      return [];
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<Duty> addDuty(Duty duty, String groupId, String authorId) async {
    try {
      String assignedId = const Uuid().v1();

      Group group = await groupsCollection
          .doc(groupId)
          .get()
          .then((value) => Group.fromEntity(GroupEntity.fromDocument(value.data()!)));

      Profile author = await usersCollection
          .doc(authorId)
          .get()
          .then((value) => Profile.fromEntity(ProfileEntity.fromDocument(value.data()!)));

      bool isGroupOfOne = group.members.length == 1 && group.members.first.id == authorId;

      Duty newDuty = duty.copyWith(
        id: assignedId,
        author: author,
        group: group,
        isApproved: isGroupOfOne ? true : false,
      );

      await dutiesCollection.doc(newDuty.id).set({
        'id': newDuty.id,
        'author': newDuty.author.id,
        'group': newDuty.group.id,
        'category': newDuty.category.toEntity().toDocument(),
        'doneAt': newDuty.doneAt,
        'acceptances': newDuty.acceptances.map((profile) => profile.id).toList(),
        'isApproved': isGroupOfOne ? true : newDuty.isApproved,
      });

      await groupsCollection.doc(groupId).update({
        'duties': FieldValue.arrayUnion([newDuty.id]),
      });

      return newDuty;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<Duty> acceptDuty(Duty duty, String groupId, String accepterId) async {
    try {
      Group group = await groupsCollection
          .doc(groupId)
          .get()
          .then((value) => Group.fromEntity(GroupEntity.fromDocument(value.data()!)));

      if (!group.members.any((profile) => profile.id == accepterId)) {
        throw Exception("User is not a member of the group");
      }

      Profile accepter = await usersCollection
          .doc(accepterId)
          .get()
          .then((value) => Profile.fromEntity(ProfileEntity.fromDocument(value.data()!)));

      if (!duty.acceptances.any((profile) => profile.id == accepterId)) {
        Duty updatedDuty = duty.copyWith(acceptances: [...duty.acceptances, accepter]);

        await dutiesCollection.doc(duty.id).update({
          'acceptances': FieldValue.arrayUnion([accepterId]),
        });
        Set<String> groupMemberIds = group.members.map((profile) => profile.id).toSet();
        Set<String> acceptedMemberIds = updatedDuty.acceptances.map((profile) => profile.id).toSet();
        groupMemberIds.remove(duty.author.id);
        // print(groupMemberIds);
        // print(acceptedMemberIds);
        //print(groupMemberIds == acceptedMemberIds);
        if (groupMemberIds.length == acceptedMemberIds.length) {
          updatedDuty = duty.copyWith(isApproved: true);
          await dutiesCollection.doc(duty.id).update({
            'isApproved': true,
          });
        }

        return updatedDuty;
      } else {
        return duty;
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteDuty(Duty duty) async {
    try {
      await dutiesCollection.doc(duty.id).delete();

      final groupSnapshot = await groupsCollection.doc(duty.group.id).get();
      if (groupSnapshot.exists) {
        final groupRef = groupsCollection.doc(duty.group.id);
        await groupRef.update({
          'duties': FieldValue.arrayRemove([duty.id]),
        });
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

  //stara wersja 
  // Future<List<Duty>> getGroupDuties(String groupId) async {
  //   try {
  //     final groupDoc = await groupsCollection.doc(groupId).get();
  //     if (groupDoc.exists) {
  //       final groupData = groupDoc.data() as Map<String, dynamic>;

  //       List<String>? groupDuties = (groupData['duties'] as List<dynamic>?)?.cast<String>();

  //       if (groupDuties != null && groupDuties.isNotEmpty) {
  //         final dutiesData = await dutiesCollection.where('id', whereIn: groupDuties).get();
  //         List<Duty> duties = [];

  //         for (var dutyDoc in dutiesData.docs) {
  //           final dutyEntity = DutyEntity.fromDocument(dutyDoc.data());
  //           final duty = Duty.fromEntity(dutyEntity);

  //           final authorData = await usersCollection.doc(duty.author.id).get();
  //           // final authorProfile = Profile(
  //           //   id: authorData['id'].toString(),
  //           //   email: authorData['email'].toString(),
  //           //   name: authorData['name'].toString(),
  //           // );
  //           final author = Profile.fromEntity(
  //             ProfileEntity.fromDocument(authorData.data() as Map<String, dynamic>),
  //           );

  //           Duty newDuty = Duty(
  //             id: duty.id,
  //             author: author,
  //             group: Group.empty.copyWith(id: duty.group.id),
  //             category: duty.category,
  //             doneAt: duty.doneAt,
  //             acceptances: duty.acceptances,
  //             isApproved: duty.isApproved,
  //           );
  //           print(newDuty);
  //           duties.add(newDuty);
  //         }
  //         duties.sort((a, b) => b.doneAt.compareTo(a.doneAt));
  //         return duties;
  //       }
  //     }

  //     return [];
  //   } catch (e) {
  //     log(e.toString());
  //     rethrow;
  //   }
  // }