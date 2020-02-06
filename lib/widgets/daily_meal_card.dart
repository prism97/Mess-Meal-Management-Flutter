import 'package:flutter/material.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/services/database.dart';
import 'package:provider/provider.dart';

class DailyMealCard extends StatefulWidget {
  final DateTime date;
  final bool isDefault;

  DailyMealCard({this.date, this.isDefault = false});

  @override
  _DailyMealCardState createState() => _DailyMealCardState();
}

class _DailyMealCardState extends State<DailyMealCard> {
  Map<String, bool> mealChecks = {};

  void _onBreakfastChanged(bool newValue) {
    setState(() {
      mealChecks['breakfast'] = newValue;
    });
  }

  void _onLunchChanged(bool newValue) {
    setState(() {
      mealChecks['lunch'] = newValue;
    });
  }

  void _onDinnerChanged(bool newValue) {
    setState(() {
      mealChecks['dinner'] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    Map<String, bool> _currentDefaultMeal = {};

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _currentDefaultMeal = snapshot.data.defaultMeal;
        }

        return Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: Colors.white,
              elevation: kElevation,
              child: Column(
                children: <Widget>[
                  // Text(
                  //   widget.date.toIso8601String(),
                  // ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 20.0),
                    title: Text(
                      'Breakfast',
                      style: Theme.of(context).textTheme.body1,
                    ),
                    trailing: Switch(
                      inactiveThumbColor: Theme.of(context).primaryColorLight,
                      inactiveTrackColor: Theme.of(context).disabledColor,
                      value: (mealChecks['breakfast'] ??
                              _currentDefaultMeal['breakfast']) ??
                          true,
                      onChanged: _onBreakfastChanged,
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    indent: 10.0,
                    endIndent: 10.0,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 20.0),
                    title: Text(
                      'Lunch',
                      style: Theme.of(context).textTheme.body1,
                    ),
                    trailing: Switch(
                      inactiveThumbColor: Theme.of(context).primaryColorLight,
                      inactiveTrackColor: Theme.of(context).disabledColor,
                      value: (mealChecks['lunch'] ??
                              _currentDefaultMeal['lunch']) ??
                          true,
                      onChanged: _onLunchChanged,
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    indent: 10.0,
                    endIndent: 10.0,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 20.0),
                    title: Text(
                      'Dinner',
                      style: Theme.of(context).textTheme.body1,
                    ),
                    trailing: Switch(
                      inactiveThumbColor: Theme.of(context).primaryColorLight,
                      inactiveTrackColor: Theme.of(context).disabledColor,
                      value: (mealChecks['dinner'] ??
                              _currentDefaultMeal['dinner']) ??
                          true,
                      onChanged: _onDinnerChanged,
                    ),
                  ),
                ],
              ),
            ),
            RaisedButton(
              elevation: kElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              onPressed: () async {
                if (widget.isDefault) {
                  await DatabaseService(uid: user.uid).updateUserDefaultMeal(
                      mealChecks['breakfast'] ??
                          _currentDefaultMeal['breakfast'],
                      mealChecks['lunch'] ?? _currentDefaultMeal['lunch'],
                      mealChecks['dinner'] ?? _currentDefaultMeal['dinner']);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
