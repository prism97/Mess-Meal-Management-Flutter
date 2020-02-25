import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/screens/budget_screen.dart';
import 'package:mess_meal/screens/login_screen.dart';
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
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Mess Meal',
                        style: Theme.of(context).textTheme.title,
                      ),
                    ],
                  ),
                ),
              ),
              NavitemTile(
                title: 'Check Meal',
                icon: FontAwesomeIcons.calendarCheck,
                onTap: () {
                  Navigator.pushReplacementNamed(context, MealCheckScreen.id);
                },
                selected: currentRoute == MealCheckScreen.id,
              ),
              NavitemTile(
                title: 'Today\'s Meal',
                icon: FontAwesomeIcons.clipboardList,
                onTap: () {
                  Navigator.pushReplacementNamed(context, MealListScreen.id);
                },
                selected: currentRoute == MealListScreen.id,
              ),
              NavitemTile(
                title: 'Budget',
                icon: FontAwesomeIcons.calculator,
                onTap: () {
                  Navigator.pushReplacementNamed(context, BudgetScreen.id);
                },
                selected: currentRoute == BudgetScreen.id,
              ),
              NavitemTile(
                title: 'Manager',
                icon: FontAwesomeIcons.userTie,
                onTap: () {
                  Navigator.pushReplacementNamed(context, ManagerScreen.id);
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
                    onTap: () {
                      _auth.logOut();
                      // Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, LoginScreen.id);
                      // TODO: logout not changing screen for normal users
                      // Navigator.popUntil(
                      // context, ModalRoute.withName(LoginScreen.id));
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
