import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create User object from FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid, email: user.email) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // get current user's uid
  Future<String> getCurrentUserId() async {
    final _user = await _auth.currentUser();
    return _user.uid;
  }

  // get current user's email
  Future<String> getCurrentUserEmail() async {
    final _user = await _auth.currentUser();
    return _user.email;
  }

  // sign up with email and password
  // Future signUp(String email, String password) async {
  //   try {
  //     AuthResult result = await _auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     FirebaseUser user = result.user;

  //     // await DatabaseService(uid: user.uid).createUserData();
  //     return _userFromFirebaseUser(user);
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  // log in with email and password
  Future logIn(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      DatabaseService.isManager();
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // log out
  Future logOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
