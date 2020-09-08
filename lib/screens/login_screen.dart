import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/enums.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/screens/admin_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  // text field states
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                gradient: kBackgroundGradient,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Mess Meal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
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
                        _loading
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SpinKitThreeBounce(
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              )
                            : BasicWhiteButton(
                                text: 'Login',
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();

                                  final formState = _formKey.currentState;
                                  if (formState.validate()) {
                                    formState.save();
                                    setState(() {
                                      _loading = true;
                                    });
                                    final result =
                                        await auth.signInWithEmailAndPassword(
                                            _email, _password);

                                    if (result == null) {
                                      setState(() {
                                        _loading = false;
                                      });
                                      showErrorSnackBar();
                                    } else {
                                      final user = await auth.user.first;
                                      navigateBasedOnUserRole(user.role);
                                    }
                                  }
                                },
                              ),
                      ],
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

  void showErrorSnackBar() {
    final snackBar = SnackBar(
      content: Text(
        'Login failed! Invalid credentials.',
        style: Theme.of(context).textTheme.bodyText1,
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

  void navigateBasedOnUserRole(UserRole role) {
    print(role);
    if (role == UserRole.Admin) {
      Navigator.pushReplacementNamed(context, AdminScreen.id);
    } else if (role == UserRole.Messboy) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MealListScreen(
            isMessboy: true,
          ),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, MealCheckScreen.id);
    }
  }
}
