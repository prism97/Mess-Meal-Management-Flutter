import 'package:mess_meal/constants/enums.dart';
import 'package:mess_meal/models/meal.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final int studentId;
  UserRole role;
  Meal defaultMeal;

  User({
    this.uid,
    this.email,
    this.name,
    this.studentId,
    this.role,
    this.defaultMeal,
  });
}

class UserData {
  final String uid;
  final Map<String, bool> defaultMeal;
  final int currentFortnightMealAmount;

  UserData({this.uid, this.defaultMeal, this.currentFortnightMealAmount});
}
