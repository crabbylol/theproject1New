import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async{
    return _auth.currentUser;
  }

  Future<User?> createUserWithEmailAndPassword(String username, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      if (cred.user != null) {
        try {
          _fire.collection("users").add({
            "username": username,
            "email": email,
            "userId": cred.user!.uid, // Include the user ID here
          });
        } catch (e) {
          print(e.toString());
        }
      }

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

  Future<String?> getCurrentUsername() async {
    final user = await _auth.currentUser;

    if (user != null) {
      final userDoc = await _fire.collection("users").doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData["username"];
      } else {
        print("User document not found");
        return null;
      }
    } else {
      print("User not logged in");
      return null;
    }
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