import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/services/auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({@required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.body1,
          ),
          // actions: <Widget>[
          //   RawMaterialButton(
          //     child: Icon(FontAwesomeIcons.signOutAlt),
          //     onPressed: () {
          //       AuthService().logOut();
          //       Navigator.pushReplacementNamed(context, LoginScreen.id);
          //     },
          //   ),
          // ],
          elevation: kElevation,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.0);
}
