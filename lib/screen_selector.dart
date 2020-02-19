import 'package:flutter/material.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/screens/admin_screen.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/services/database.dart';
import 'package:provider/provider.dart';

class ScreenSelector extends StatelessWidget {
  // Future<Widget> adminCheck(String uid) async {
  //   final db = DatabaseService(uid: uid);
  //   final userRoles = await db.userRoles;
  //   final _admin = userRoles.contains('admin');
  //   if (_admin) {
  //     return AdminScreen();
  //   } else {
  //     return MealCheckScreen();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return LoginScreen();
    } else {
      final db = DatabaseService(uid: user.uid);
      return FutureProvider<List<String>>(
        initialData: [],
        create: (context) => db.userRoles,
        child: MealCheckScreen(),
      );
    }
  }
}
