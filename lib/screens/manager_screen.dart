import 'package:flutter/material.dart';
import 'package:mess_meal/widgets/current_manager_card.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';

class ManagerScreen extends StatelessWidget {
  static const String id = 'manager_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(
        currentRoute: id,
      ),
      appBar: CustomAppBar(
        title: 'Manager',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CurrentManagerCard(),
          ],
        ),
      ),
    );
  }
}
