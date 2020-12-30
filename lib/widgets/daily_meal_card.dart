import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/meal_amount.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/guest_meal_dialog.dart';
import 'package:mess_meal/widgets/meal_amount_dialog.dart';
import 'package:provider/provider.dart';

class DailyMealCard extends StatefulWidget {
  final DateTime date;

  const DailyMealCard({this.date});

  @override
  _DailyMealCardState createState() => _DailyMealCardState();
}

class _DailyMealCardState extends State<DailyMealCard> {
  bool breakfast, lunch, dinner;
  bool loading = false;
  Meal defaultMeal;
  MealAmount mealAmount;
  FirestoreDatabase db;
  bool isManager = false;

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
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Meal>(
      stream: db.defaultMealStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          defaultMeal = snapshot.data;

          return StreamBuilder<Meal>(
              stream: db.mealStream(date: widget.date),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Meal meal = snapshot.data;
                  breakfast = meal.breakfast;
                  lunch = meal.lunch;
                  dinner = meal.dinner;
                } else {
                  breakfast = defaultMeal.breakfast;
                  lunch = defaultMeal.lunch;
                  dinner = defaultMeal.dinner;
                }

                return StreamBuilder<MealAmount>(
                    stream: db.mealAmountStream(date: widget.date),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        mealAmount = snapshot.data;
                      } else {
                        mealAmount = MealAmount.fromDefault();
                      }
                      return Column(
                        children: [
                          Card(
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: Colors.white,
                            elevation: kElevation,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Column(
                                children: [
                                  MealTile(
                                    title: 'Breakfast',
                                    mealAmount: mealAmount.breakfast,
                                    value: breakfast,
                                    onChanged: _checkTimeConstraint()
                                        ? (bool value) {
                                            breakfast = value;
                                            db.setMeal(
                                              Meal(
                                                date: widget.date,
                                                breakfast: breakfast,
                                                lunch: lunch,
                                                dinner: dinner,
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                  Divider(
                                    height: 1.0,
                                    indent: 10.0,
                                    endIndent: 10.0,
                                  ),
                                  MealTile(
                                    title: 'Lunch',
                                    mealAmount: mealAmount.lunch,
                                    value: lunch,
                                    onChanged: _checkTimeConstraint()
                                        ? (bool value) {
                                            lunch = value;
                                            db.setMeal(
                                              Meal(
                                                date: widget.date,
                                                breakfast: breakfast,
                                                lunch: lunch,
                                                dinner: dinner,
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                  Divider(
                                    height: 1.0,
                                    indent: 10.0,
                                    endIndent: 10.0,
                                  ),
                                  MealTile(
                                    title: 'Dinner',
                                    mealAmount: mealAmount.dinner,
                                    value: dinner,
                                    onChanged: _checkTimeConstraint()
                                        ? (bool value) {
                                            dinner = value;
                                            db.setMeal(
                                              Meal(
                                                date: widget.date,
                                                breakfast: breakfast,
                                                lunch: lunch,
                                                dinner: dinner,
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          RaisedButton(
                            child: Text(
                              'Guest Meal',
                            ),
                            color: Theme.of(context).accentColor,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(kBorderRadius),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => GuestMealDialog(
                                  date: widget.date,
                                  mealAmount: mealAmount,
                                  userMeal: Meal(
                                    breakfast: breakfast,
                                    lunch: lunch,
                                    dinner: dinner,
                                  ),
                                ),
                              );
                            },
                          ),
                          StreamBuilder<Member>(
                            stream: Provider.of<AuthProvider>(context,
                                    listen: false)
                                .user,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                isManager = snapshot.data.isManager();
                              }
                              return isManager && _checkTimeConstraint()
                                  ? RaisedButton(
                                      child: Text(
                                        'Change meal amount',
                                      ),
                                      color: Theme.of(context).accentColor,
                                      textColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            kBorderRadius),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              MealAmountDialog(
                                            date: widget.date,
                                            mealAmount: mealAmount,
                                          ),
                                        );
                                      },
                                    )
                                  : Container();
                            },
                          ),
                        ],
                      );
                    });
              });
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: SpinKitCircle(
              color: primaryColorDark,
              size: 50.0,
            ),
          );
        }
      },
    );
  }
}

class MealTile extends StatelessWidget {
  final String title;
  final double mealAmount;
  final bool value;
  final Function onChanged;

  const MealTile({
    @required this.title,
    @required this.mealAmount,
    @required this.value,
    @required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      secondary: Chip(
        label: Text(mealAmount.toString()),
      ),
      value: value,
      onChanged: onChanged,
      inactiveThumbColor: accentColor.shade300,
      inactiveTrackColor: Theme.of(context).disabledColor,
      activeColor: primaryColorDark,
      activeTrackColor: accentColor.shade600,
    );
  }
}
