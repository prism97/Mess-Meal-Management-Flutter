import 'package:flutter/material.dart';
import 'package:mess_meal/screens/admin_screen.dart';
import 'package:mess_meal/screens/meal_check_screen.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:mess_meal/services/database.dart';
import 'package:mess_meal/widgets/loading.dart';
import 'package:provider/provider.dart';

class ScreenSelector extends StatefulWidget {
  @override
  _ScreenSelectorState createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
  bool _loading = true;
  bool _isAdmin = false;
  List<String> _roles = [];

  Future<void> checkAdmin() async {
    final uid = await AuthService().getCurrentUserId();
    final db = DatabaseService(uid: uid);
    _roles = await db.userRoles;
    if (_roles.contains('admin')) {
      _isAdmin = true;
    }
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
    // TODO: fix provider so that every screen can access it
    return _loading
        ? Loading()
        : Provider<List<String>>(
            create: (context) => _roles,
            child: _isAdmin ? AdminScreen() : MealCheckScreen(),
          );
  }
}
