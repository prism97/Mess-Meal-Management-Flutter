import 'package:flutter/material.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/default_meal.dart';
import 'package:mess_meal/widgets/meal_check.dart';
import 'package:provider/provider.dart';

class DailyMealCard extends StatefulWidget {
  final DateTime date;

  DailyMealCard({this.date});

  @override
  _DailyMealCardState createState() => _DailyMealCardState();
}

class _DailyMealCardState extends State<DailyMealCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
          MealCheck(
            mealName: 'Breakfast',
            initialCheck: Provider.of<DefaultMeal>(context).breakfast,
          ),
          Divider(
            height: 1.0,
            indent: 10.0,
            endIndent: 10.0,
          ),
          MealCheck(
            mealName: 'Lunch',
            initialCheck: Provider.of<DefaultMeal>(context).lunch,
          ),
          Divider(
            height: 1.0,
            indent: 10.0,
            endIndent: 10.0,
          ),
          MealCheck(
            mealName: 'Dinner',
            initialCheck: Provider.of<DefaultMeal>(context).dinner,
          ),
        ],
      ),
    );
  }
}
