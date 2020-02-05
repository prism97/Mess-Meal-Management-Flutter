import 'package:flutter/material.dart';
import 'package:mess_meal/screens/budget_screen.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/manager_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/screens/signup_screen.dart';
import 'package:mess_meal/screens/start_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primaryColorDark: Colors.purple.shade900,
        primaryColorLight: Colors.purple.shade600,
        accentColor: Colors.purple,
        disabledColor: Colors.purple.shade100,
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
          body1: TextStyle(
            color: Colors.purple.shade900,
            fontSize: 16.0,
          ),
          body2: TextStyle(
            color: Colors.purple.shade600,
            fontSize: 16.0,
          ),
          display1: TextStyle(
            color: Colors.purple.shade900,
            fontSize: 15.0,
          ),
          display2: TextStyle(
            color: Colors.purple.shade600,
            fontSize: 15.0,
          ),
        ),
      ),
      initialRoute: StartScreen.id,
      routes: {
        StartScreen.id: (context) => StartScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        SignupScreen.id: (context) => SignupScreen(),
        MealCheckScreen.id: (context) => MealCheckScreen(),
        MealListScreen.id: (context) => MealListScreen(),
        BudgetScreen.id: (context) => BudgetScreen(),
        ManagerScreen.id: (context) => ManagerScreen(),
      },
    );
  }
}
