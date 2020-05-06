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

  // log in with email and password
  Future<User> logIn(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      DatabaseService db = DatabaseService(uid: user.uid);
      await db.checkRoles();
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // log out
  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
