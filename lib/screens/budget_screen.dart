import 'package:flutter/material.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';

class BudgetScreen extends StatelessWidget {
  static const String id = 'budget_screen';

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
