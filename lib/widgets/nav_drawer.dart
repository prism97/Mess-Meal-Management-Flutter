import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/screens/budget_screen.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/manager_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';

class NavDrawer extends StatelessWidget {
  final String currentRoute;

  NavDrawer({@required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColorDark,
                      Theme.of(context).primaryColorLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  child: Text(
                    'Mess Meal',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              NavitemTile(
                title: 'Daily Meal',
                icon: FontAwesomeIcons.calendarCheck,
                route: MealCheckScreen.id,
                selected: currentRoute == MealCheckScreen.id,
              ),
              NavitemTile(
                title: 'Meal List',
                icon: FontAwesomeIcons.clipboardList,
                route: MealListScreen.id,
                selected: currentRoute == MealListScreen.id,
              ),
              NavitemTile(
                title: 'Budget',
                icon: FontAwesomeIcons.calculator,
                route: BudgetScreen.id,
                selected: currentRoute == BudgetScreen.id,
              ),
              NavitemTile(
                title: 'Manager',
                icon: FontAwesomeIcons.userTie,
                route: ManagerScreen.id,
                selected: currentRoute == ManagerScreen.id,
              ),
              Divider(),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomLeft,
                  child: NavitemTile(
                    icon: FontAwesomeIcons.signOutAlt,
                    title: 'Log Out',
                    route: LoginScreen.id,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavitemTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final bool selected;

  NavitemTile(
      {@required this.title,
      @required this.icon,
      @required this.route,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      leading: Icon(
        icon,
      ),
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
