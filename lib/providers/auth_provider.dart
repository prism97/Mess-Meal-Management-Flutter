import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_meal/constants/enums.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/member.dart';

class AuthProvider extends ChangeNotifier {
  //Firebase Auth object
  FirebaseAuth _auth;
  String _uid;
  String _email;

  //Default status
  AuthStatus _status = AuthStatus.Uninitialized;

  Stream<AuthStatus> get status => Stream.value(_status);

  String get uid => _uid;

  String get email => _email;

  Stream<Member> get user =>
      _auth.authStateChanges().asyncMap(_userFromFirebase);

  AuthProvider() {
    //initialise object
    _auth = FirebaseAuth.instance;

    //listener for authentication changes such as user sign in and sign out
    _auth.authStateChanges().listen(onAuthStateChanged);
  }

  //Create member object based on the given FirebaseUser
  Future<Member> _userFromFirebase(User firebaseUser) async {
    if (firebaseUser == null) {
      return null;
    }

    final userDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!userDocument.exists) {
      _status = AuthStatus.Unregistered;
      return null;
    }

    _status = AuthStatus.Authenticated;
    final user = userDocument.data();
    return Member(
      uid: user[userDocument.id],
      email: user['email'],
      name: user['name'],
      managerSerial: user['managerSerial'],
      isConvener: user['isConvener'],
      defaultMeal: Meal.fromMap(Map<String, bool>.from(user['defaultMeal'])),
    );
  }

  //Method to detect live auth changes such as user sign in and sign out
  Future<void> onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _uid = null;
      _email = null;
      _status = AuthStatus.Unauthenticated;
    } else {
      _uid = firebaseUser.uid;
      _email = firebaseUser.email;
      await _userFromFirebase(firebaseUser);
    }
    print('auth change $_status');
    notifyListeners();
  }

  //Method to handle user sign in using email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("Error on the sign in = " + e.toString());
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  //Method to handle password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  //Method to handle user signing out
  Future signOut() async {
    _auth.signOut();
    _status = AuthStatus.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }
}
