import 'package:flutter/material.dart';
import 'package:mess_meal/constants/custom_theme.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/screen_selector.dart';
import 'package:mess_meal/screens/admin_screen.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/manager_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/services/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget _getHomeScreen() {
    return StreamBuilder<User>(
      stream: AuthService().user,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ScreenSelector();
        } else {
          return LoginScreen();
        }
      },
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: _getHomeScreen(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        MealCheckScreen.id: (context) => MealCheckScreen(),
        MealListScreen.id: (context) => MealListScreen(),
        ManagerScreen.id: (context) => ManagerScreen(),
        AdminScreen.id: (context) => AdminScreen(),
      },
    );
  }
}
