import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/src/models/models.dart';

abstract class UserRepository {
  Stream<User?> get user;
  Future<Profile> signUp(Profile user, String password);
  Future<void> setUser(Profile user);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<Profile> getUser(String userId);
  Future<Profile> updateUser(Profile currentUser, String userId);
}
