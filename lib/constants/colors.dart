import 'package:flutter/material.dart';

const primaryColorDark = Color(0xFF4A148C);
const primaryColorLight = Color(0xFF8E24AA);

const kBackgroundGradient = LinearGradient(
  colors: [
    primaryColorDark,
    primaryColorLight,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
