import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_meal/models/meal_data.dart';
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

  createNewMealData(
      DateTime date, bool breakfast, bool lunch, bool dinner) async {
    final _date = DateTime(date.year, date.month, date.day);
    await userCollection.document(uid).collection('meals').document().setData({
      'date': _date,
      'meal': <String, bool>{
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner
      },
    });
  }

  updateMealData(DateTime date, bool breakfast, bool lunch, bool dinner) async {
    final _date = DateTime(date.year, date.month, date.day);
    final snapshot = await queryMealData(_date);
    final doc = snapshot.documents.first;
    final docId = doc.documentID;

    await userCollection
        .document(uid)
        .collection('meals')
        .document(docId)
        .updateData({
      'meal': <String, bool>{
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner
      },
    });
  }

  MealData _mealDataFromSnapshot(QuerySnapshot snapshot) {
    if (snapshot.documents.isNotEmpty) {
      final doc = snapshot.documents.first;
      return MealData(Map<String, bool>.from(doc.data['meal']));
    }
    return null;
  }

  Future<MealData> getMealData(DateTime date) async {
    final _date = DateTime(date.year, date.month, date.day);
    return _mealDataFromSnapshot(await queryMealData(_date));
  }

  Future<QuerySnapshot> queryMealData(DateTime date) async {
    return await userCollection
        .document(uid)
        .collection('meals')
        .where('date', isEqualTo: date)
        .getDocuments();
  }

  // list of users who checked today's breakfast
  Future<List<String>> mealTakers(String mealName) async {
    final today = DateTime.now();
    final _date = DateTime(today.year, today.month, today.day);

    final usersSnapshot = await userCollection.getDocuments();
    final users = usersSnapshot.documents;

    List<String> mealUsers = [];

    users.forEach((user) async {
      await userCollection
          .document(user.documentID)
          .collection('meals')
          .where('date', isEqualTo: _date)
          .getDocuments()
          .then((userMeal) {
        if (userMeal.documents.isEmpty) {
          if (user.data['default_meal'][mealName]) {
            mealUsers.add(user.documentID);
          }
        } else {
          if (userMeal.documents.first.data['meal'][mealName]) {
            mealUsers.add(user.documentID);
          }
        }
      });
    });
    return mealUsers;
  }
}
