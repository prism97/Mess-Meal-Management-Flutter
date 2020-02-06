import 'package:mess_meal/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  final AuthService _auth = AuthService();

  void storeUser(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
  }

  Future logUserIntoFirebase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');
    String password = prefs.getString('password');
    // if (email )
    return _auth.logIn(email, password);
  }

  void removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
  }
}
