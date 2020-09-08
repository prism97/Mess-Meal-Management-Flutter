import 'package:meta/meta.dart';

class Meal {
  DateTime date; // for a particular day (not needed for default meal)
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
        dinner: data['dinner']);
  }

  Map<String, bool> toMap() {
    return {
      'breakfast': this.breakfast,
      'lunch': this.lunch,
      'dinner': this.dinner
    };
  }
}
