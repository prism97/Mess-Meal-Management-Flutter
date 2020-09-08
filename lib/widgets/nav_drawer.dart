import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/enums.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/manager_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/screens/stats_screen.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatelessWidget {
  final String currentRoute;

  NavDrawer({@required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: Provider.of<AuthProvider>(context).user,
      builder: (context, snapshot) {
        var role = snapshot.hasData ? snapshot.data.role : UserRole.Member;
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
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          snapshot.hasData
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data.name,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      snapshot.data.email,
                                      style: TextStyle(color: Colors.white60),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  NavitemTile(
                    title: 'Check Meal',
                    icon: FontAwesomeIcons.calendarCheck,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, MealCheckScreen.id);
                    },
                    selected: currentRoute == MealCheckScreen.id,
                  ),
                  role == UserRole.Manager
                      ? NavitemTile(
                          title: 'Today\'s Meal',
                          icon: FontAwesomeIcons.clipboardList,
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, MealListScreen.id);
                          },
                          selected: currentRoute == MealListScreen.id,
                        )
                      : Container(),
                  NavitemTile(
                    title: 'Manager',
                    icon: FontAwesomeIcons.userTie,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, ManagerScreen.id);
                    },
                    selected: currentRoute == ManagerScreen.id,
                  ),
                  NavitemTile(
                    title: 'Stats',
                    icon: FontAwesomeIcons.chartBar,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, StatsScreen.id);
                    },
                    selected: currentRoute == StatsScreen.id,
                  ),
                  Divider(),
                  Expanded(
                    child: Align(
                      alignment: FractionalOffset.bottomLeft,
                      child: NavitemTile(
                        icon: FontAwesomeIcons.signOutAlt,
                        title: 'Log Out',
                        onTap: () async {
                          await Provider.of<AuthProvider>(context,
                                  listen: false)
                              .signOut();

                          Navigator.popAndPushNamed(context, LoginScreen.id);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
