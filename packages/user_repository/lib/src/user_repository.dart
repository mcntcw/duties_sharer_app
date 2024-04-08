import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:user_repository/user_repository_library.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser;
    });
  }

  @override
  Future<Profile> signUp(Profile profile, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: profile.email,
        password: password,
      );

      profile = profile.copyWith(id: user.user!.uid);

      return profile;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> setUser(Profile profile) async {
    try {
      await usersCollection.doc(profile.id).set(profile.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<Profile> getUser(String profileId) async {
    try {
      return usersCollection
          .doc(profileId)
          .get()
          .then((value) => Profile.fromEntity(ProfileEntity.fromDocument(value.data()!)));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<Profile> updateUser(Profile currentUser, String userId) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        bool hasChanges = false;

        String? name = userData['name'];
        if (name != null && name != currentUser.name) {
          currentUser = currentUser.copyWith(name: name);
          hasChanges = true;
        }

        List<String>? groups = (userData['groups'] as List<dynamic>).cast<String>();
        if (!listEquals(groups, currentUser.groups)) {
          currentUser = currentUser.copyWith(groups: groups);
          hasChanges = true;
        }

        if (hasChanges) {
          return currentUser;
        }
      }
      return currentUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
