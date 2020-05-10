import 'package:flutter/material.dart';
import 'package:mess_meal/constants/numbers.dart';

ThemeData themeData = ThemeData(
  fontFamily: 'Montserrat',
  primaryColorDark: Colors.purple.shade900,
  primaryColorLight: Colors.purple.shade600,
  accentColor: Colors.purple,
  disabledColor: Colors.purple.shade100,
  cursorColor: Colors.white,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 20.0,
    backgroundColor: Colors.purple.shade100,
    unselectedItemColor: Colors.white,
    selectedItemColor: Colors.purple.shade600,
  ),
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
    headline6: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
    ),
    bodyText1: TextStyle(
      color: Colors.purple.shade900,
      fontSize: 16.0,
    ),
    bodyText2: TextStyle(
      color: Colors.purple.shade600,
      fontSize: 16.0,
    ),
    subtitle1: TextStyle(
      color: Colors.purple.shade900,
      fontSize: 15.0,
    ),
    subtitle2: TextStyle(
      color: Colors.purple.shade600,
      fontSize: 15.0,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.purple.shade300,
    disabledColor: Colors.purple.shade100,
    selectedColor: Colors.purple.shade600,
    secondarySelectedColor: Colors.purple.shade600,
    labelPadding: EdgeInsets.all(0.0),
    padding: EdgeInsets.all(6.0),
    shape: CircleBorder(),
    labelStyle: TextStyle(
      color: Colors.white,
      fontSize: 12.0,
    ),
    secondaryLabelStyle: TextStyle(
      color: Colors.white,
      fontSize: 12.0,
    ),
    brightness: Brightness.light,
    elevation: kElevation,
  ),
);
