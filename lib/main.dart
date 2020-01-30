import 'package:flutter/material.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: MealCheckScreen.id,
      routes: {
        MealCheckScreen.id: (context) => MealCheckScreen(),
      },
    );
  }
}
