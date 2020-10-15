import 'package:meta/meta.dart';
import 'package:mess_meal/models/meal.dart';

class Member {
  final String uid;
  final String email;
  final String name;
  final int managerSerial;
  bool isConvener;
  bool isMessboy;
  Meal defaultMeal;

  Member({
    @required this.uid,
    @required this.email,
    @required this.name,
    @required this.managerSerial,
    this.isConvener = false,
    this.isMessboy = false,
    @required this.defaultMeal,
  });

  factory Member.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    return Member(
      uid: documentId,
      email: data['email'],
      name: data['name'],
      managerSerial: data['managerSerial'],
      isConvener: data['isConvener'],
      defaultMeal: Meal.fromMapWithDate(data['defaultMeal']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': this.email,
      'name': this.name,
      'managerSerial': this.managerSerial,
      'isConvener': this.isConvener,
      'defaultMeal': this.defaultMeal.toMapWithDate(),
    };
  }

  bool isManager() {
    return this.managerSerial == 1;
  }
}
