import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_meal/models/fund.dart';
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
      data: {
        'users': FieldValue.increment(1),
      },
      merge: true,
    );

    if (user.isManager()) {
      // create new document in managers collection
      String managerId = await _firestoreService.createDocument(
        collectionPath: FirestorePath.managers(),
        data: {
          'uid': user.uid,
          'name': user.name,
        },
      );
      // update current manager document
      await _setCurrentManager(
        uid: user.uid,
        name: user.name,
        managerId: managerId,
      );
    }
  }

  Future<int> _getUserCount() async {
    final data = await _firestoreService.getData(path: FirestorePath.counts());
    return data['users'];
  }

  Future<int> getTotalFunds() async {
    final data = await _firestoreService.getData(path: FirestorePath.counts());
    return data['totalFunds'];
  }

  Stream<int> totalFundStream() => _firestoreService.documentStream(
        path: FirestorePath.counts(),
        builder: (data, documentId) => data['totalFunds'],
      );

  Stream<Map<String, dynamic>> currentManagerStream() =>
      _firestoreService.documentStream(
        path: FirestorePath.currentManager(),
        builder: (data, documentId) => data,
      );

  Future<int> updateManagerSerials() async {
    int userCount = await _getUserCount();
    if (userCount < 5) {
      return userCount + 1;
    }

    final users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
      queryBuilder: (query) => query.where('managerSerial', isGreaterThan: 4),
    );

    Member user;
    for (user in users) {
      await _firestoreService.setData(
        path: FirestorePath.user(user.uid),
        data: {
          'managerSerial': FieldValue.increment(1)
        }, //  user.managerSerial + 1
        merge: true,
      );
    }

    return 5; // new user will always start at serial 5
  }

  _setCurrentManager({String uid, String name, String managerId}) async {
    DateTime startDate = DateTime.now();
    if (startDate.hour > 7) {
      startDate = startDate.add(Duration(days: 1));
    }
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
    await _firestoreService.setData(
      path: FirestorePath.currentManager(),
      data: {
        'managerId': managerId,
        'uid': uid,
        'name': name,
        'cost': 0,
        'totalEggCount': 0,
        'startDate': startDate.toIso8601String(),
      },
    );
  }

  Future<Map<String, dynamic>> _getCurrentManager() =>
      _firestoreService.getData(path: FirestorePath.currentManager());

  Future<void> updateCurrentManagerCost(int addedCost) =>
      _firestoreService.setData(
        path: FirestorePath.currentManager(),
        data: {
          'cost': FieldValue.increment(addedCost),
        },
        merge: true,
      );

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

    /*  if default meal is updated after 7am, 
        set today's meal with old meal
        (in case today's meal doesn't exist yet)
    */
    DateTime now = DateTime.now();
    if (now.hour > 6) {
      DateTime today = DateTime(now.year, now.month, now.day);

      DocumentSnapshot document = await _firestoreService.getDocument(
          path: FirestorePath.meal(uid, today.toIso8601String()));
      if (!document.exists) {
        setMeal(
          Meal(
            breakfast: oldMeal.breakfast,
            lunch: oldMeal.lunch,
            dinner: oldMeal.dinner,
            date: today,
          ),
        );
      }
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

  // retrieve fixed cost
  Future<double> getFixedCost() async {
    final data = await _firestoreService.getData(path: FirestorePath.others());
    return double.parse(data['fixedCost'].toString());
  }

  // update manager
  Future<void> updateManager() async {
    Map<String, dynamic> currentManager = await _getCurrentManager();

    String oldManagerId = currentManager['managerId'];
    DateTime startDate = DateTime.parse(currentManager['startDate']);
    DateTime endDate = DateTime.now();
    if (endDate.hour < 7) {
      endDate = endDate.subtract(Duration(days: 1));
    }
    endDate = DateTime(endDate.year, endDate.month, endDate.day);

    DateTime tempDate;
    Map<DateTime, MealAmount> mealAmounts = Map();
    tempDate = startDate;

    DocumentSnapshot document;
    // fetch meal amounts for the duration
    while (true) {
      document = await _firestoreService.getDocument(
        path: FirestorePath.mealAmount(
          tempDate.toIso8601String(),
        ),
      );
      if (document.exists) {
        mealAmounts[tempDate] =
            MealAmount.fromMap(Map<String, double>.from(document.data()));
      } else {
        mealAmounts[tempDate] = MealAmount.fromDefault();
      }
      if (tempDate.isAtSameMomentAs(endDate)) break;
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

    Member user;
    String newManagerId;
    for (user in users) {
      // this user will be the new manager
      if (user.managerSerial == 2) {
        // create new document in managers collection
        newManagerId = await _firestoreService.createDocument(
          collectionPath: FirestorePath.managers(),
          data: {
            'uid': user.uid,
            'name': user.name,
          },
        );
        // update current manager document
        await _setCurrentManager(
          uid: user.uid,
          name: user.name,
          managerId: newManagerId,
        );
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

      tempDate = startDate;
      userMealAmount = 0;
      breakfastCount = 0;
      lunchCount = 0;
      dinnerCount = 0;

      while (true) {
        document = await _firestoreService.getDocument(
          path: FirestorePath.meal(user.uid, tempDate.toIso8601String()),
        );

        if (document.exists) {
          meal = Meal.fromMap(Map<String, bool>.from(document.data()));
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
        }
        if (tempDate.isAtSameMomentAs(endDate)) break;
        tempDate = tempDate.add(Duration(days: 1));
      }

      await _firestoreService.setData(
        path: FirestorePath.mealRecord(oldManagerId, user.uid),
        data: {
          'mealAmount': userMealAmount,
          'breakfastCount': breakfastCount,
          'lunchCount': lunchCount,
          'dinnerCount': dinnerCount,
        },
        merge: true,
      );

      totalMealAmount += userMealAmount;
    }

    double eggUnitPrice = await getEggUnitPrice();
    await _firestoreService.setData(
      path: FirestorePath.manager(oldManagerId),
      data: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalCost': currentManager['cost'],
        'totalMealAmount': totalMealAmount,
        'perMealCost': (currentManager['cost'] -
                currentManager['totalEggCount'] * eggUnitPrice) /
            totalMealAmount,
      },
      merge: true,
    );

    for (user in users) {
      _firestoreService.setData(
        path: FirestorePath.mealRecord(newManagerId, user.uid),
        data: {'eggCount': 0},
      );
    }
  }

  Future<void> addFund(Fund fund) async {
    await _firestoreService.createDocument(
      collectionPath: FirestorePath.funds(),
      data: fund.toMap(),
    );
    await _firestoreService.setData(
      path: FirestorePath.counts(),
      data: {
        'totalFunds': FieldValue.increment(fund.amount),
      },
      merge: true,
    );
  }

  Future<List<Fund>> getFundList() => _firestoreService.listDocuments(
        path: FirestorePath.funds(),
        builder: (data, documentId) => Fund.fromMap(data),
        sort: (a, b) => b.date.difference(a.date).inSeconds,
      );

  // list of users who subscribed for today's breakfast, lunch and dinner
  Future<Map<String, List<Member>>> getMealSubscribers() async {
    final today = DateTime.now();
    final _date = DateTime(today.year, today.month, today.day);

    List<Member> users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
    );

    Map<String, List<Member>> mealSubscribers = {
      'breakfast': List<Member>(),
      'lunch': List<Member>(),
      'dinner': List<Member>(),
    };

    Meal meal, defaultMeal;
    DocumentSnapshot document;
    Member user;
    for (user in users) {
      defaultMeal = user.defaultMeal;
      document = await _firestoreService.getDocument(
        path: FirestorePath.meal(user.uid, _date.toIso8601String()),
      );

      if (document.exists) {
        meal = Meal.fromMap(Map<String, bool>.from(document.data()));
      } else {
        meal = defaultMeal;
        // set only after 7 am
        if (DateTime.now().hour > 6) {
          _setMealOfUser(
            Meal(
              breakfast: defaultMeal.breakfast,
              lunch: defaultMeal.lunch,
              dinner: defaultMeal.dinner,
              date: _date,
            ),
            user.uid,
          );
        }
      }
      if (meal.breakfast) mealSubscribers['breakfast'].add(user);
      if (meal.lunch) mealSubscribers['lunch'].add(user);
      if (meal.dinner) mealSubscribers['dinner'].add(user);
    }

    return mealSubscribers;
  }

  Future<List<Map<String, dynamic>>> getMealRecords() async {
    List<Map<String, dynamic>> managers = [], records = [];
    int userCount = await _getUserCount();
    double fixedCost = await getFixedCost();
    double eggUnitPrice = await getEggUnitPrice();
    double perUserFixedCost = fixedCost / userCount;

    await _firestoreService.listDocuments(
      path: FirestorePath.managers(),
      builder: (data, documentId) {
        Map<String, dynamic> manager = {
          'managerId': documentId,
          'managerName': data['name'],
          'startDate': data['startDate'],
          'endDate': data['endDate'],
          'perMealCost': data['perMealCost'],
        };
        managers.add(manager);
      },
    );
    for (var manager in managers) {
      Map<String, dynamic> mealData = await _firestoreService.getData(
        path: FirestorePath.mealRecord(manager['managerId'], uid),
      );
      if (mealData.containsKey('mealAmount')) {
        Map<String, dynamic> record = Map.from(manager);
        record['mealAmount'] = mealData['mealAmount'];
        record['breakfastCount'] = mealData['breakfastCount'];
        record['lunchCount'] = mealData['lunchCount'];
        record['dinnerCount'] = mealData['dinnerCount'];
        record['eggCount'] = mealData['eggCount'];
        record['mealCost'] = record['perMealCost'] * mealData['mealAmount'];
        record['fixedCost'] = perUserFixedCost;
        record['totalCost'] = record['mealCost'] +
            mealData['eggCount'] * eggUnitPrice +
            perUserFixedCost;
        records.add(record);
      }
    }
    return records;
  }

  Future<void> updateFixedCost(double newFixedCost) =>
      _firestoreService.setData(
        path: FirestorePath.others(),
        data: {
          'fixedCost': newFixedCost,
        },
        merge: true,
      );

  // retrieve unit price of eggs
  Future<double> getEggUnitPrice() async {
    final data = await _firestoreService.getData(path: FirestorePath.others());
    return double.parse(data['eggUnitPrice'].toString());
  }

  Stream<double> eggUnitPriceStream() => _firestoreService.documentStream(
        path: FirestorePath.others(),
        builder: (data, documentId) =>
            double.parse(data['eggUnitPrice'].toString()),
      );

  Future<void> updateEggUnitPrice(double newPrice) => _firestoreService.setData(
        path: FirestorePath.others(),
        data: {
          'eggUnitPrice': newPrice,
        },
        merge: true,
      );

  Future<void> updateEggCountOfUser(String userId) async {
    Map<String, dynamic> currentManager = await _getCurrentManager();
    String managerId = currentManager['managerId'];

    await _firestoreService.setData(
      path: FirestorePath.mealRecord(managerId, userId),
      data: {
        'eggCount': FieldValue.increment(1),
      },
      merge: true,
    );
    return _firestoreService.setData(
      path: FirestorePath.currentManager(),
      data: {
        'totalEggCount': FieldValue.increment(1),
      },
      merge: true,
    );
  }
}
