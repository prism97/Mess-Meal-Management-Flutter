import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/meal_amount.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/daily_meal_card.dart';
import 'package:provider/provider.dart';

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
      child: Container(
        height: MediaQuery.of(context).size.height / 1.8,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Meal Amount for ${widget.date.toIso8601String().substring(0, 10)}',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 15.0,
                ),
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
                            mealAmount: widget.mealAmount.breakfast * 1.5,
                            value: _breakfast,
                            onChanged: _checkTimeConstraint()
                                ? (bool value) {
                                    if (value && widget.userMeal.breakfast) {
                                      setState(() {
                                        _breakfast = value;
                                      });
                                    }
                                  }
                                : null,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          MealTile(
                            title: 'Lunch',
                            mealAmount: widget.mealAmount.lunch * 1.5,
                            value: _lunch,
                            onChanged: _checkTimeConstraint()
                                ? (bool value) {
                                    if (value && widget.userMeal.lunch) {
                                      setState(() {
                                        _lunch = value;
                                      });
                                    }
                                  }
                                : null,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          MealTile(
                            title: 'Dinner',
                            mealAmount: widget.mealAmount.dinner * 1.5,
                            value: _dinner,
                            onChanged: _checkTimeConstraint()
                                ? (bool value) {
                                    if (value && widget.userMeal.dinner) {
                                      setState(() {
                                        _dinner = value;
                                      });
                                    }
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
