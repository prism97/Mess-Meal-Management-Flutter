import 'package:flutter/material.dart';
import 'package:mess_meal/constants/numbers.dart';

class CustomTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(),
        ),
      ),
    );
  }
}
