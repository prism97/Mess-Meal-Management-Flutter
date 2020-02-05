import 'package:flutter/material.dart';
import 'package:mess_meal/constants/numbers.dart';

class BasicWhiteButton extends StatelessWidget {
  final String text;
  final String destination;

  BasicWhiteButton({@required this.text, @required this.destination});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
        child: Text(
          text,
          style: Theme.of(context).textTheme.body1,
        ),
        onPressed: () {
          Navigator.pushNamed(context, destination);
        },
        elevation: kElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
      ),
    );
  }
}
