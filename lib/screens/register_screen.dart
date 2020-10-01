import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const String id = 'register_screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

// text field states
  String _name = '';

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context);
    final auth = Provider.of<AuthProvider>(context);
    final _email = auth.email;

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
                  children: [
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
                        hintText: 'display name',
                      ),
                      keyboardType: TextInputType.name,
                      validator: (val) => val == null
                          ? 'Enter a display name for your account'
                          : null,
                      onChanged: (val) {
                        setState(() => _name = val);
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
                            text: 'Save',
                            onPressed: () async {
                              FocusScope.of(context).unfocus();

                              final formState = _formKey.currentState;
                              if (formState.validate()) {
                                formState.save();
                                setState(() {
                                  _loading = true;
                                });
                                // create user document & send password reset email
                                final managerSerial =
                                    await db.updateManagerSerials();

                                final Member user = Member(
                                  uid: db.uid,
                                  email: _email,
                                  name: _name,
                                  managerSerial: managerSerial,
                                  defaultMeal: Meal(
                                    breakfast: true,
                                    lunch: true,
                                    dinner: true,
                                  ),
                                );

                                try {
                                  await db.createUser(user);
                                  await auth.sendPasswordResetEmail(_email);
                                  await auth.signOut();

                                  EasyDialog(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    title: Text('Success'),
                                    description: Text(
                                        'An e-mail has been sent to your e-mail address. Follow the directions in the e-mail to reset your password & then login with your new password.'),
                                  ).show(context);
                                } catch (error) {
                                  setState(() {
                                    _loading = false;
                                  });
                                  showErrorSnackBar();
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
  }

  void showErrorSnackBar() {
    final snackBar = SnackBar(
      content: Text(
        'Failed to register and send password reset e-mail! Please try again later.',
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
}
