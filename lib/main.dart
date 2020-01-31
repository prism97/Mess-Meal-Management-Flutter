import 'package:flutter/material.dart';
import 'package:mess_meal/screens/budget_screen.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/manager_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';

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
      ),
      initialRoute: MealCheckScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        MealCheckScreen.id: (context) => MealCheckScreen(),
        MealListScreen.id: (context) => MealListScreen(),
        BudgetScreen.id: (context) => BudgetScreen(),
        ManagerScreen.id: (context) => ManagerScreen(),
      },
    );
  }
}
