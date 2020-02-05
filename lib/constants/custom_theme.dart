import 'package:flutter/material.dart';
import 'package:mess_meal/constants/numbers.dart';

ThemeData themeData = ThemeData(
  fontFamily: 'Montserrat',
  primaryColorDark: Colors.purple.shade900,
  primaryColorLight: Colors.purple.shade600,
  accentColor: Colors.purple,
  disabledColor: Colors.purple.shade100,
  cursorColor: Colors.white,
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: Colors.purple.shade100,
    ),
    errorStyle: TextStyle(
      color: Colors.white,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide(
        color: Colors.purple.shade100,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide(
        color: Colors.white,
        width: 2.0,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide(
        color: Colors.purple.shade100,
        width: 2.0,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadius),
      borderSide: BorderSide(
        color: Colors.white,
        width: 2.0,
      ),
    ),
  ),
  textTheme: TextTheme(
    title: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
    ),
    body1: TextStyle(
      color: Colors.purple.shade900,
      fontSize: 16.0,
    ),
    body2: TextStyle(
      color: Colors.purple.shade600,
      fontSize: 16.0,
    ),
    display1: TextStyle(
      color: Colors.purple.shade900,
      fontSize: 15.0,
    ),
    display2: TextStyle(
      color: Colors.purple.shade600,
      fontSize: 15.0,
    ),
  ),
);
