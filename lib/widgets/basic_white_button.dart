import 'package:flutter/material.dart';
import 'package:mess_meal/constants/numbers.dart';

class BasicWhiteButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  BasicWhiteButton({@required this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 100.0,
      ),
      child: RaisedButton(
        child: Text(
          text,
          style: Theme.of(context).textTheme.body1,
        ),
        onPressed: onPressed,
        elevation: kElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
      ),
    );
  }
}
