import 'package:flutter/material.dart';

class GuestMeal {
  DateTime date;
  int breakfast;
  int lunch;
  int dinner;

  GuestMeal(
      {this.date,
      @required this.breakfast,
      @required this.lunch,
      @required this.dinner});

  factory GuestMeal.fromMap(Map<String, int> data, {DateTime date}) {
    if (data == null) {
      return null;
    }

    return GuestMeal(
      date: date,
      breakfast: data['breakfast'],
      lunch: data['lunch'],
      dinner: data['dinner'],
    );
  }

  factory GuestMeal.fromMapWithDate(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    return GuestMeal(
      date: DateTime.parse(data['date']),
      breakfast: data['breakfast'],
      lunch: data['lunch'],
      dinner: data['dinner'],
    );
  }

  Map<String, int> toMap() {
    return {
      'breakfast': this.breakfast,
      'lunch': this.lunch,
      'dinner': this.dinner
    };
  }

  Map<String, dynamic> toMapWithDate() {
    return {
      'breakfast': this.breakfast,
      'lunch': this.lunch,
      'dinner': this.dinner,
      'date': this.date.toIso8601String(),
    };
  }
}
