import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/screens/funds_screen.dart';
import 'package:mess_meal/screens/landing_screen.dart';
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
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return StreamBuilder<Member>(
      stream: auth.user,
      builder: (context, snapshot) {
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
                      Navigator.popUntil(
                          context, ModalRoute.withName(LandingScreen.id));
                      Navigator.pushNamed(context, MealCheckScreen.id);
                    },
                    selected: currentRoute == MealCheckScreen.id,
                  ),
                  snapshot.hasData && snapshot.data.isManager()
                      ? NavitemTile(
                          title: 'Today\'s Meal',
                          icon: FontAwesomeIcons.clipboardList,
                          onTap: () {
                            Navigator.popUntil(
                                context, ModalRoute.withName(LandingScreen.id));
                            Navigator.pushNamed(context, MealListScreen.id);
                          },
                          selected: currentRoute == MealListScreen.id,
                        )
                      : Container(),
                  NavitemTile(
                    title: 'Manager',
                    icon: FontAwesomeIcons.userTie,
                    onTap: () {
                      Navigator.popUntil(
                          context, ModalRoute.withName(LandingScreen.id));
                      Navigator.pushNamed(context, ManagerScreen.id);
                    },
                    selected: currentRoute == ManagerScreen.id,
                  ),
                  NavitemTile(
                    title: 'Funds',
                    icon: FontAwesomeIcons.dollarSign,
                    onTap: () {
                      Navigator.popUntil(
                          context, ModalRoute.withName(LandingScreen.id));
                      Navigator.pushNamed(context, FundsScreen.id);
                    },
                  ),
                  NavitemTile(
                    title: 'Stats',
                    icon: FontAwesomeIcons.chartBar,
                    onTap: () {
                      Navigator.popUntil(
                          context, ModalRoute.withName(LandingScreen.id));
                      Navigator.pushNamed(context, StatsScreen.id);
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
                        onTap: () {
                          Navigator.popUntil(
                              context, ModalRoute.withName(LandingScreen.id));
                          auth.signOut();
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
