// import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthImplementation {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<String> getCurrentUser();
  Future<void> signOut();
}

class Auth implements AuthImplementation {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    if (user.isEmailVerified)
      return user.uid;
    else
      return null;
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    try {
      await user.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
    if (user.isEmailVerified)
      return user.uid;
    else
      return null;
  }

  Future<String> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user == null) {
      return null;
    } else {
      return user.uid;
    }
  }

  Future<void> signOut() async {
    _firebaseAuth.signOut();
  }
}
