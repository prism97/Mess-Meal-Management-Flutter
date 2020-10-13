import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/screens/login_screen.dart';
import 'package:mess_meal/widgets/create_user_card.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatelessWidget {
  static const String id = 'admin_screen';

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: 'Admin'),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            topLeft: Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.shade100,
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.users),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.userCog),
                label: 'Manager',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.calculator),
                label: 'Budget',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.signOutAlt),
                label: 'Logout',
              ),
            ],
            onTap: (index) async {
              switch (index) {
                case 0:
                  break;
                case 1:
                  break;
                case 2:
                  break;
                case 3:
                  {
                    await _auth.signOut();
                    Navigator.popAndPushNamed(context, LoginScreen.id);
                    break;
                  }
              }
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CreateUserCard(),
          ],
        ),
      ),
    );
  }
}
