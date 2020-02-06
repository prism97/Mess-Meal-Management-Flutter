import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/screens/budget_screen.dart';
import 'package:mess_meal/screens/manager_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/services/auth.dart';

class NavDrawer extends StatelessWidget {
  final String currentRoute;
  final _auth = AuthService();

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
                  gradient: kBackgroundGradient,
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
                onTap: () {
                  Navigator.pushNamed(context, MealCheckScreen.id);
                },
                selected: currentRoute == MealCheckScreen.id,
              ),
              NavitemTile(
                title: 'Meal List',
                icon: FontAwesomeIcons.clipboardList,
                onTap: () {
                  Navigator.pushNamed(context, MealListScreen.id);
                },
                selected: currentRoute == MealListScreen.id,
              ),
              NavitemTile(
                title: 'Budget',
                icon: FontAwesomeIcons.calculator,
                onTap: () {
                  Navigator.pushNamed(context, BudgetScreen.id);
                },
                selected: currentRoute == BudgetScreen.id,
              ),
              NavitemTile(
                title: 'Manager',
                icon: FontAwesomeIcons.userTie,
                onTap: () {
                  Navigator.pushNamed(context, ManagerScreen.id);
                },
                selected: currentRoute == ManagerScreen.id,
              ),
              Divider(),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomLeft,
                  child: NavitemTile(
                    icon: FontAwesomeIcons.signOutAlt,
                    title: 'Log Out',
                    onTap: () async {
                      Navigator.pop(context);
                      await _auth.logOut();
                    },
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
  final Function onTap;
  final bool selected;

  NavitemTile(
      {@required this.title,
      @required this.icon,
      @required this.onTap,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      iconColor: Theme.of(context).primaryColorDark,
      textColor: Theme.of(context).primaryColorDark,
      selectedColor: Theme.of(context).primaryColorLight,
      style: ListTileStyle.drawer,
      child: ListTile(
        selected: selected,
        leading: Icon(
          icon,
        ),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
