import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';

class SignupScreen extends StatefulWidget {
  static const String id = 'signup_screen';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // text field states
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Container(
        padding: EdgeInsets.only(
          top: 150.0,
          bottom: 20.0,
          left: 20.0,
          right: 20.0,
        ),
        decoration: BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Mess Meal',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title,
            ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 40.0,
                  ),
                  TextFormField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        FontAwesomeIcons.solidEnvelope,
                        color: Theme.of(context).disabledColor,
                      ),
                      hintText: 'email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => !EmailValidator.validate(email)
                        ? 'Enter a valid email address'
                        : null,
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    obscureText: true,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        FontAwesomeIcons.lock,
                        color: Theme.of(context).disabledColor,
                      ),
                      hintText: 'password',
                    ),
                    validator: (val) => val.length < 6
                        ? 'Enter a password at least 6 characters long'
                        : null,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  BasicWhiteButton(
                    text: 'Signup',
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        dynamic result = await _auth.signUp(email, password);
                        if (result == null) {
                          final snackBar = SnackBar(
                            content: Text(
                              'Signup failed! Please provide valid input.',
                              style: Theme.of(context).textTheme.body1,
                            ),
                            backgroundColor: Theme.of(context).disabledColor,
                            elevation: kElevation,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(kBorderRadius),
                                topRight: Radius.circular(kBorderRadius),
                              ),
                            ),
                          );
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                        } else {
                          Navigator.popAndPushNamed(
                              context, MealCheckScreen.id);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                RawMaterialButton(
                  child: Text(
                    'Log In!',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.popAndPushNamed(context, LoginScreen.id);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
