import 'package:meta/meta.dart';

class MealAmount {
  DateTime date; // for a particular day (handled by manager)
  double breakfast;
  double lunch;
  double dinner;

  MealAmount(
      {this.date,
      @required this.breakfast,
      @required this.lunch,
      @required this.dinner});

  factory MealAmount.fromMap(Map<String, double> data,
      {DateTime date, int dayOfWeek}) {
    if (data == null) {
      return null;
    }

    return MealAmount(
        date: date,
        breakfast: data['breakfast'],
        lunch: data['lunch'],
        dinner: data['dinner']);
  }

  Map<String, double> toMap() {
    return {
      'breakfast': this.breakfast,
      'lunch': this.lunch,
      'dinner': this.dinner
    };
  }
}
