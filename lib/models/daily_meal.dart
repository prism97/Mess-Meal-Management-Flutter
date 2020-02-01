class DailyMeal {
  DateTime date;
  bool breakfast;
  bool lunch;
  bool dinner;

  DailyMeal() {
    breakfast = true;
    lunch = true;
    dinner = true;
  }

  Map<String, dynamic> toJson() => {
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
      };

  DailyMeal.fromJson(Map<String, dynamic> json)
      : breakfast = json['breakfast'],
        lunch = json['lunch'],
        dinner = json['dinner'];
}
