import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:theproject1/journal.dart';
import 'package:theproject1/loginpagewithemail.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}"); // Handle specific errors if needed
          } else {
            if (snapshot.data == null) {
              return const LoginPageWithEmail();
            } else {
              return const JournalPage();
            }
          }
        },
      ),
    );
  }
}
