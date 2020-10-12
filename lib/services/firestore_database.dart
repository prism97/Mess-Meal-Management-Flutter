import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/meal_amount.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/services/firestore_path.dart';
import 'package:mess_meal/services/firestore_service.dart';
import 'package:meta/meta.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

/*
This is the main class access/call for any UI widgets that require to perform
any CRUD activities operation in Firestore database.
This class work hand-in-hand with FirestoreService and FirestorePath.
Notes:
For cases where you need to have a special method such as bulk update specifically
on a field, then is ok to use custom code and write it here. For example,
setAllTodoComplete is require to change all todos item to have the complete status
changed to true.
 */
class FirestoreDatabase {
  FirestoreDatabase({@required this.uid});
  // : assert(uid != null);
  final String uid;

  final _firestoreService = FirestoreService.instance;

  // create new user (member)
  createUser(Member user) async {
    await _firestoreService.setData(
      path: FirestorePath.user(user.uid),
      data: user.toMap(),
    );

    // increment user count by 1
    await _firestoreService.setData(
      path: FirestorePath.counts(),
      data: {'users': FieldValue.increment(1)},
    );

    if (user.isManager()) {
      _setCurrentManager(user);
    }
  }

  Future<int> _getUserCount() async {
    final data = await _firestoreService.getData(path: FirestorePath.counts());
    return data['users'];
  }

  Future<DateTime> _getCurrentManagerStartDate() async {
    final data =
        await _firestoreService.getData(path: FirestorePath.currentManager());
    return data['startDate'];
  }

  Future<int> updateManagerSerials() async {
    int userCount = await _getUserCount();
    if (userCount < 5) {
      return userCount + 1;
    }

    int newUserManagerSerial;
    final users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
      queryBuilder: (query) => query.where('manager_serial', isGreaterThan: 4),
    );

    users.forEach((user) {
      _firestoreService.setData(
        path: FirestorePath.user(user.uid),
        data: {
          'managerSerial': FieldValue.increment(1)
        }, //  user.managerSerial + 1
        merge: true,
      );
    });

    return newUserManagerSerial;
  }

  _setCurrentManager(Member user) async {
    DateTime startDate = DateTime.now();
    if (startDate.hour > 7) {
      startDate = startDate.add(Duration(days: 1));
    }
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
    await _firestoreService.setData(
      path: FirestorePath.currentManager(),
      data: {
        'uid': user.uid,
        'name': user.name,
        'cost': 0.0,
        'startDate': startDate.toIso8601String(),
      },
    );
  }

  Future<Map<String, dynamic>> _getCurrentManager() async =>
      _firestoreService.getData(path: FirestorePath.currentManager());

  // retrieve default meal of user
  Stream<Meal> defaultMealStream() => _firestoreService.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => Meal.fromMapWithDate(
          Map<String, dynamic>.from(data['defaultMeal']),
        ),
      );

  Future<Meal> getDefaultMeal() async {
    Member currentUser = Member.fromMap(
      await _firestoreService.getData(
        path: FirestorePath.user(uid),
      ),
      uid,
    );
    return currentUser.defaultMeal;
  }

  // update default meal of user
  Future<void> _setDefaultMeal(Meal meal) async {
    await _firestoreService.setData(
      path: FirestorePath.user(uid),
      data: {'defaultMeal': meal.toMap()},
      merge: true,
    );
  }

  Future<void> updateDefaultMeal(Meal oldMeal, Meal newMeal) async {
    await _setDefaultMeal(newMeal);
    DateTime updateStartDate, updateEndDate = newMeal.date;
    DateTime oldMealStartDate = oldMeal.date;
    DateTime currentManagerStartDate = await _getCurrentManagerStartDate();
    if (oldMealStartDate.isBefore(currentManagerStartDate)) {
      updateStartDate = currentManagerStartDate;
    } else {
      if (oldMealStartDate.hour < 7) {
        updateStartDate = oldMealStartDate;
      } else {
        updateStartDate = oldMealStartDate.add(Duration(days: 1));
      }
    }

    if (updateEndDate.hour < 7) {
      updateEndDate = newMeal.date.subtract(Duration(days: 1));
    }

    updateStartDate = DateTime(
        updateStartDate.year, updateStartDate.month, updateStartDate.day);
    updateEndDate =
        DateTime(updateEndDate.year, updateEndDate.month, updateEndDate.day);

    bool exists;

    while (true) {
      if (updateStartDate.isAtSameMomentAs(updateEndDate)) break;
      exists = await _firestoreService.documentExists(
        path: FirestorePath.meal(uid, updateStartDate.toIso8601String()),
      );
      if (!exists) {
        setMeal(
          Meal(
            breakfast: oldMeal.breakfast,
            lunch: oldMeal.lunch,
            dinner: oldMeal.dinner,
            date: updateStartDate,
          ),
        );
      }

      updateStartDate = updateStartDate.add(Duration(days: 1));
    }
  }

  // create/update meal
  Future<void> setMeal(Meal meal) async => await _firestoreService.setData(
        path: FirestorePath.meal(uid, meal.date.toIso8601String()),
        data: meal.toMap(),
        merge: true,
      );

  // create/update meal of any user
  Future<void> _setMealOfUser(Meal meal, String userUid) async =>
      await _firestoreService.setData(
        path: FirestorePath.meal(userUid, meal.date.toIso8601String()),
        data: meal.toMap(),
        merge: true,
      );

  // retrieve meal by date
  Stream<Meal> mealStream({@required DateTime date}) =>
      _firestoreService.documentStream(
        path: FirestorePath.meal(uid, date.toIso8601String()),
        builder: (data, documentId) => Meal.fromMap(
          Map<String, bool>.from(data),
          date: DateTime.parse(documentId),
        ),
      );

  // retrieve meal of any user by date
  Future<Meal> _getMealOfUser(
          {@required DateTime date, @required String uid}) async =>
      Meal.fromMap(
        await _firestoreService.getData(
          path: FirestorePath.meal(uid, date.toIso8601String()),
        ),
      );

  // create/update meal amount
  Future<void> setMealAmount(
          {@required DateTime date, @required MealAmount mealAmount}) =>
      _firestoreService.setData(
        path: FirestorePath.mealAmount(
          date.toIso8601String(),
        ),
        data: mealAmount.toMap(),
        merge: true,
      );

  // retrieve meal amount by date
  Stream<MealAmount> mealAmountStream({@required DateTime date}) =>
      _firestoreService.documentStream(
        path: FirestorePath.mealAmount(date.toIso8601String()),
        builder: (data, documentId) =>
            MealAmount.fromMap(Map<String, double>.from(data)),
      );

  Future<MealAmount> getMealAmount({@required DateTime date}) async =>
      MealAmount.fromMap(
          Map<String, double>.from(await _firestoreService.getData(
        path: FirestorePath.mealAmount(
          date.toIso8601String(),
        ),
      )));

  // retrieve all meals from the same user based on uid
  Future<List<Meal>> mealList() => _firestoreService.listDocuments(
        path: FirestorePath.meals(uid),
        builder: (data, documentId) =>
            Meal.fromMap(data, date: DateTime.parse(documentId)),
      );

  // update manager
  Future<void> updateManager() async {
    Map<String, dynamic> currentManager = await _getCurrentManager();
    DateTime startDate = currentManager['startDate'];
    DateTime endDate = DateTime.now();
    if (endDate.hour < 7) {
      endDate = endDate.subtract(Duration(days: 1));
    }
    endDate = DateTime(endDate.year, endDate.month, endDate.day);

    // create new document in managers collection
    String managerId = await _firestoreService.createDocument(
      collectionPath: FirestorePath.managers(),
      data: {
        'uid': currentManager['uid'],
        'name': currentManager['name'],
        'startDate': startDate,
        'endDate': endDate,
        'totalCost': currentManager['cost'],
      },
    );

    Meal defaultMeal;
    bool exists;
    DateTime tempDate;

    Map<DateTime, MealAmount> mealAmounts = Map();
    tempDate = startDate;

    // fetch meal amounts for the duration
    while (true) {
      if (tempDate.isAtSameMomentAs(endDate)) break;
      exists = await _firestoreService.documentExists(
        path: FirestorePath.mealAmount(
          tempDate.toIso8601String(),
        ),
      );
      if (exists) {
        mealAmounts[tempDate] = await getMealAmount(date: tempDate);
      } else {
        mealAmounts[tempDate] = MealAmount.fromDefault();
      }
      tempDate = tempDate.add(Duration(days: 1));
    }

    List<Member> users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
    );

    MealAmount mealAmount;
    Meal meal;
    double totalMealAmount = 0, userMealAmount;
    int breakfastCount, lunchCount, dinnerCount;

    users.forEach((user) async {
      // update current manager doc in system
      if (user.managerSerial == 2) {
        await _setCurrentManager(user);
      }

      // update user's manager serial
      if (user.isManager()) {
        int userCount = await _getUserCount();
        await _firestoreService.setData(
          path: FirestorePath.user(user.uid),
          data: {'managerSerial': userCount},
          merge: true,
        );
      } else {
        await _firestoreService.setData(
          path: FirestorePath.user(user.uid),
          data: {'managerSerial': FieldValue.increment(-1)},
          merge: true,
        );
      }

      defaultMeal = user.defaultMeal;
      tempDate = startDate;
      userMealAmount = 0;
      breakfastCount = 0;
      lunchCount = 0;
      dinnerCount = 0;

      while (true) {
        if (tempDate.isAtSameMomentAs(endDate)) break;
        exists = await _firestoreService.documentExists(
          path: FirestorePath.meal(user.uid, tempDate.toIso8601String()),
        );
        if (exists) {
          meal = await _getMealOfUser(date: tempDate, uid: user.uid);
        } else {
          _setMealOfUser(
            Meal(
              breakfast: defaultMeal.breakfast,
              lunch: defaultMeal.lunch,
              dinner: defaultMeal.dinner,
              date: tempDate,
            ),
            user.uid,
          );
          meal = defaultMeal;
        }

        mealAmount = mealAmounts[tempDate];
        if (meal.breakfast) {
          userMealAmount += mealAmount.breakfast;
          breakfastCount++;
        }
        if (meal.lunch) {
          userMealAmount += mealAmount.lunch;
          lunchCount++;
        }
        if (meal.dinner) {
          userMealAmount += mealAmount.dinner;
          dinnerCount++;
        }

        tempDate = tempDate.add(Duration(days: 1));
      }

      await _firestoreService.setData(
        path: FirestorePath.mealRecord(managerId, user.uid),
        data: {
          'mealAmount': userMealAmount,
          'breakfastCount': breakfastCount,
          'lunchCount': lunchCount,
          'dinnerCount': dinnerCount,
        },
      );

      totalMealAmount += userMealAmount;
    });

    await _firestoreService.setData(
      path: FirestorePath.manager(managerId),
      data: {
        'totalMealAmount': totalMealAmount,
        'perMealCost': currentManager['cost'] / totalMealAmount,
      },
      merge: true,
    );
  }
}
