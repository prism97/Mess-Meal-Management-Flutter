import 'package:flutter/material.dart';
import 'package:mess_meal/constants/colors.dart';

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
