import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/database.dart';
import 'package:provider/provider.dart';

class OldDailyMealCard extends StatefulWidget {
  final DateTime date;
  final bool isDefault;

  OldDailyMealCard({this.date, this.isDefault = false});

  @override
  _DailyMealCardState createState() => _DailyMealCardState();
}

class _DailyMealCardState extends State<OldDailyMealCard> {
  Map<String, bool> mealChecks;
  Map<String, num> mealAmounts;
  bool mealExists;
  bool mealUpdated;
  bool mealAmountExists;
  bool mealAmountUpdated;
  DatabaseService db;
  bool _loading = true;
  bool _saveLoading = false;

  void _onBreakfastChanged(bool newValue) {
    mealUpdated = true;
    setState(() {
      mealChecks['breakfast'] = newValue;
    });
  }

  void _onLunchChanged(bool newValue) {
    mealUpdated = true;
    setState(() {
      mealChecks['lunch'] = newValue;
    });
  }

  void _onDinnerChanged(bool newValue) {
    mealUpdated = true;
    setState(() {
      mealChecks['dinner'] = newValue;
    });
  }

  Future<void> fetchMeal() async {
    final String _uid = '1';
    db = DatabaseService(uid: _uid);
    if (!widget.isDefault) {
      final resultData = await db.getMealData(widget.date);
      if (resultData != null) {
        mealChecks['breakfast'] = resultData['breakfast'];
        mealChecks['lunch'] = resultData['lunch'];
        mealChecks['dinner'] = resultData['dinner'];
        mealExists = true;
      }
      final resultAmount = await db.getMealAmount(widget.date);
      if (resultAmount != null) {
        mealAmounts['breakfast'] = resultAmount['breakfast'];
        mealAmounts['lunch'] = resultAmount['lunch'];
        mealAmounts['dinner'] = resultAmount['dinner'];
        mealAmountExists = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    mealChecks = {};
    mealExists = false;
    mealUpdated = false;
    mealAmounts = {
      'breakfast': 0.5,
      'lunch': (!widget.isDefault && widget.date.weekday == 5) ? 2.5 : 1.0,
      'dinner': (!widget.isDefault && widget.date.weekday == 2) ? 1.5 : 1.0,
    };
    mealAmountExists = false;
    mealAmountUpdated = false;
    fetchMeal().whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void didUpdateWidget(OldDailyMealCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    mealChecks = {};
    mealExists = false;
    mealUpdated = false;
    mealAmounts = {
      'breakfast': 0.5,
      'lunch': (!widget.isDefault && widget.date.weekday == 5) ? 2.5 : 1.0,
      'dinner': (!widget.isDefault && widget.date.weekday == 2) ? 1.5 : 1.0,
    };
    mealAmountExists = false;
    mealAmountUpdated = false;
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
    DateTime updateTime = widget.isDefault
        ? DateTime.now()
        : DateTime(
            widget.date.year,
            widget.date.month,
            widget.date.day,
            6,
          );
    bool changeNotAllowed = !widget.isDefault && now.isAfter(updateTime);

    return _loading
        ? Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: SpinKitCircle(
              color: primaryColorDark,
              size: 50.0,
            ),
          )
        : StreamBuilder<Member>(
            stream: Provider.of<AuthProvider>(context).user,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _currentDefaultMeal = snapshot.data.defaultMeal.toMap();
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 20.0),
                            title: Text(
                              'Breakfast',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            subtitle: widget.isDefault
                                ? null
                                : (DatabaseService.isManager &&
                                        !changeNotAllowed)
                                    ? Wrap(
                                        children: kMealAmounts
                                            .map(
                                              (amt) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 4.0,
                                                ),
                                                child: ChoiceChip(
                                                  label: Text(
                                                    amt.toString(),
                                                  ),
                                                  selected: amt ==
                                                          mealAmounts[
                                                              'breakfast']
                                                      ? true
                                                      : false,
                                                  onSelected: (bool selected) {
                                                    if (selected) {
                                                      setState(() {
                                                        mealAmounts[
                                                            'breakfast'] = amt;
                                                        mealAmountUpdated =
                                                            true;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      )
                                    : Align(
                                        alignment: Alignment.topLeft,
                                        child: Chip(
                                          label: Text(
                                            mealAmounts['breakfast']
                                                .toDouble()
                                                .toString(),
                                          ),
                                        ),
                                      ),
                            trailing: Switch(
                              inactiveThumbColor:
                                  Theme.of(context).primaryColorLight,
                              inactiveTrackColor:
                                  Theme.of(context).disabledColor,
                              value: mealExists
                                  ? mealChecks['breakfast']
                                  : ((mealChecks['breakfast'] ??
                                          _currentDefaultMeal['breakfast']) ??
                                      true),
                              onChanged:
                                  changeNotAllowed ? null : _onBreakfastChanged,
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
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            subtitle: widget.isDefault
                                ? null
                                : (DatabaseService.isManager &&
                                        !changeNotAllowed)
                                    ? Wrap(
                                        children: kMealAmounts
                                            .map(
                                              (amt) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 4.0,
                                                ),
                                                child: ChoiceChip(
                                                  label: Text(
                                                    amt.toString(),
                                                  ),
                                                  selected: amt ==
                                                          mealAmounts['lunch']
                                                      ? true
                                                      : false,
                                                  onSelected: (bool selected) {
                                                    if (selected) {
                                                      setState(() {
                                                        mealAmounts['lunch'] =
                                                            amt;
                                                        mealAmountUpdated =
                                                            true;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      )
                                    : Align(
                                        alignment: Alignment.topLeft,
                                        child: Chip(
                                          label: Text(
                                            mealAmounts['lunch']
                                                .toDouble()
                                                .toString(),
                                          ),
                                        ),
                                      ),
                            trailing: Switch(
                              inactiveThumbColor:
                                  Theme.of(context).primaryColorLight,
                              inactiveTrackColor:
                                  Theme.of(context).disabledColor,
                              value: mealExists
                                  ? mealChecks['lunch']
                                  : ((mealChecks['lunch'] ??
                                          _currentDefaultMeal['lunch']) ??
                                      true),
                              onChanged:
                                  changeNotAllowed ? null : _onLunchChanged,
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
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            subtitle: widget.isDefault
                                ? null
                                : (DatabaseService.isManager &&
                                        !changeNotAllowed)
                                    ? Wrap(
                                        children: kMealAmounts
                                            .map(
                                              (amt) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 4.0,
                                                ),
                                                child: ChoiceChip(
                                                  label: Text(
                                                    amt.toString(),
                                                  ),
                                                  selected: amt ==
                                                          mealAmounts['dinner']
                                                      ? true
                                                      : false,
                                                  onSelected: (bool selected) {
                                                    if (selected) {
                                                      setState(() {
                                                        mealAmounts['dinner'] =
                                                            amt;
                                                        mealAmountUpdated =
                                                            true;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      )
                                    : Align(
                                        alignment: Alignment.topLeft,
                                        child: Chip(
                                          label: Text(
                                            mealAmounts['dinner']
                                                .toDouble()
                                                .toString(),
                                          ),
                                        ),
                                      ),
                            trailing: Switch(
                              inactiveThumbColor:
                                  Theme.of(context).primaryColorLight,
                              inactiveTrackColor:
                                  Theme.of(context).disabledColor,
                              value: mealExists
                                  ? mealChecks['dinner']
                                  : ((mealChecks['dinner'] ??
                                          _currentDefaultMeal['dinner']) ??
                                      false),
                              onChanged:
                                  changeNotAllowed ? null : _onDinnerChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  changeNotAllowed
                      ? Container()
                      : (_saveLoading
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SpinKitThreeBounce(
                                color: accentColor,
                                size: 25.0,
                              ),
                            )
                          : RaisedButton(
                              elevation: kElevation,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(kBorderRadius),
                              ),
                              color: Theme.of(context).accentColor,
                              textColor: Colors.white,
                              onPressed: () async {
                                setState(() {
                                  _saveLoading = true;
                                });
                                if (widget.isDefault) {
                                  await db.updateUserDefaultMeal(
                                      mealChecks['breakfast'] ??
                                          _currentDefaultMeal['breakfast'],
                                      mealChecks['lunch'] ??
                                          _currentDefaultMeal['lunch'],
                                      mealChecks['dinner'] ??
                                          _currentDefaultMeal['dinner']);
                                  Navigator.pop(context);
                                } else {
                                  if (mealUpdated) {
                                    if (!mealExists) {
                                      await db.createNewMealData(
                                          widget.date,
                                          mealChecks['breakfast'] ??
                                              _currentDefaultMeal['breakfast'],
                                          mealChecks['lunch'] ??
                                              _currentDefaultMeal['lunch'],
                                          mealChecks['dinner'] ??
                                              _currentDefaultMeal['dinner']);
                                      mealExists = true;
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

                                  if (DatabaseService.isManager &&
                                      mealAmountUpdated) {
                                    if (!mealAmountExists) {
                                      await db.createMealAmount(
                                          widget.date,
                                          mealAmounts['breakfast'],
                                          mealAmounts['lunch'],
                                          mealAmounts['dinner']);
                                      mealAmountExists = true;
                                    } else {
                                      await db.updateMealAmount(
                                          widget.date,
                                          mealAmounts['breakfast'],
                                          mealAmounts['lunch'],
                                          mealAmounts['dinner']);
                                    }
                                  }

                                  setState(() {
                                    _saveLoading = false;
                                  });
                                }
                              },
                              child: Text('Save'),
                            )),
                ],
              );
            },
          );
  }
}
