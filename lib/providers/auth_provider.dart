import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_meal/constants/enums.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/user.dart';

class AuthProvider extends ChangeNotifier {
  //Firebase Auth object
  FirebaseAuth _auth;
  String _uid;

  //Default status
  AuthStatus _status = AuthStatus.Uninitialized;

  Stream<AuthStatus> get status => Stream.value(_status);

  String get uid => _uid;

  Stream<User> get user => _auth.onAuthStateChanged.asyncMap(_userFromFirebase);

  AuthProvider() {
    //initialise object
    _auth = FirebaseAuth.instance;

    //listener for authentication changes such as user sign in and sign out
    _auth.onAuthStateChanged.listen(onAuthStateChanged);
  }

  //Create user object based on the given FirebaseUser
  Future<User> _userFromFirebase(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      return null;
    }

    final userDocument = await Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .get();
    if (userDocument == null) {
      _status = AuthStatus.Unregistered;
      return null;
    }

    _status = AuthStatus.Authenticated;
    final user = userDocument.data;
    return User(
      uid: user[userDocument.documentID],
      email: user['email'],
      name: user['name'],
      managerSerial: user['managerSerial'],
      isConvener: user['isConvener'],
      defaultMeal: Meal.fromMap(user['defaultMeal']),
    );
  }

  //Method to detect live auth changes such as user sign in and sign out
  Future<void> onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _uid = null;
      _status = AuthStatus.Unauthenticated;
    } else {
      _uid = firebaseUser.uid;
      _userFromFirebase(firebaseUser);
    }
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
