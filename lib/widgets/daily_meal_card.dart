import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:mess_meal/services/database.dart';

class DailyMealCard extends StatefulWidget {
  final DateTime date;
  final bool isDefault;

  DailyMealCard({this.date, this.isDefault = false});

  @override
  _DailyMealCardState createState() => _DailyMealCardState();
}

class _DailyMealCardState extends State<DailyMealCard> {
  Map<String, bool> mealChecks;
  bool mealExists;
  DatabaseService db;
  bool _loading = true;

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

  Future<void> fetchMeal() async {
    final String _uid = await AuthService().getCurrentUserId();
    db = DatabaseService(uid: _uid);
    if (!widget.isDefault) {
      final result = await db.getMealData(widget.date);
      if (result != null) {
        setState(() {
          mealChecks['breakfast'] = result.meal['breakfast'];
          mealChecks['lunch'] = result.meal['lunch'];
          mealChecks['dinner'] = result.meal['dinner'];
          mealExists = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    mealChecks = {};
    mealExists = false;
    fetchMeal().whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void didUpdateWidget(DailyMealCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    mealChecks = {};
    mealExists = false;
    if (!widget.isDefault) {
      setState(() {
        _loading = true;
      });
    }

    fetchMeal().whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, bool> _currentDefaultMeal = {};

    DateTime now = DateTime.now();
    DateTime breakfastTime = DateTime(
      now.year,
      now.month,
      now.day,
      6,
    );
    DateTime lunchDinnerTime = DateTime(
      now.year,
      now.month,
      now.day,
      9,
    );
    bool breakfastChangeNotAllowed = !widget.isDefault &&
        now.day == widget.date.day &&
        now.isAfter(breakfastTime);

    bool lunchDinnerChangeNotAllowed = !widget.isDefault &&
        now.day == widget.date.day &&
        now.isAfter(lunchDinnerTime);

    return _loading
        ? Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: SpinKitCircle(
              color: primaryColorDark,
              size: 50.0,
            ),
          )
        : StreamBuilder<UserData>(
            stream: db.userData,
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
                        Text(!widget.isDefault ? widget.date.toString() : ''),
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 20.0),
                          title: Text(
                            'Breakfast',
                            style: Theme.of(context).textTheme.body1,
                          ),
                          trailing: Switch(
                            inactiveThumbColor:
                                Theme.of(context).primaryColorLight,
                            inactiveTrackColor: Theme.of(context).disabledColor,
                            value: mealExists
                                ? mealChecks['breakfast']
                                : ((mealChecks['breakfast'] ??
                                        _currentDefaultMeal['breakfast']) ??
                                    true),
                            onChanged: breakfastChangeNotAllowed
                                ? null
                                : _onBreakfastChanged,
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
                            inactiveThumbColor:
                                Theme.of(context).primaryColorLight,
                            inactiveTrackColor: Theme.of(context).disabledColor,
                            value: mealExists
                                ? mealChecks['lunch']
                                : ((mealChecks['lunch'] ??
                                        _currentDefaultMeal['lunch']) ??
                                    true),
                            onChanged: lunchDinnerChangeNotAllowed
                                ? null
                                : _onLunchChanged,
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
                            inactiveThumbColor:
                                Theme.of(context).primaryColorLight,
                            inactiveTrackColor: Theme.of(context).disabledColor,
                            value: mealExists
                                ? mealChecks['dinner']
                                : ((mealChecks['dinner'] ??
                                        _currentDefaultMeal['dinner']) ??
                                    false),
                            onChanged: lunchDinnerChangeNotAllowed
                                ? null
                                : _onDinnerChanged,
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
                        await db.updateUserDefaultMeal(
                            mealChecks['breakfast'] ??
                                _currentDefaultMeal['breakfast'],
                            mealChecks['lunch'] ?? _currentDefaultMeal['lunch'],
                            mealChecks['dinner'] ??
                                _currentDefaultMeal['dinner']);
                        Navigator.pop(context);
                      } else {
                        if (!mealExists) {
                          await db.createNewMealData(
                              widget.date,
                              mealChecks['breakfast'] ??
                                  _currentDefaultMeal['breakfast'],
                              mealChecks['lunch'] ??
                                  _currentDefaultMeal['lunch'],
                              mealChecks['dinner'] ??
                                  _currentDefaultMeal['dinner']);
                        } else {
                          await db.updateMealData(
                              widget.date,
                              mealChecks['breakfast'] ??
                                  _currentDefaultMeal['breakfast'],
                              mealChecks['lunch'] ??
                                  _currentDefaultMeal['lunch'],
                              mealChecks['dinner'] ??
                                  _currentDefaultMeal['dinner']);
                        }
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
