import 'package:flutter/material.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/default_meal.dart';
import 'package:mess_meal/widgets/daily_meal_card.dart';
import 'package:provider/provider.dart';

class DefaultSettingsModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF757575),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Default Meal Settings',
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20.0,
              ),
            ),
            ChangeNotifierProvider<DefaultMeal>.value(
              value: DefaultMeal.getInstance(),
              child: DailyMealCard(),
            ),
            RaisedButton(
              elevation: kElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
