import 'package:flutter/material.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/signup_screen.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';

class StartScreen extends StatelessWidget {
  static const String id = 'start_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        decoration: BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Mess Meal',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title,
            ),
            SizedBox(
              height: 10.0,
            ),
            BasicWhiteButton(
              text: 'Login',
              destination: LoginScreen.id,
            ),
            BasicWhiteButton(
              text: 'Signup',
              destination: SignupScreen.id,
            ),
          ],
        ),
      ),
    );
  }
}
