import 'package:flutter/material.dart';
import 'package:mess_meal/widgets/current_manager_card.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/egg_price_card.dart';
import 'package:mess_meal/widgets/manager_cost_card.dart';
import 'package:mess_meal/widgets/manager_list_card.dart';
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
            ManagerCostCard(),
            EggPriceCard(),
            CurrentManagerCard(),
            ManagerListCard(
              start: 1,
              end: 6,
            ),
          ],
        ),
      ),
    );
  }
}
