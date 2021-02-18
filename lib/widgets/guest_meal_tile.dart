import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';

class GuestMealTile extends StatelessWidget {
  final String title;
  final double mealAmount;
  final int count;
  final Function onIncrement;
  final Function onDecrement;

  const GuestMealTile({
    @required this.title,
    @required this.mealAmount,
    @required this.count,
    @required this.onIncrement,
    @required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.all(0),
      title: Text(
        title,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      leading: Chip(
        label: Text(
          mealAmount.toString(),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.minus,
              size: 10,
            ),
            color: accentColor,
            onPressed: onDecrement,
          ),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.caption.copyWith(
                  color: Colors.black,
                ),
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.plus,
              size: 10,
            ),
            color: accentColor,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
