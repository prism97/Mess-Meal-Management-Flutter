import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:mess_meal/services/database.dart';

class LandingScreen extends StatefulWidget {
  static const String id = 'landing_screen';

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Future<void> _getHomeScreen(BuildContext context, String uid) async {
    DatabaseService db = DatabaseService(uid: uid);
    await db.checkRoles();
    if (DatabaseService.isMessboy) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MealListScreen(isMessboy: true)),
      );
    } else {
      Navigator.pushReplacementNamed(context, MealCheckScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: AuthService().user.timeout(Duration(seconds: 5),
          onTimeout: (eventSink) {
        eventSink.close();
        Navigator.of(context).pushReplacementNamed(LoginScreen.id);
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final uid = snapshot.data.uid;
          _getHomeScreen(context, uid);
        }
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: kBackgroundGradient,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitWave(
                  color: Colors.white,
                  size: 40.0,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  'Mess Meal',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
