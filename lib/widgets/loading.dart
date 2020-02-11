import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).disabledColor,
      child: Center(
        child: SpinKitChasingDots(
          color: primaryColorDark,
          size: 50.0,
        ),
      ),
    );
  }
}
