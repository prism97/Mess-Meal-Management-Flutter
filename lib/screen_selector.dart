import 'package:flutter/material.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:provider/provider.dart';

class ScreenSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return LoginScreen();
    } else {
      return MealCheckScreen();
    }
  }
}
