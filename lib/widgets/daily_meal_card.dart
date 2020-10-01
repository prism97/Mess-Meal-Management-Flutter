import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/services/firestore_database.dart';
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

  // TODO: add time limit for meal update

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);

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
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: [
                          MealTile(
                            title: 'Breakfast',
                            value: breakfast,
                            onChanged: (bool value) {
                              breakfast = value;
                              db.setMeal(
                                Meal(
                                  date: widget.date,
                                  breakfast: breakfast,
                                  lunch: lunch,
                                  dinner: dinner,
                                ),
                              );
                            },
                          ),
                          Divider(
                            height: 1.0,
                            indent: 10.0,
                            endIndent: 10.0,
                          ),
                          MealTile(
                            title: 'Lunch',
                            value: lunch,
                            onChanged: (bool value) {
                              lunch = value;
                              db.setMeal(
                                Meal(
                                  date: widget.date,
                                  breakfast: breakfast,
                                  lunch: lunch,
                                  dinner: dinner,
                                ),
                              );
                            },
                          ),
                          Divider(
                            height: 1.0,
                            indent: 10.0,
                            endIndent: 10.0,
                          ),
                          MealTile(
                            title: 'Dinner',
                            value: dinner,
                            onChanged: (bool value) {
                              dinner = value;
                              db.setMeal(
                                Meal(
                                  date: widget.date,
                                  breakfast: breakfast,
                                  lunch: lunch,
                                  dinner: dinner,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          );
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
  final bool value;
  final Function onChanged;

  const MealTile(
      {@required this.title, @required this.value, @required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      value: value,
      onChanged: onChanged,
      inactiveThumbColor: Theme.of(context).primaryColorLight,
      inactiveTrackColor: Theme.of(context).disabledColor,
    );
  }
}
