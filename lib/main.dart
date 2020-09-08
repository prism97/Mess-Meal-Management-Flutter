import 'package:flutter/material.dart';
import 'package:mess_meal/constants/custom_theme.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/screens/admin_screen.dart';
import 'package:mess_meal/screens/landing_screen.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/manager_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/screens/stats_screen.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static final AuthProvider authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData,
        routes: {
          LandingScreen.id: (context) => LandingScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          MealCheckScreen.id: (context) => MealCheckScreen(),
          MealListScreen.id: (context) => MealListScreen(),
          ManagerScreen.id: (context) => ManagerScreen(),
          AdminScreen.id: (context) => AdminScreen(),
          StatsScreen.id: (context) => StatsScreen(),
        },
        initialRoute: LandingScreen.id,
      ),
    );
  }
}
