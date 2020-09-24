import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final String uid;

  static bool isAdmin = false;
  static bool isManager = false;
  static bool isMessboy = false;

  DatabaseService({this.uid});

  // collection references
  static final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  static final CollectionReference systemCollection =
      FirebaseFirestore.instance.collection('system');

  static final CollectionReference managerCollection =
      FirebaseFirestore.instance.collection('managers');

  static final CollectionReference mealAmountCollection =
      FirebaseFirestore.instance.collection('mealAmounts');

  // role checks
  Future<void> checkRoles() async {
    final managerDoc = await systemCollection.doc('currentManager').get();
    final managerId = managerDoc.data()['userId'].toString();

    if (managerId.compareTo(this.uid) == 0) {
      isManager = true;
      print('manager');
    }

    final userDoc = await userCollection.doc(this.uid).get();
    final userRoles = List<String>.from(userDoc.data()['roles'] ?? []);
    if (userRoles.contains('admin')) {
      isAdmin = true;
      print('admin');
    } else if (userRoles.contains('messboy')) {
      isMessboy = true;
      print('messboy');
    }
  }

  // data creation
  static createUserData(int studentId, String name, String email) async {
    await userCollection
        .doc()
        .set({'studentId': studentId, 'name': name, 'email': email});
  }

  static Future<void> createManagerData(DateTime date) async {
    await managerCollection.doc().set({'start_date': date});
  }

  static Future<void> updateManagerCost(int cost) async {
    final systemManagerDoc = await systemCollection.doc('currentManager').get();
    final managerId = systemManagerDoc.data()['managerId'];
    await managerCollection
        .doc(managerId)
        .set({'cost': cost}, SetOptions(merge: true));
  }

  static Future<Map<String, String>> getManagerData() async {
    final systemManagerDoc = await systemCollection.doc('currentManager').get();
    final managerId = systemManagerDoc.data()['managerId'];
    final userId = systemManagerDoc.data()['userId'];

    final managerDoc = await managerCollection.doc(managerId).get();
    final userDoc = await userCollection.doc(userId).get();
    final startDate = (managerDoc.data()['start_date'] as Timestamp).toDate();
    final workPeriod = DateTime.now().difference(startDate).inDays;

    return {
      'name': userDoc.data()['name'],
      'studentId': userDoc.data()['studentId'].toString(),
      'startDate': DateFormat.yMMMd().format(startDate),
      'workPeriod': workPeriod.toString(),
      'cost': managerDoc.data()['cost'].toString()
    };
  }

  // default meal functions
  Future<void> createUserDefaultMeal(
      bool breakfast, bool lunch, bool dinner) async {
    await userCollection.doc(uid).collection('defaultMeals').add({
      'start_date': DateTime.now(),
      'default_meal': <String, bool>{
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner
      }
    });
  }

  Future<void> updateUserDefaultMeal(
      bool breakfast, bool lunch, bool dinner) async {
    await userCollection.doc(uid).update({
      'default_meal': <String, bool>{
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner
      }
    });
    await createUserDefaultMeal(breakfast, lunch, dinner);
  }

  // user data from snapshot
  // User _userDataFromSnapshot(docSnapshot snapshot) {
  //   return User(
  //     uid: uid,
  //     defaultMeal: Map<String, bool>.from(snapshot.data()['default_meal']),
  //     currentFortnightMealAmount:
  //         snapshot.data()['current_fortnight_meal_amount'],
  //   );
  // }

  // Stream<User> get userData {
  //   return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  // }

  Future<void> createNewMealData(
      DateTime date, bool breakfast, bool lunch, bool dinner) async {
    final _date = DateTime(date.year, date.month, date.day);
    await userCollection.doc(uid).collection('meals').add({
      'date': _date,
      'meal': <String, bool>{
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner
      },
    });
  }

  Future<void> updateMealData(
      DateTime date, bool breakfast, bool lunch, bool dinner) async {
    final _date = DateTime(date.year, date.month, date.day);
    final snapshot = await queryMealData(_date);
    final doc = snapshot.docs.first;
    final docId = doc.id;

    await userCollection.doc(uid).collection('meals').doc(docId).update({
      'meal': <String, bool>{
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner
      },
    });
  }

  // get a user's meal settings for a given date
  Future<Map<String, bool>> getMealData(DateTime date) async {
    final _date = DateTime(date.year, date.month, date.day);

    QuerySnapshot snapshot = await queryMealData(_date);
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return Map<String, bool>.from(doc.data()['meal']);
    }
    return null;
  }

  Future<QuerySnapshot> queryMealData(DateTime date) async {
    return await userCollection
        .doc(uid)
        .collection('meals')
        .where('date', isEqualTo: date)
        .get();
  }

  // list of users who subscribed for today's breakfast, lunch and dinner
  static Future<Map<String, List<String>>> mealTakersGrouped() async {
    final today = DateTime.now();
    final _date = DateTime(today.year, today.month, today.day);

    final usersSnapshot = await userCollection.get();
    final users = usersSnapshot.docs;

    Map<String, List<String>> mealUsers = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
    };

    for (var user in users) {
      final roles = List<String>.from(user.data()['roles'] ?? []);
      if (!roles.contains('admin') && !roles.contains('messboy')) {
        final userMeal = await userCollection
            .doc(user.id)
            .collection('meals')
            .where('date', isEqualTo: _date)
            .get();

        final mealDoc = userMeal.docs;
        final defaultMeal = user.data()['default_meal'];
        final name = user.data()['name'];

        if (mealDoc.isEmpty) {
          if (defaultMeal['breakfast']) mealUsers['breakfast'].add(name);
          if (defaultMeal['lunch']) mealUsers['lunch'].add(name);
          if (defaultMeal['dinner']) mealUsers['dinner'].add(name);
        } else {
          final meal = mealDoc.first.data()['meal'];
          if (meal['breakfast']) mealUsers['breakfast'].add(name);
          if (meal['lunch']) mealUsers['lunch'].add(name);
          if (meal['dinner']) mealUsers['dinner'].add(name);
        }
      }
    }
    return mealUsers;
  }

  // meal amount functions
  Future<Map<String, num>> getMealAmount(DateTime date) async {
    final _date = DateTime(date.year, date.month, date.day);

    QuerySnapshot snapshot =
        await mealAmountCollection.where('date', isEqualTo: _date).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return Map<String, num>.from(doc.data()['amounts']);
    }
    return null;
  }

  Future<void> createMealAmount(
      DateTime date, num breakfast, num lunch, num dinner) async {
    final _date = DateTime(date.year, date.month, date.day);

    await mealAmountCollection.add({
      'date': _date,
      'meal': <String, num>{
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner
      }
    });
  }

  Future<void> updateMealAmount(
      DateTime date, num breakfast, num lunch, num dinner) async {
    final _date = DateTime(date.year, date.month, date.day);
    final snapshot =
        await mealAmountCollection.where('date', isEqualTo: _date).get();
    final doc = snapshot.docs.first;
    final docId = doc.id;

    await mealAmountCollection.doc(docId).update({
      'meal': <String, num>{
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner
      }
    });
  }

  // budget and cost calculation functions
  Future<Map<String, num>> mealAmountCalc() async {
    int breakfast = 0;
    int lunch = 0;
    int dinner = 0;
    double total = 0.0;

    final mealCollection = userCollection.doc(this.uid).collection('meals');
    final defaultMealCollection =
        userCollection.doc(this.uid).collection('defaultMeals');

    DateTime todayFull = DateTime.now();
    DateTime today = DateTime(todayFull.year, todayFull.month, todayFull.day);
    DateTime firstDayFull = today.subtract(Duration(days: 30));
    DateTime firstDay =
        DateTime(firstDayFull.year, firstDayFull.month, firstDayFull.day);

    final afterSnapshot = await defaultMealCollection
        .where('start_date', isGreaterThanOrEqualTo: firstDay)
        .orderBy('start_date')
        .get();
    final beforeSnapshot = await defaultMealCollection
        .where('start_date', isLessThanOrEqualTo: firstDay)
        .orderBy('start_date', descending: true)
        .limit(1)
        .get();

    final mealMap = Map<DateTime, Map<String, bool>>();

    if (afterSnapshot.docs.isEmpty) {
      if (beforeSnapshot.docs.isEmpty) {
        var day = firstDay;
        while (day.isBefore(today)) {
          mealMap[day] = {'breakfast': true, 'lunch': true, 'dinner': true};
          day = day.add(Duration(days: 1));
        }
      } else {
        final defaultMeal = beforeSnapshot.docs.first.data()['default_meal'];
        var day = firstDay;
        while (day.isBefore(today)) {
          mealMap[day] = {
            'breakfast': defaultMeal['breakfast'],
            'lunch': defaultMeal['lunch'],
            'dinner': defaultMeal['dinner']
          };
          day = day.add(Duration(days: 1));
        }
      }
    } else {
      final docs = afterSnapshot.docs;
      DateTime afterStartDay;
      if (docs.length == 1) {
        DateTime day = docs.first.data()['start_date'];
        if (day.hour >= 6) {
          day = day.add(Duration(days: 1));
        }
        day = DateTime(day.year, day.month, day.day);

        afterStartDay = day;
        final defaultMeal = docs.first.data()['default_meal'];
        while (day.isBefore(today)) {
          mealMap[day] = {
            'breakfast': defaultMeal['breakfast'],
            'lunch': defaultMeal['lunch'],
            'dinner': defaultMeal['dinner']
          };
          day = day.add(Duration(days: 1));
        }
      } else {
        var i = 0;

        afterStartDay = docs.first.data()['start_date'].toDate();
        while (i < docs.length) {
          DateTime currentDay = docs.elementAt(i).data()['start_date'].toDate();
          if (currentDay.hour >= 6) {
            currentDay = currentDay.add(Duration(days: 1));
          }
          currentDay =
              DateTime(currentDay.year, currentDay.month, currentDay.day);

          DateTime nextDay;
          if (i + 1 < docs.length) {
            nextDay = docs.elementAt(i + 1).data()['start_date'].toDate();
          } else {
            nextDay = today;
          }

          var defaultMeal = docs.elementAt(i).data()['default_meal'];
          var day = currentDay;
          while (day.isBefore(nextDay)) {
            mealMap[day] = {
              'breakfast': defaultMeal['breakfast'],
              'lunch': defaultMeal['lunch'],
              'dinner': defaultMeal['dinner']
            };
            day = day.add(Duration(days: 1));
          }
          i++;
        }
      }

      var defaultMeal;
      if (beforeSnapshot.docs.isEmpty) {
        defaultMeal = {'breakfast': true, 'lunch': true, 'dinner': true};
      } else {
        defaultMeal = beforeSnapshot.docs.first.data()['default_meal'];
      }
      DateTime day = firstDay;
      while (day.isBefore(afterStartDay)) {
        mealMap[day] = {
          'breakfast': defaultMeal['breakfast'],
          'lunch': defaultMeal['lunch'],
          'dinner': defaultMeal['dinner']
        };
        day = day.add(Duration(days: 1));
      }
    }

    final mealSnapshot = await mealCollection
        .where('date', isGreaterThanOrEqualTo: firstDay)
        .where('date', isLessThan: today)
        .get();
    mealSnapshot.docs.forEach((doc) {
      DateTime date = doc.data()['date'].toDate();
      final meal = Map<String, bool>.from(doc.data()['meal']);
      mealMap.update(date, (defMeal) => meal);
    });

    mealMap.forEach((date, meal) {
      if (meal['breakfast']) {
        breakfast++;
        total += 0.5;
      }
      if (meal['lunch']) {
        lunch++;
        total += date.weekday == 5 ? 2.5 : 1.0;
      }
      if (meal['dinner']) {
        dinner++;
        total += date.weekday == 2 ? 1.5 : 1.0;
      }
    });

    final mealAmountSnapshot = await mealAmountCollection
        .where('date', isGreaterThanOrEqualTo: firstDay)
        .where('date', isLessThan: today)
        .get();
    mealAmountSnapshot.docs.forEach((doc) {
      DateTime date = doc.data()['date'].toDate();
      final amounts = Map<String, num>.from(doc.data()['meal']);
      total = total - 0.5 + amounts['breakfast'];
      final lunchAmt = date.weekday == 5 ? 2.5 : 1.0;
      total = total - lunchAmt + amounts['lunch'];
      final dinnerAmt = date.weekday == 2 ? 1.5 : 1.0;
      total = total - dinnerAmt + amounts['dinner'];
    });

    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'total_meal_amount': total
    };
  }
}
