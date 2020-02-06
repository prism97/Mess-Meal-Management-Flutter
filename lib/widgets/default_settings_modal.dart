import 'package:flutter/material.dart';
import 'package:mess_meal/widgets/daily_meal_card.dart';

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
            DailyMealCard(isDefault: true),
          ],
        ),
      ),
    );
  }
}
