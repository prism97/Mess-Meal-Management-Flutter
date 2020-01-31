import 'package:flutter/material.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';

class MealListScreen extends StatelessWidget {
  static const String id = 'meal_list_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(
        currentRoute: id,
      ),
      appBar: AppBar(),
      body: Container(),
    );
  }
}
