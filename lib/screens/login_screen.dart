import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/screens/signup_screen.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                    text: 'Login',
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        dynamic result = await _auth.logIn(email, password);
                        if (result == null) {
                          final snackBar = SnackBar(
                            content: Text(
                                'Login failed! Please provide valid input.'),
                          );
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Don\'t have an account?',
                      style: TextStyle(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    RawMaterialButton(
                      child: Text(
                        'Sign Up!',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.popAndPushNamed(context, SignupScreen.id);
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
