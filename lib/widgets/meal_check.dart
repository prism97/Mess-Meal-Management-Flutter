import 'package:flutter/material.dart';

class MealCheck extends StatefulWidget {
  final String mealName;
  final bool initialCheck;

  MealCheck({@required this.mealName, this.initialCheck = true});

  @override
  _MealCheckState createState() => _MealCheckState(check: initialCheck);
}

class _MealCheckState extends State<MealCheck> {
  bool check;

  _MealCheckState({this.check});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20.0),
      title: Text(
        widget.mealName,
        style: Theme.of(context).textTheme.body1,
      ),
      trailing: Switch(
        inactiveThumbColor: Theme.of(context).primaryColorLight,
        inactiveTrackColor: Theme.of(context).disabledColor,
        value: check,
        onChanged: (newValue) {
          setState(() {
            check = newValue;
          });
        },
      ),
    );
  }
}
