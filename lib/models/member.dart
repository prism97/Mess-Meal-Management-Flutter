import 'package:meta/meta.dart';
import 'package:mess_meal/models/meal.dart';

class Member {
  final String uid;
  final String email;
  final String name;
  final String teacherId;
  final int managerSerial;
  bool isConvener;
  bool isMessboy;
  bool isDeleted;
  Meal defaultMeal;

  Member({
    @required this.uid,
    @required this.email,
    @required this.name,
    @required this.teacherId,
    @required this.managerSerial,
    this.isConvener = false,
    this.isMessboy = false,
    this.isDeleted = false,
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
      teacherId: data['teacherId'],
      managerSerial: data['managerSerial'],
      isConvener: data['isConvener'],
      isDeleted: data['isDeleted'] ?? false,
      defaultMeal: Meal.fromMapWithDate(data['defaultMeal']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': this.email,
      'name': this.name,
      'teacherId': this.teacherId,
      'managerSerial': this.managerSerial,
      'isConvener': this.isConvener,
      'isDeleted': this.isDeleted,
      'defaultMeal': this.defaultMeal.toMapWithDate(),
    };
  }

  bool isManager() {
    return this.managerSerial == 1;
  }
}
