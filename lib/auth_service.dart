import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async{
    return _auth.currentUser;
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      return cred.user;
    } catch (e) {
      print("Something went wrong with signup process");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

      return cred.user;
    } catch (e) {
      print("Something went wrong with login process");
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
      print("Successfully Signed Out");
    } catch (e) {
      print("Something went wrong with the signout process");
    }
  }
}