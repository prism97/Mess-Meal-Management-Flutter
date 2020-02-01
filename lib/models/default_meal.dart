import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultMeal with ChangeNotifier {
  bool breakfast = true;
  bool lunch = true;
  bool dinner = true;
  static DefaultMeal _instance;

  DefaultMeal._();

  static DefaultMeal getInstance() {
    if (_instance == null) {
      _instance = DefaultMeal._();
      getDefaultMeal();
    }
    return _instance;
  }

  Map<String, dynamic> toJson() => {
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
      };

  void update(Map<String, dynamic> json) {
    breakfast = json['breakfast'];
    lunch = json['lunch'];
    dinner = json['dinner'];
    notifyListeners();
  }

  static void getDefaultMeal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String mealString = prefs.getString('default_meal');
    if (mealString != null) {
      _instance.update(jsonDecode(mealString));
    } else {
      await prefs.setString('default_meal', jsonEncode(_instance.toJson()));
    }
  }
}
