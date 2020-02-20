import 'package:flutter/material.dart';
import 'package:mess_meal/screens/admin_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/screens/meal_list_screen.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:mess_meal/services/database.dart';
import 'package:mess_meal/widgets/loading.dart';

class ScreenSelector extends StatefulWidget {
  @override
  _ScreenSelectorState createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
  bool _loading = true;
  List<String> _roles = [];
  DatabaseService db;

  Future<void> checkAdmin() async {
    final uid = await AuthService().getCurrentUserId();
    db = DatabaseService(uid: uid);
    _roles = await db.userRoles;
  }

  @override
  void initState() {
    super.initState();
    checkAdmin().whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : (_roles.contains('admin')
            ? AdminScreen()
            : (_roles.contains('messboy')
                ? MealListScreen(
                    isMessboy: true,
                  )
                : MealCheckScreen()));
  }
}
