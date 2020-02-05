import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  static const String id = 'signup_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Mess Meal',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body1,
            ),
            SizedBox(
              height: 10.0,
            ),
            TextField(),
            TextField(),
          ],
        ),
      ),
    );
  }
}
