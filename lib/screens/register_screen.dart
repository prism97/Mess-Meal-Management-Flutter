import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/enums.dart';
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
  bool _loading = false;
  FirestoreDatabase db;
  AuthProvider auth;

// text field states
  String _name = '';
  String _teacherId = '';
  Department _department;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    auth = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final _email = auth.email;

    return Scaffold(
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
              SizedBox(
                height: 10,
              ),
              Text(
                'Please provide the following information to activate your account',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: Colors.purple.shade100),
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
                    _buildNameField(context),
                    SizedBox(
                      height: 20.0,
                    ),
                    _buildTeacherIdField(context),
                    SizedBox(
                      height: 20.0,
                    ),
                    _buildDepartmentField(),
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
                        : _buildSaveButton(context, _email),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BasicWhiteButton _buildSaveButton(BuildContext context, String _email) {
    return BasicWhiteButton(
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
          final managerSerial = await db.updateManagerSerials();

          final Member user = Member(
            uid: db.uid,
            email: _email,
            name: _name + ', ' + _department.toString().substring(11),
            teacherId: _teacherId,
            managerSerial: managerSerial,
            isDeleted: false,
            defaultMeal: Meal(
              breakfast: false,
              lunch: false,
              dinner: false,
              date: DateTime.now(),
            ),
          );

          try {
            await db.createUser(user);
            await auth.sendPasswordResetEmail(_email);
            await auth.signOut();

            EasyDialog(
              height: MediaQuery.of(context).size.height / 2,
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
    );
  }

  DropdownButtonFormField<Department> _buildDepartmentField() {
    return DropdownButtonFormField<Department>(
      items: Department.values
          .map(
            (e) => DropdownMenuItem<Department>(
              value: e,
              child: Text(
                e.toString().substring(11),
              ),
            ),
          )
          .toList(),
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          FontAwesomeIcons.building,
          color: Theme.of(context).disabledColor,
        ),
        hintText: 'department',
      ),
      iconEnabledColor: Theme.of(context).disabledColor,
      dropdownColor: accentColor.shade400,
      onChanged: (val) {
        setState(() {
          _department = val;
        });
      },
      validator: (val) => val == null ? 'This field is required' : null,
    );
  }

  TextFormField _buildTeacherIdField(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          FontAwesomeIcons.idCard,
          color: Theme.of(context).disabledColor,
        ),
        hintText: 'teacher id',
      ),
      keyboardType: TextInputType.name,
      validator: (val) =>
          val == null || val.isEmpty ? 'This field is required' : null,
      onChanged: (val) {
        setState(() => _teacherId = val);
      },
    );
  }

  TextFormField _buildNameField(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          FontAwesomeIcons.userCircle,
          color: Theme.of(context).disabledColor,
        ),
        hintText: 'display name',
      ),
      keyboardType: TextInputType.name,
      validator: (val) =>
          val == null || val.isEmpty ? 'This field is required' : null,
      onChanged: (val) {
        setState(() => _name = val);
      },
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
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
