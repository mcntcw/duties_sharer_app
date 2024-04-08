import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:group_repository/group_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';
import 'package:uuid/uuid.dart';

class FirebaseGroupRepository implements GroupRepository {
  final groupsCollection = FirebaseFirestore.instance.collection('groups');
  final usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Future<List<Group>> getUserGroups(String userId) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        List<String>? userGroups = (userData['groups'] as List<dynamic>?)?.cast<String>();

        if (userGroups != null && userGroups.isNotEmpty) {
          final groupsData = await groupsCollection.where('id', whereIn: userGroups).get();
          List<Group> groups = [];

          for (var groupDoc in groupsData.docs) {
            final groupEntity = GroupEntity.fromDocument(groupDoc.data());
            final group = Group.fromEntity(groupEntity);

            List<String> memberIds = group.members.map((profile) => profile.id).whereType<String>().toList();

            final membersData = await usersCollection.where('id', whereIn: memberIds).get();
            List<Profile> members = membersData.docs.map((userDoc) {
              return Profile.fromEntity(ProfileEntity.fromDocument(userDoc.data()));
            }).toList();

            members = members.map((member) => member.copyWith(groups: [])).toList();

            // List<Activity> activities = (group.activities as List<dynamic>?)?.map((activityData) {
            //       return Activity.fromEntity(ActivityEntity.fromDocument(activityData));
            //     }).toList() ??
            //     [];

            Group newGroup = Group(
              id: group.id,
              name: group.name,
              members: members,
              activities: group.activities,
              duties: group.duties,
            );
            //print(newGroup);
            groups.add(newGroup);
          }

          return groups;
        }
      }

      return [];
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<Group> addGroup(Group group, String initiatorId) async {
    try {
      String assignedId = const Uuid().v1();
      Profile initiator = await usersCollection
          .doc(initiatorId)
          .get()
          .then((value) => Profile.fromEntity(ProfileEntity.fromDocument(value.data()!)));

      Group newGroup = group.copyWith(id: assignedId, members: [initiator, ...group.members]);

      await groupsCollection.doc(newGroup.id).set({
        'id': newGroup.id,
        'name': newGroup.name,
        'members': newGroup.members.map((profile) => profile.id).toList(),
        'activities': newGroup.activities.map((activity) => activity.toEntity().toDocument()).toList(),
      });

      await groupsCollection.doc(newGroup.id).update({
        'members': FieldValue.arrayUnion([initiatorId]),
      });

      await usersCollection.doc(initiatorId).update({
        'groups': FieldValue.arrayUnion([newGroup.id]),
      });
      return newGroup;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteGroup(Group group) async {
    try {
      await groupsCollection.doc(group.id).delete();

      for (Profile member in group.members) {
        await usersCollection.doc(member.id).update({
          'groups': FieldValue.arrayRemove([group.id]),
        });
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateGroup(Group currentGroup) async {
    try {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(currentGroup.id).get();
      if (groupDoc.exists) {
        final groupData = groupDoc.data() as Map<String, dynamic>;

        bool hasChanges = false;

        String? groupName = groupData['name'];
        if (groupName != null && groupName != currentGroup.name) {
          hasChanges = true;
        }

        List<String>? members = (groupData['members'] as List<dynamic>).cast<String>();

        // Konwersja listy obiektów Profile na listę identyfikatorów
        List<String> memberIds = currentGroup.members.map((profile) => profile.id).toList();

        if (!listEquals(members, memberIds)) {
          hasChanges = true;
        }

        List<String>? categories = (groupData['categories'] as List<dynamic>).cast<String>();
        if (!listEquals(categories, currentGroup.activities)) {
          hasChanges = true;
        }

        if (hasChanges) {
          await FirebaseFirestore.instance.collection('groups').doc(currentGroup.id).update({
            'name': currentGroup.name,
            'members': memberIds,
          });
        }
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  @override
  Future<Group> joinGroup(String id, String joiningId) async {
    try {
      // Pobierz grupę o podanym id z Firebase
      final groupDoc = await groupsCollection.doc(id).get();

      if (groupDoc.exists) {
        // Konwertuj dane dokumentu na obiekt GroupEntity
        final groupEntity = GroupEntity.fromDocument(groupDoc.data()!);

        // Utwórz nową grupę z użyciem obiektu GroupEntity
        Group group = Group.fromEntity(groupEntity);
        List<String> memberIds = group.members.map((profile) => profile.id).whereType<String>().toList();

        final membersData = await usersCollection.where('id', whereIn: memberIds).get();
        List<Profile> members = membersData.docs.map((userDoc) {
          return Profile.fromEntity(ProfileEntity.fromDocument(userDoc.data()));
        }).toList();

        // Pobierz pełny profil użytkownika o podanym joiningId z Firebase
        final joiningUserDoc = await usersCollection.doc(joiningId).get();
        final joiningUserProfile = Profile.fromEntity(ProfileEntity.fromDocument(joiningUserDoc.data()!));

        group.members.add(joiningUserProfile);

        // Zaktualizuj dokument grupy w Firebase
        await groupsCollection.doc(id).update({
          'members': group.members.map((profile) => profile.id).toList(),
        });

        // Dodaj id grupy do pola 'groups' użytkownika
        await usersCollection.doc(joiningId).update({
          'groups': FieldValue.arrayUnion([id]),
        });

        final groupWiithMembersProfiles = group.copyWith(members: members);
        groupWiithMembersProfiles.members.add(joiningUserProfile);
        return groupWiithMembersProfiles;
      } else {
        throw Exception('No group found with the specified ID');
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> leaveGroup(String id, String leavingId) async {
    try {
      // Pobierz grupę o podanym id z Firebase
      final groupDoc = await groupsCollection.doc(id).get();

      if (groupDoc.exists) {
        // Konwertuj dane dokumentu na obiekt GroupEntity
        final groupEntity = GroupEntity.fromDocument(groupDoc.data()!);

        // Utwórz nową grupę z użyciem obiektu GroupEntity
        final group = Group.fromEntity(groupEntity);

        // Usuń użytkownika z grupy
        group.members.removeWhere((member) => member.id == leavingId);

        // Zaktualizuj dokument grupy w Firebase
        await groupsCollection.doc(id).update({
          'members': group.members.map((profile) => profile.id).toList(),
        });

        // Usuń id grupy z pola 'groups' użytkownika
        await usersCollection.doc(leavingId).update({
          'groups': FieldValue.arrayRemove([id]),
        });
      } else {
        throw Exception('No group found with the specified ID');
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
