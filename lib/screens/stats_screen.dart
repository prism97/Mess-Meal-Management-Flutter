import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';

class StatsScreen extends StatefulWidget {
  static const String id = 'stats_screen';

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _loading = true;
  int breakfast = 0;
  int lunch = 0;
  int dinner = 0;
  double totalMealAmount = 0.0;

  Future<void> fetchUserData() async {}

  @override
  void initState() {
    super.initState();
    fetchUserData().whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(title: 'User Statistics'),
      drawer: NavDrawer(currentRoute: StatsScreen.id),
      body: SingleChildScrollView(
        child: _loading
            ? SpinKitFadingCircle(
                color: accentColor,
                size: 50.0,
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Card(
                      elevation: kElevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text('Last 30 days'),
                          ListTile(
                            title: Text('Breakfasts taken'),
                            trailing: Text(breakfast.toString()),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Lunches taken'),
                            trailing: Text(lunch.toString()),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Dinners taken'),
                            trailing: Text(dinner.toString()),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Total meal amount'),
                            trailing: Text(totalMealAmount.toString()),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
