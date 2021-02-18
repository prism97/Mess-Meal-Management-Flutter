import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/guest_meal.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/meal_amount.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/guest_meal_tile.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';

class GuestMealDialog extends StatefulWidget {
  final DateTime date;
  final MealAmount mealAmount;
  final Meal userMeal;

  const GuestMealDialog(
      {@required this.date,
      @required this.mealAmount,
      @required this.userMeal});

  @override
  _GuestMealDialogState createState() => _GuestMealDialogState();
}

class _GuestMealDialogState extends State<GuestMealDialog> {
  bool _loading = true;
  int _breakfast, _lunch, _dinner;
  FirestoreDatabase db;

  bool _checkTimeConstraint() {
    final lastUpdateTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      7,
    );
    if (DateTime.now().isAfter(lastUpdateTime)) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    print(widget.mealAmount.breakfast);
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    db.getGuestMeal(widget.date).then((doc) {
      if (doc.exists) {
        GuestMeal guestMeal =
            GuestMeal.fromMap(Map<String, int>.from(doc.data()));
        _breakfast = guestMeal.breakfast;
        _lunch = guestMeal.lunch;
        _dinner = guestMeal.dinner;
      } else {
        _breakfast = 0;
        _lunch = 0;
        _dinner = 0;
      }
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          kBorderRadius,
        ),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Guest Meal',
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              Text(
                widget.date.toIso8601String().substring(0, 10),
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
              Divider(
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(
                height: 10.0,
              ),
              _loading
                  ? SpinKitFadingCircle(
                      color: primaryColorDark,
                      size: 40.0,
                    )
                  : Form(
                      child: Column(
                        children: [
                          GuestMealTile(
                            title: 'Breakfast',
                            mealAmount: (Decimal.parse(widget
                                        .mealAmount.breakfast
                                        .toString()) *
                                    Decimal.parse('1.5'))
                                .toDouble(),
                            count: _breakfast,
                            onDecrement:
                                _checkTimeConstraint() && _breakfast != 0
                                    ? () {
                                        if (!widget.userMeal.breakfast) {
                                          return;
                                        }
                                        setState(() {
                                          _breakfast--;
                                        });
                                      }
                                    : null,
                            onIncrement: _checkTimeConstraint()
                                ? () {
                                    if (!widget.userMeal.breakfast) {
                                      return;
                                    }
                                    setState(() {
                                      _breakfast++;
                                    });
                                  }
                                : null,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          GuestMealTile(
                            title: 'Lunch',
                            mealAmount: (Decimal.parse(
                                        widget.mealAmount.lunch.toString()) *
                                    Decimal.parse('1.5'))
                                .toDouble(),
                            count: _lunch,
                            onDecrement: _checkTimeConstraint() && _lunch != 0
                                ? () {
                                    if (!widget.userMeal.lunch) {
                                      return;
                                    }
                                    setState(() {
                                      _lunch--;
                                    });
                                  }
                                : null,
                            onIncrement: _checkTimeConstraint()
                                ? () {
                                    if (!widget.userMeal.lunch) {
                                      return;
                                    }
                                    setState(() {
                                      _lunch++;
                                    });
                                  }
                                : null,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          GuestMealTile(
                            title: 'Dinner',
                            mealAmount: (Decimal.parse(
                                        widget.mealAmount.dinner.toString()) *
                                    Decimal.parse('1.5'))
                                .toDouble(),
                            count: _dinner,
                            onDecrement: _checkTimeConstraint() && _dinner != 0
                                ? () {
                                    if (!widget.userMeal.dinner) {
                                      return;
                                    }
                                    setState(() {
                                      _dinner--;
                                    });
                                  }
                                : null,
                            onIncrement: _checkTimeConstraint()
                                ? () {
                                    if (!widget.userMeal.dinner) {
                                      return;
                                    }
                                    setState(() {
                                      _dinner++;
                                    });
                                  }
                                : null,
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          _checkTimeConstraint()
                              ? RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(kBorderRadius),
                                  ),
                                  child: Text('Save'),
                                  onPressed: () async {
                                    await db.setGuestMeal(
                                      GuestMeal(
                                        breakfast: _breakfast,
                                        lunch: _lunch,
                                        dinner: _dinner,
                                        date: widget.date,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                )
                              : Container(),
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
