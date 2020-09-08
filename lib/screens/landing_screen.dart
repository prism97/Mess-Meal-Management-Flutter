import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/enums.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatelessWidget {
  static const String id = 'landing_screen';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthStatus>(
      stream: Provider.of<AuthProvider>(context).status,
      builder: (context, snapshot) {
        var status = snapshot.data;

        if (status == AuthStatus.Unauthenticated) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, LoginScreen.id);
          });
        } else if (status == AuthStatus.Authenticated) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, MealCheckScreen.id);
          });
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
