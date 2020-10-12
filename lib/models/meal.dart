import 'package:meta/meta.dart';

class Meal {
  DateTime date;
  bool breakfast;
  bool lunch;
  bool dinner;

  Meal(
      {this.date,
      @required this.breakfast,
      @required this.lunch,
      @required this.dinner});

  factory Meal.fromMap(Map<String, bool> data, {DateTime date}) {
    if (data == null) {
      return null;
    }

    return Meal(
      date: date,
      breakfast: data['breakfast'],
      lunch: data['lunch'],
      dinner: data['dinner'],
    );
  }

  factory Meal.fromMapWithDate(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    return Meal(
      date: DateTime.parse(data['date']),
      breakfast: data['breakfast'],
      lunch: data['lunch'],
      dinner: data['dinner'],
    );
  }

  Map<String, bool> toMap() {
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
