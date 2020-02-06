import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_meal/models/user.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  // collection reference
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  createUserData() async {
    await userCollection.document(uid).setData({
      'default_meal': <String, bool>{
        'breakfast': true,
        'lunch': true,
        'dinner': true
      },
      'current_fortnight_meal_amount': 0
    });
  }

  Future updateUserDefaultMeal(bool breakfast, bool lunch, bool dinner) async {
    return await userCollection.document(uid).updateData({
      'default_meal': <String, bool>{
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner
      }
    });
  }

  // user data from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      defaultMeal: Map<String, bool>.from(snapshot.data['default_meal']),
      currentFortnightMealAmount:
          snapshot.data['current_fortnight_meal_amount'],
    );
  }

  Stream<UserData> get userData {
    return userCollection.document(uid).snapshots().map(_userDataFromSnapshot);
  }
}
