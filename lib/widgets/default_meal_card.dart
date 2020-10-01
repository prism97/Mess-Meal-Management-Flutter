import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/daily_meal_card.dart';
import 'package:provider/provider.dart';

class DefaultMealCard extends StatefulWidget {
  @override
  _DefaultMealCardState createState() => _DefaultMealCardState();
}

class _DefaultMealCardState extends State<DefaultMealCard> {
  bool breakfast, lunch, dinner;
  bool loading = false;
  Meal defaultMeal;

  // TODO: handle what to do after default meal update

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);

    return StreamBuilder<Meal>(
      stream: db.defaultMealStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          defaultMeal = snapshot.data;
          breakfast = defaultMeal.breakfast;
          lunch = defaultMeal.lunch;
          dinner = defaultMeal.dinner;

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
                          db.setDefaultMeal(
                            Meal(
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
                          db.setDefaultMeal(
                            Meal(
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
                          db.setDefaultMeal(
                            Meal(
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
