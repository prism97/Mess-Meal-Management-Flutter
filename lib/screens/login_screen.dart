import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
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
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
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
                    validator: (val) => !EmailValidator.validate(_email)
                        ? 'Enter a valid email address'
                        : null,
                    onChanged: (val) {
                      setState(() => _email = val);
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
                      setState(() => _password = val);
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  BasicWhiteButton(
                    text: 'Login',
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      final formState = _formKey.currentState;
                      if (formState.validate()) {
                        formState.save();
                        final result = await _auth.logIn(_email, _password);
                        if (result == null) {
                          final snackBar = SnackBar(
                            content: Text(
                              'Login failed! Invalid credentials.',
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
                  'Don\'t have an account?',
                  style: TextStyle(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
