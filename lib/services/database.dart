import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mess_meal/models/meal_data.dart';
import 'package:mess_meal/models/user.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  // collection reference
  static final CollectionReference userCollection =
      Firestore.instance.collection('users');

  static final CollectionReference systemCollection =
      Firestore.instance.collection('system');

  static final CollectionReference managerCollection =
      Firestore.instance.collection('managers');

  static createUserData(int studentId, String name, String email) async {
    await userCollection
        .document()
        .setData({'studentId': studentId, 'name': name, 'email': email});
  }

  static Future<void> createManagerData(DateTime date) async {
    await managerCollection.document().setData({'start_date': date});
  }

  static Future<Map<String, String>> getManagerData() async {
    final systemManagerDoc =
        await systemCollection.document('currentManager').get();
    final managerId = systemManagerDoc.data['managerId'];
    final userId = systemManagerDoc.data['userId'];

    final managerDoc = await managerCollection.document(managerId).get();
    final userDoc = await userCollection.document(userId).get();
    final startDate = (managerDoc.data['start_date'] as Timestamp).toDate();
    final workPeriod = DateTime.now().difference(startDate).inDays;

    return {
      'name': userDoc.data['name'],
      'studentId': userDoc.data['studentId'].toString(),
      'startDate': DateFormat.yMMMd().format(startDate),
      'workPeriod': workPeriod.toString(),
      'cost': managerDoc.data['cost'].toString()
    };
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

  Future<List<String>> get userRoles async {
    final userDoc = await userCollection.document(uid).get();
    return List<String>.from(userDoc.data['roles'] ?? []);
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

  // list of users who subscribed for today's breakfast, lunch and dinner
  static Future<Map<String, List<String>>> mealTakersGrouped() async {
    final today = DateTime.now();
    final _date = DateTime(today.year, today.month, today.day);

    final usersSnapshot = await userCollection.getDocuments();
    final users = usersSnapshot.documents;

    Map<String, List<String>> mealUsers = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
    };

    for (var user in users) {
      final roles = List<String>.from(user.data['roles'] ?? []);
      if (!roles.contains('admin') && !roles.contains('messboy')) {
        final userMeal = await userCollection
            .document(user.documentID)
            .collection('meals')
            .where('date', isEqualTo: _date)
            .getDocuments();

        final mealDoc = userMeal.documents;
        final defaultMeal = user.data['default_meal'];
        final name = user.data['name'];

        if (mealDoc.isEmpty) {
          if (defaultMeal['breakfast']) mealUsers['breakfast'].add(name);
          if (defaultMeal['lunch']) mealUsers['lunch'].add(name);
          if (defaultMeal['dinner']) mealUsers['dinner'].add(name);
        } else {
          final meal = mealDoc.first.data['meal'];
          if (meal['breakfast']) mealUsers['breakfast'].add(name);
          if (meal['lunch']) mealUsers['lunch'].add(name);
          if (meal['dinner']) mealUsers['dinner'].add(name);
        }
      }
    }
    return mealUsers;
  }
}
