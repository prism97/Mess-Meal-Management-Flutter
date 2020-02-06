import 'package:flutter/material.dart';
import 'package:mess_meal/constants/custom_theme.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/screen_selector.dart';
import 'package:mess_meal/screens/budget_screen.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/manager_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/screens/signup_screen.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: ScreenSelector(),
        routes: {
          LoginScreen.id: (context) => LoginScreen(),
          SignupScreen.id: (context) => SignupScreen(),
          MealCheckScreen.id: (context) => MealCheckScreen(),
          MealListScreen.id: (context) => MealListScreen(),
          BudgetScreen.id: (context) => BudgetScreen(),
          ManagerScreen.id: (context) => ManagerScreen(),
        },
      ),
    );
  }
}
