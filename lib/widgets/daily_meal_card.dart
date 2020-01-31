import 'package:flutter/material.dart';

class DailyMealCard extends StatefulWidget {
  @override
  _DailyMealCardState createState() => _DailyMealCardState();
}

class _DailyMealCardState extends State<DailyMealCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.purple.shade100,
      child: Column(
        children: <Widget>[
          MealCheck(
            mealName: 'Breakfast',
          ),
          Divider(
            height: 1.0,
            indent: 10.0,
            endIndent: 10.0,
          ),
          MealCheck(
            mealName: 'Lunch',
          ),
          Divider(
            height: 1.0,
            indent: 10.0,
            endIndent: 10.0,
          ),
          MealCheck(
            mealName: 'Dinner',
          ),
        ],
      ),
    );
  }
}

class MealCheck extends StatelessWidget {
  final String mealName;

  MealCheck({@required this.mealName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20.0),
      title: Text(
        mealName,
        style: TextStyle(
          color: Colors.purple.shade900,
          fontSize: 18.0,
        ),
      ),
      trailing: Switch(
        inactiveThumbColor: Colors.purple.shade900,
        inactiveTrackColor: Colors.white,
        value: false,
        onChanged: (newValue) {},
      ),
    );
  }
}
