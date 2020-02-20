import 'package:flutter/material.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';
import 'package:mess_meal/widgets/create_user_card.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';

class AdminScreen extends StatelessWidget {
  static const String id = 'admin_screen';
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: 'Admin'),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CreateUserCard(),
            BasicWhiteButton(
              text: 'Logout',
              onPressed: () {
                _auth.logOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
