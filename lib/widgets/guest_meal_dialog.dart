import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/meal_amount.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/meal_tile.dart';
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
  bool _breakfast, _lunch, _dinner;
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
        Meal guestMeal = Meal.fromMap(Map<String, bool>.from(doc.data()));
        _breakfast = guestMeal.breakfast;
        _lunch = guestMeal.lunch;
        _dinner = guestMeal.dinner;
      } else {
        _breakfast = false;
        _lunch = false;
        _dinner = false;
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
                          MealTile(
                            title: 'Breakfast',
                            mealAmount: (Decimal.parse(widget
                                        .mealAmount.breakfast
                                        .toString()) *
                                    Decimal.parse('1.5'))
                                .toDouble(),
                            value: _breakfast,
                            onChanged: _checkTimeConstraint()
                                ? (bool value) {
                                    if (!widget.userMeal.breakfast && value) {
                                      return;
                                    }
                                    setState(() {
                                      _breakfast = value;
                                    });
                                  }
                                : null,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          MealTile(
                            title: 'Lunch',
                            mealAmount: (Decimal.parse(
                                        widget.mealAmount.lunch.toString()) *
                                    Decimal.parse('1.5'))
                                .toDouble(),
                            value: _lunch,
                            onChanged: _checkTimeConstraint()
                                ? (bool value) {
                                    if (!widget.userMeal.lunch && value) {
                                      return;
                                    }
                                    setState(() {
                                      _lunch = value;
                                    });
                                  }
                                : null,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          MealTile(
                            title: 'Dinner',
                            mealAmount: (Decimal.parse(
                                        widget.mealAmount.dinner.toString()) *
                                    Decimal.parse('1.5'))
                                .toDouble(),
                            value: _dinner,
                            onChanged: _checkTimeConstraint()
                                ? (bool value) {
                                    if (!widget.userMeal.dinner && value) {
                                      return;
                                    }
                                    setState(() {
                                      _dinner = value;
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
                                      Meal(
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
