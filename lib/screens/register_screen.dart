import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
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

                                await db.createUser(user);
                                await auth.sendPasswordResetEmail(_email);
                                await auth.signOut();

                                // TODO: show success dialog

                                // if (!result) {
                                //   setState(() {
                                //     _loading = false;
                                //   });
                                //   showErrorSnackBar();
                                // }

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
}
