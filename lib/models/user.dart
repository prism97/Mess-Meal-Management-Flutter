import 'package:meta/meta.dart';
import 'package:mess_meal/models/meal.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final int managerSerial;
  bool isConvener;
  Meal defaultMeal;

  User({
    @required this.uid,
    @required this.email,
    @required this.name,
    @required this.managerSerial,
    this.isConvener = false,
    this.defaultMeal,
  });

  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    return User(
      uid: documentId,
      email: data['email'],
      name: data['name'],
      managerSerial: data['managerSerial'],
      isConvener: data['isConvener'],
      defaultMeal: Meal.fromMap(data['defaultMeal']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': this.email,
      'name': this.name,
      'managerSerial': this.managerSerial,
      'isConvener': this.isConvener,
      'defaultMeal': this.defaultMeal.toMap(),
    };
  }

  bool isManager() {
    return this.managerSerial == 1;
  }
}
