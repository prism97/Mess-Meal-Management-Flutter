import 'package:flutter/material.dart';
import 'package:mess_meal/constants/enums.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/screens/register_screen.dart';
import 'package:mess_meal/screens/splash_screen.dart';
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
          return LoginScreen();
        } else if (status == AuthStatus.Unregistered) {
          return RegisterScreen();
        } else if (status == AuthStatus.Authenticated) {
          return MealCheckScreen();
        } else if (status == AuthStatus.AuthenticatedAsMessboy) {
          return MealListScreen(
            isMessboy: true,
          );
        }
        return SplashScreen();
      },
    );
  }
}
