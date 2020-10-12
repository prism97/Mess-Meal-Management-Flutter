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
  bool loading = true, updating = false;
  Meal defaultMeal;
  FirestoreDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    db.getDefaultMeal().then((value) {
      defaultMeal = value;
      breakfast = defaultMeal.breakfast;
      lunch = defaultMeal.lunch;
      dinner = defaultMeal.dinner;
      setState(() {
        loading = false;
      });
    });
  }

  // TODO: handle what to do after default meal update

  @override
  Widget build(BuildContext context) {
    return loading
        ? Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: SpinKitCircle(
              color: primaryColorDark,
              size: 50.0,
            ),
          )
        : Column(
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
                          setState(() {
                            breakfast = value;
                          });
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
                          setState(() {
                            lunch = value;
                          });
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
                          setState(() {
                            dinner = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              updating
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 25.0,
                      ),
                    )
                  : RaisedButton(
                      child: Text('Save'),
                      onPressed: () async {
                        Meal newMeal = Meal(
                          breakfast: breakfast,
                          lunch: lunch,
                          dinner: dinner,
                          date: DateTime.now(),
                        );
                        setState(() {
                          updating = true;
                        });
                        try {
                          await db.updateDefaultMeal(
                            defaultMeal,
                            newMeal,
                          );
                          defaultMeal = newMeal;
                          breakfast = defaultMeal.breakfast;
                          lunch = defaultMeal.lunch;
                          dinner = defaultMeal.dinner;
                        } catch (error) {
                          print(error);
                        } finally {
                          setState(() {
                            updating = false;
                          });
                        }
                      },
                    )
            ],
          );
  }
}
