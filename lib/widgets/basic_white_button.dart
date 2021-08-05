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
        horizontal: 20.0,
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.white,
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
          ),
          elevation: MaterialStateProperty.all<double>(kElevation),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
